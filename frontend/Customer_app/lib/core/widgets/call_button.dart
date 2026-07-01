import 'package:flutter/material.dart';

import '../utils/dialer.dart';

/// An icon button that opens the native dialer for [phoneNumber].
///
/// The action is disabled whenever [phoneNumber] sanitizes to an empty string
/// (null, blank, or all-noise), so a call is only offered when there is a
/// dialable number (Req 6.6). On tap it dials via [launchDialer]; if the launch
/// fails it surfaces a non-blocking floating SnackBar and keeps running
/// (Req 6.5). It exposes a "Call" tooltip/semantic label and inherits
/// [IconButton]'s >=48x48 tap target (Req 9.1, 9.2).
///
/// [launcher] is injectable so widget tests can substitute a fake launcher
/// boundary instead of hitting the platform dialer; production code leaves it
/// null and the real url_launcher boundary is used.
class CallButton extends StatelessWidget {
  const CallButton({
    super.key,
    required this.phoneNumber,
    this.color,
    this.tooltip = 'Call',
    this.failureMessage = "Couldn't open the dialer",
    this.launcher,
  });

  /// The raw phone number to dial; may be null/blank when unavailable.
  final String? phoneNumber;

  /// Optional tint for the phone glyph (preserves each screen's existing look).
  final Color? color;

  /// Tooltip and accessibility label for the control.
  final String tooltip;

  /// Message shown in the floating SnackBar when the dialer cannot be opened.
  final String failureMessage;

  /// Test seam for the url_launcher boundary; null uses the real launcher.
  final UrlLauncher? launcher;

  /// The call action is enabled only when there is a dialable number.
  bool get _enabled => sanitizePhone(phoneNumber ?? '').isNotEmpty;

  Future<void> _dial(BuildContext context) async {
    // Capture the messenger before the await so we never touch a
    // possibly-unmounted BuildContext across the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final launcher = this.launcher;
    final launched = launcher == null
        ? await launchDialer(phoneNumber!)
        : await launchDialer(phoneNumber!, launcher: launcher);
    if (!launched) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(failureMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(Icons.phone, color: color),
      onPressed: _enabled ? () => _dial(context) : null,
    );
  }
}
