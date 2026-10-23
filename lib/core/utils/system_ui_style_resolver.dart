import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// ============================================================================
/// محلل مركزي لألوان/أنماط أشرطة النظام (Status/Navigation Bars)
/// ============================================================================
/// - لا ألوان hardcoded (AGENTS §1/§13).
/// - dynamic (light/dark) عبر Theme.of(context).brightness.
/// - Single Source of Truth لقيم SystemUiOverlayStyle.
abstract final class SystemUiStyleResolver {
  SystemUiStyleResolver._();

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static SystemUiOverlayStyle resolve(BuildContext context) {
    final colors = context.colors;
    final isDark = _isDark(context);

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: colors.surface,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  static void apply(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(resolve(context));
  }
}
