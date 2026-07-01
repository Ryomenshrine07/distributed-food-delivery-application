import 'failure.dart';

/// A lightweight sealed Either type for representing a value that is either
/// a [Left] (failure/error) or a [Right] (success/value).
sealed class Either<L, R> {
  const Either();

  /// True when this is a [Right] (success) value.
  bool get isRight => this is Right<L, R>;

  /// True when this is a [Left] (failure) value.
  bool get isLeft => this is Left<L, R>;

  /// Pattern-match on both cases, returning a single result.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Transform the right (success) value, leaving left untouched.
  Either<L, T> map<T>(T Function(R right) transform);

  /// Transform the left (failure) value, leaving right untouched.
  Either<T, R> mapLeft<T>(T Function(L left) transform);

  /// Chain an operation that itself returns an [Either].
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) transform);

  /// Extract the right value or throw if this is a [Left].
  ///
  /// Useful for tests or places where failure is not expected.
  R getOrThrow();

  /// Extract the right value or return [defaultValue] if this is a [Left].
  R getOrElse(R Function() defaultValue);

  /// Swap left and right.
  Either<R, L> swap();
}

/// The failure (left) case of [Either].
final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      onLeft(value);

  @override
  Either<L, T> map<T>(T Function(R right) transform) => Left(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L left) transform) =>
      Left(transform(value));

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) transform) =>
      Left(value);

  @override
  R getOrThrow() => throw StateError('Called getOrThrow on a Left: $value');

  @override
  R getOrElse(R Function() defaultValue) => defaultValue();

  @override
  Either<R, L> swap() => Right(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// The success (right) case of [Either].
final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      onRight(value);

  @override
  Either<L, T> map<T>(T Function(R right) transform) =>
      Right(transform(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L left) transform) => Right(value);

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) transform) =>
      transform(value);

  @override
  R getOrThrow() => value;

  @override
  R getOrElse(R Function() defaultValue) => value;

  @override
  Either<R, L> swap() => Left(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

/// The standard result type used by all repositories.
///
/// A [Result] is either a [Left] containing a [Failure] or a [Right]
/// containing the success value of type [T].
typedef Result<T> = Either<Failure, T>;

/// Convenience extensions on [Result] for common patterns.
extension ResultExtensions<T> on Result<T> {
  /// Returns the success value or `null` if this is a failure.
  T? getOrNull() => fold((_) => null, (value) => value);

  /// Returns the failure or `null` if this is a success.
  Failure? get failureOrNull => fold((f) => f, (_) => null);

  /// Executes [action] only on success, returning the original [Result].
  Result<T> onSuccess(void Function(T value) action) {
    if (this is Right<Failure, T>) {
      action((this as Right<Failure, T>).value);
    }
    return this;
  }

  /// Executes [action] only on failure, returning the original [Result].
  Result<T> onFailure(void Function(Failure failure) action) {
    if (this is Left<Failure, T>) {
      action((this as Left<Failure, T>).value);
    }
    return this;
  }
}
