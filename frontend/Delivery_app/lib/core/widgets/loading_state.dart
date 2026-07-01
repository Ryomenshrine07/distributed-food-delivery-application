import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// A reusable loading-state placeholder for async/list screens.
///
/// Shows a centered progress indicator with an optional message. For richer
/// list skeletons the app may still use `shimmer`; this widget is the simple,
/// consistent default.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
  });

  /// Optional text shown beneath the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = context.typography;
    final colorScheme = context.colors;

    return Semantics(
      container: true,
      label: message ?? 'Loading',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                SizedBox(height: tokens.space16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
