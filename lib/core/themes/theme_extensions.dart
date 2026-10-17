import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_theme_colors.dart';
import 'package:netsales/core/themes/app_themes.dart';

extension ThemeDataX on ThemeData {
  AppThemeColors get appColors =>
      extension<AppThemeColors>() ??
      (brightness == Brightness.dark
          ? AppThemes.dark.extension<AppThemeColors>()!
          : AppThemes.light.extension<AppThemeColors>()!);
}
