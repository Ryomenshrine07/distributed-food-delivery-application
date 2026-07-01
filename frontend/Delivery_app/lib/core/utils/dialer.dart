import 'package:url_launcher/url_launcher.dart';

/// Signature for the URL-launch boundary used by [launchDialer].
///
/// Defaults to url_launcher's [launchUrl]. Tests substitute a fake so the
/// sanitization/gating logic can be verified deterministically without a real
/// platform channel.
typedef UrlLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

/// Strips every character that is not a digit (`0-9`) or `+` from [rawPhone],
/// preserving the relative order of the surviving characters.
///
/// Pure and deterministic (no I/O), so the sanitization rule is unit- and
/// property-testable in isolation (Req 6.3).
String sanitizePhone(String rawPhone) =>
    rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');

/// Opens the native phone dialer prefilled with the sanitized [rawPhone].
///
/// Sanitizes [rawPhone] to `[0-9+]`; if the result is empty it returns `false`
/// WITHOUT attempting a launch (Req 6.4). Otherwise it builds a `tel:` URI and
/// calls [launcher] directly (Req 6.1/6.2/6.3) — deliberately NOT gating on
/// `canLaunchUrl`, which needs query-scheme declarations and can falsely report
/// `false` for `tel:`. Returns whatever [launcher] reports (Req 6.5).
///
/// [launcher] defaults to url_launcher's [launchUrl] and is injectable so tests
/// can substitute a fake boundary.
Future<bool> launchDialer(
  String rawPhone, {
  UrlLauncher launcher = launchUrl,
}) async {
  final sanitized = sanitizePhone(rawPhone);
  if (sanitized.isEmpty) return false;
  final uri = Uri(scheme: 'tel', path: sanitized);
  return launcher(uri, mode: LaunchMode.externalApplication);
}
