import 'package:mocktail/mocktail.dart';

/// Contract for a no-argument void callback, mocked via [MockVoidCallback].
abstract class _VoidCallback {
  void call();
}

/// A recordable no-argument callback for verifying widget interactions
/// (e.g., a button's `onPressed`) with mocktail's `verify`.
class MockVoidCallback extends Mock implements _VoidCallback {}

/// Contract for a single-argument void callback.
abstract class _ValueCallback<T> {
  void call(T value);
}

/// A recordable single-argument callback (e.g., `onChanged`) for mocktail.
class MockValueCallback<T> extends Mock implements _ValueCallback<T> {}

/// Registers fallback values commonly needed by mocktail `any()` /
/// `captureAny()` matchers across this feature's tests. Safe to call multiple
/// times (mocktail de-duplicates by type).
void registerCommonFallbackValues() {
  registerFallbackValue(Uri());
  registerFallbackValue(Duration.zero);
}
