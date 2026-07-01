import 'pbt.dart';

/// A small library of composable [Generator]s for property tests.
///
/// These constrain the input space intelligently for the pure-logic targets in
/// the design's Correctness Properties (cart counts, phone-like strings,
/// id sets, nullable coordinates, colors/sizes/DPR for the marker cache).
abstract final class Gen {
  /// Uniform boolean.
  static Generator<bool> boolean() => (random) => random.nextBool();

  /// Integer in the inclusive range `[min, maxInclusive]`.
  static Generator<int> intInRange(int min, int maxInclusive) {
    assert(maxInclusive >= min, 'maxInclusive must be >= min');
    return (random) => min + random.nextInt(maxInclusive - min + 1);
  }

  /// Non-negative integer in `[0, maxExclusive)`.
  static Generator<int> nonNegativeInt({int maxExclusive = 1 << 20}) =>
      (random) => random.nextInt(maxExclusive);

  /// Double in `[min, max)`.
  static Generator<double> doubleInRange(double min, double max) =>
      (random) => min + random.nextDouble() * (max - min);

  /// Wraps [inner] so it returns null with probability [nullProbability].
  static Generator<T?> nullable<T>(
    Generator<T> inner, {
    double nullProbability = 0.3,
  }) =>
      (random) =>
          random.nextDouble() < nullProbability ? null : inner(random);

  /// Picks one element of [values] uniformly.
  static Generator<T> oneOf<T>(List<T> values) {
    assert(values.isNotEmpty, 'values must not be empty');
    return (random) => values[random.nextInt(values.length)];
  }

  /// A string of up to [maxLength] characters drawn from [alphabet].
  static Generator<String> string({
    int maxLength = 12,
    String alphabet = _asciiAlphabet,
  }) =>
      (random) {
        final length = random.nextInt(maxLength + 1);
        final buffer = StringBuffer();
        for (var i = 0; i < length; i++) {
          buffer.write(alphabet[random.nextInt(alphabet.length)]);
        }
        return buffer.toString();
      };

  /// A phone-like string mixing digits, `+`, and noise (spaces, dashes,
  /// parentheses, letters) so dialer-sanitization logic is exercised across
  /// the whole input space.
  static Generator<String> phoneLike({int maxLength = 16}) =>
      string(maxLength: maxLength, alphabet: _phoneAlphabet);

  /// A short hex-ish id suitable for order/offer ids.
  static Generator<String> id({int length = 8}) => (random) {
        final buffer = StringBuffer();
        for (var i = 0; i < length; i++) {
          buffer.write(_hexAlphabet[random.nextInt(_hexAlphabet.length)]);
        }
        return buffer.toString();
      };

  /// A list of up to [maxLength] values from [inner].
  static Generator<List<T>> listOf<T>(
    Generator<T> inner, {
    int maxLength = 8,
  }) =>
      (random) {
        final length = random.nextInt(maxLength + 1);
        return List<T>.generate(length, (_) => inner(random));
      };

  /// A set of up to [maxLength] values from [inner].
  static Generator<Set<T>> setOf<T>(
    Generator<T> inner, {
    int maxLength = 8,
  }) =>
      (random) {
        final length = random.nextInt(maxLength + 1);
        final result = <T>{};
        for (var i = 0; i < length; i++) {
          result.add(inner(random));
        }
        return result;
      };

  static const String _asciiAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-_';
  static const String _phoneAlphabet = '0123456789+ ()-.abcXYZ';
  static const String _hexAlphabet = '0123456789abcdef';
}
