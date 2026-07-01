import 'package:flutter/material.dart';
import 'app_tokens.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get typography => theme.textTheme;
  AppTokens get tokens => theme.extension<AppTokens>()!;
}
