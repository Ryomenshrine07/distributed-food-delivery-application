import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

/// Minimum number of generated iterations each property test must run, per the
/// design's property-test configuration ("a minimum of 100 generated
/// iterations").
const int kDefaultPbtIterations = 100;

/// Builds the canonical tag string for a property test so every property test
/// in this feature is consistently tagged, e.g.:
///
/// `Feature: ui-modernization, Property 3: Idempotent rider release on completion`
///
/// Pass the result to `test(..., tags: propertyTag(3, 'Idempotent ...'))` or
/// use it in the test description.
String propertyTag(int number, String title) =>
    'Feature: ui-modernization, Property $number: $title';

/// A pure generator: produces a value of type [T] from a seeded [math.Random].
typedef Generator<T> = T Function(math.Random random);

/// Runs [check] against values produced by [generate].
///
/// Runs at least [kDefaultPbtIterations] iterations (the design's minimum); if
/// a smaller [iterations] is requested it is raised to that floor so the
/// convention always holds. The [seed] makes runs reproducible. On the first
/// failing value, a [TestFailure] is thrown that names the iteration index, the
/// seed, and the failing example (rendered via [describe] when provided) so the
/// counterexample is easy to reproduce.
void forAll<T>(
  Generator<T> generate,
  void Function(T value) check, {
  int iterations = kDefaultPbtIterations,
  int seed = 0x5EED,
  String Function(T value)? describe,
}) {
  final effectiveIterations = math.max(iterations, kDefaultPbtIterations);
  final random = math.Random(seed);
  for (var i = 0; i < effectiveIterations; i++) {
    final value = generate(random);
    try {
      check(value);
    } on TestFailure catch (failure) {
      final rendered = describe != null ? describe(value) : '$value';
      throw TestFailure(
        'Property failed at iteration $i of $effectiveIterations '
        '(seed=$seed).\n'
        'Failing example: $rendered\n'
        '${failure.message}',
      );
    }
  }
}
