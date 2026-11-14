import 'package:flutter/material.dart';

/// ============================================================================
/// نظام الألوان الموحد المركزي للمشروع بالكامل (Enterprise Unified Colors)
/// ============================================================================
/// يمثل المرجع الحصري والشامل لكافة ألوان التطبيق في مشروعي NetSales و NetSales API.
/// يدعم الوضعين الفاتح والداكن (Light & Dark) ديناميكياً بدون أي تكرار أو تشتت.
class AppColors {
  // ── 1. Primary Colors (هوية النظام الأساسية) ──
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;

  // ── 2. Secondary Colors (اللون الثانوي - تيل ناعم) ──
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;

  // ── 3. Tertiary Colors (اللون التكميلي - أخضر نعناعي للأرصدة والشبكات) ──
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;

  // ── 4. Error Colors (حالات الخطأ والرفض) ──
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color onErrorVariant;

  // ── 5. Success Colors (حالات النجاح والعمليات المعتمدة) ──
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color onSuccessVariant;

  // ── 6. Warning Colors (حالات التنبيه والانتظار) ──
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color onWarningVariant;

  // ── 7. Info Colors (المعلومات والملاحظات) ──
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color onInfoVariant;

  // ── 8. Surface & Surfaces Hierarchy (الخلفيات والبطاقات والأسطح) ──
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceTint;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  // ── 9. Background Colors ──
  final Color background;
  final Color onBackground;

  // ── 10. Inverse Colors ──
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  // ── 11. Outline & Borders ──
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;

  // ── 12. Disabled & States ──
  final Color disabled;
  final Color onDisabled;

  // ── 13. Dividers ──
  final Color divider;

  // ── 14. Gradients (التدرجات اللونية الموحدة) ──
  final List<Color> primaryGradient;
  final LinearGradient successGradient;
  final LinearGradient errorGradient;
  final LinearGradient warningGradient;
  final LinearGradient infoGradient;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.onErrorVariant,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.onSuccessVariant,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.onWarningVariant,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.onInfoVariant,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceTint,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.background,
    required this.onBackground,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.disabled,
    required this.onDisabled,
    required this.divider,
    required this.primaryGradient,
    required this.successGradient,
    required this.errorGradient,
    required this.warningGradient,
    required this.infoGradient,
  });

  /// ── الوصول الموحد التلقائي حسب الثيم النشط في الشاشة ──
  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkColors : lightColors;
  }

  // ===========================================================================
  // لوحة ألوان الوضع الفاتح (Light Palette)
  // ===========================================================================
  static const lightColors = AppColors(
    primary: Color(0xFF059669),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD1FAE5),
    onPrimaryContainer: Color(0xFF064E3B),
    primaryFixed: Color(0xFFD1FAE5),
    primaryFixedDim: Color(0xFFA7F3D0),
    onPrimaryFixed: Color(0xFF064E3B),
    onPrimaryFixedVariant: Color(0xFF047857),

    secondary: Color(0xFF0D9488),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF115E59),
    secondaryFixed: Color(0xFFCCFBF1),
    secondaryFixedDim: Color(0xFF99F6E4),
    onSecondaryFixed: Color(0xFF115E59),
    onSecondaryFixedVariant: Color(0xFF0F766E),

    tertiary: Color(0xFF10B981),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD1FAE5),
    onTertiaryContainer: Color(0xFF064E3B),
    tertiaryFixed: Color(0xFFD1FAE5),
    tertiaryFixedDim: Color(0xFFA7F3D0),
    onTertiaryFixed: Color(0xFF064E3B),
    onTertiaryFixedVariant: Color(0xFF059669),

    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    onErrorVariant: Color(0xFFFEE2E2),

    success: Color(0xFF059669),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD1FAE5),
    onSuccessContainer: Color(0xFF064E3B),
    onSuccessVariant: Color(0xFFD1FAE5),

    warning: Color(0xFFD97706),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF92400E),
    onWarningVariant: Color(0xFFFEF3C7),

    info: Color(0xFF2563EB),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFDBEAFE),
    onInfoContainer: Color(0xFF1E40AF),
    onInfoVariant: Color(0xFFDBEAFE),

    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF475569),
    surfaceTint: Color(0xFF059669),
    surfaceDim: Color(0xFFE2E8F0),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFCBD5E1),

    background: Color(0xFFF8FAFC),
    onBackground: Color(0xFF0F172A),

    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFF34D399),

    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: Color(0x0F0F172A),
    scrim: Color(0xFF000000),

    disabled: Color(0xFFCBD5E1),
    onDisabled: Color(0xFF94A3B8),

    divider: Color(0xFFE2E8F0),

    primaryGradient: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    successGradient: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    errorGradient: LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    warningGradient: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    infoGradient: LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    ),
  );

  // ===========================================================================
  // لوحة ألوان الوضع الداكن (Dark Palette - VIP Obsidian & Emerald)
  // ===========================================================================
  static const darkColors = AppColors(
    primary: Color(0xFF10B981),
    onPrimary: Color(0xFF022C22),
    primaryContainer: Color(0xFF064E3B),
    onPrimaryContainer: Color(0xFFA7F3D0),
    primaryFixed: Color(0xFFD1FAE5),
    primaryFixedDim: Color(0xFFA7F3D0),
    onPrimaryFixed: Color(0xFF064E3B),
    onPrimaryFixedVariant: Color(0xFF10B981),

    secondary: Color(0xFF14B8A6),
    onSecondary: Color(0xFF042F2E),
    secondaryContainer: Color(0xFF115E59),
    onSecondaryContainer: Color(0xFF99F6E4),
    secondaryFixed: Color(0xFFCCFBF1),
    secondaryFixedDim: Color(0xFF99F6E4),
    onSecondaryFixed: Color(0xFF115E59),
    onSecondaryFixedVariant: Color(0xFF14B8A6),

    tertiary: Color(0xFF34D399),
    onTertiary: Color(0xFF022C22),
    tertiaryContainer: Color(0xFF065F46),
    onTertiaryContainer: Color(0xFFD1FAE5),
    tertiaryFixed: Color(0xFFD1FAE5),
    tertiaryFixedDim: Color(0xFFA7F3D0),
    onTertiaryFixed: Color(0xFF022C22),
    onTertiaryFixedVariant: Color(0xFF059669),

    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    onErrorVariant: Color(0xFFFEE2E2),

    success: Color(0xFF34D399),
    onSuccess: Color(0xFF022C22),
    successContainer: Color(0xFF064E3B),
    onSuccessContainer: Color(0xFFA7F3D0),
    onSuccessVariant: Color(0xFFA7F3D0),

    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
    warningContainer: Color(0xFF78350F),
    onWarningContainer: Color(0xFFFEF3C7),
    onWarningVariant: Color(0xFFFEF3C7),

    info: Color(0xFF60A5FA),
    onInfo: Color(0xFF172554),
    infoContainer: Color(0xFF1E3A8A),
    onInfoContainer: Color(0xFFDBEAFE),
    onInfoVariant: Color(0xFFDBEAFE),

    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFF8FAFC),
    surfaceVariant: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    surfaceTint: Color(0xFF10B981),
    surfaceDim: Color(0xFF0B0F17),
    surfaceBright: Color(0xFF1E293B),
    surfaceContainerLowest: Color(0xFF070A10),
    surfaceContainerLow: Color(0xFF0D1522),
    surfaceContainer: Color(0xFF111C2D),
    surfaceContainerHigh: Color(0xFF162236),
    surfaceContainerHighest: Color(0xFF1E2D44),

    background: Color(0xFF0B0F17),
    onBackground: Color(0xFFF8FAFC),

    inverseSurface: Color(0xFFF8FAFC),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: Color(0xFF059669),

    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF1E293B),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    disabled: Color(0xFF334155),
    onDisabled: Color(0xFF64748B),

    divider: Color(0xFF1E293B),

    primaryGradient: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    successGradient: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    errorGradient: LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    warningGradient: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    infoGradient: LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    ),
  );
}

/// ============================================================================
/// امتداد فائق السهولة على BuildContext للوصول السريع والموحد للألوان
/// ============================================================================
extension AppColorsExtension on BuildContext {
  /// الوصول المباشر لكافة ألوان النظام:
  /// context.colors.primary
  /// context.colors.success
  /// context.colors.surface
  AppColors get colors => AppColors.of(this);

  /// للتوافقية العكسية مع أي استدعاءات سابقة:
  AppColors get appColors => AppColors.of(this);
}
