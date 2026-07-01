import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// A reusable empty-state placeholder for async/list screens.
///
/// Shows a centered icon, a title, an optional supporting message, and an
/// optional call-to-action button. Spacing and type come from the theme so it
/// stays consistent with the rest of the app.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  /// Primary line describing the empty condition.
  final String title;

  /// Optional supporting text shown beneath the title.
  final String? message;

  /// Glyph shown above the title.
  final IconData icon;

  /// Optional call-to-action label. When null, no button is shown.
  final String? actionLabel;

  /// Invoked when the action button is pressed.
  final VoidCallback? onAction;

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
                color: colorScheme.onSurfaceVariant,
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
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: tokens.spaceLg),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
