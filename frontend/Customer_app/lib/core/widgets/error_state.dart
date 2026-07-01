import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// A reusable error-state placeholder for async/list screens.
///
/// Shows a centered error icon, a title, an optional detail message, and an
/// optional retry button. Colors and spacing come from the theme.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  /// Primary line describing the failure.
  final String title;

  /// Optional supporting detail shown beneath the title.
  final String? message;

  /// Glyph shown above the title.
  final IconData icon;

  /// Label for the retry action.
  final String retryLabel;

  /// Invoked when the retry button is pressed. When null, no button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: colorScheme.error,
              ),
              SizedBox(height: tokens.spaceMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              if (message != null) ...[
                SizedBox(height: tokens.spaceSm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                SizedBox(height: tokens.spaceLg),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
