import 'package:flutter/material.dart';

class AppColors {
  // ── Primary ──
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;

  // ── Secondary (Teal) ──
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;

  // ── Tertiary (Green Mint) ──
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;

  // ── Error ──
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color onErrorVariant;

  // ── Success ──
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color onSuccessVariant;

  // ── Warning ──
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color onWarningVariant;

  // ── Info ──
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color onInfoVariant;

  // ── Surface ──
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

  // ── Background ──
  final Color background;
  final Color onBackground;

  // ── Inverse ──
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  // ── Outline ──
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;

  // ── Disabled ──
  final Color disabled;
  final Color onDisabled;

  // ── Divider ──
  final Color divider;

  // ── Gradient ──
  final List<Color> primaryGradient;

  AppColors({
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
  });

  static final lightColors = AppColors(
    // ── Primary ──
    primary: Color(0xFF0D7A5F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB8F0E0),
    onPrimaryContainer: Color(0xFF00382A),
    primaryFixed: Color(0xFFB8F0E0),
    primaryFixedDim: Color(0xFF8CD6C2),
    onPrimaryFixed: Color(0xFF00382A),
    onPrimaryFixedVariant: Color(0xFF005C45),

    // ── Secondary (Teal) ──
    secondary: Color(0xFF1ABC9C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC8F5EC),
    onSecondaryContainer: Color(0xFF004D3D),
    secondaryFixed: Color(0xFFC8F5EC),
    secondaryFixedDim: Color(0xFF9EE8D8),
    onSecondaryFixed: Color(0xFF004D3D),
    onSecondaryFixedVariant: Color(0xFF007A60),

    // ── Tertiary (Green Mint) ──
    tertiary: Color(0xFF2ECC71),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD0F5DD),
    onTertiaryContainer: Color(0xFF004D25),
    tertiaryFixed: Color(0xFFD0F5DD),
    tertiaryFixedDim: Color(0xFFA8E6BF),
    onTertiaryFixed: Color(0xFF004D25),
    onTertiaryFixedVariant: Color(0xFF006E38),

    // ── Error ──
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    onErrorVariant: Color(0xFFFFDAD6),

    // ── Success ──
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFC8E6C9),
    onSuccessContainer: Color(0xFF1B5E20),
    onSuccessVariant: Color(0xFFC8E6C9),

    // ── Warning ──
    warning: Color(0xFFF57C00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE0B2),
    onWarningContainer: Color(0xFFE65100),
    onWarningVariant: Color(0xFFFFE0B2),

    // ── Info ──
    info: Color(0xFF1976D2),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFBBDEFB),
    onInfoContainer: Color(0xFF0D47A1),
    onInfoVariant: Color(0xFFBBDEFB),

    // ── Surface ──
    surface: Color(0xFFFAFDFB),
    onSurface: Color(0xFF191C1B),
    surfaceVariant: Color(0xFFDBE5E0),
    onSurfaceVariant: Color(0xFF3F4945),
    surfaceTint: Color(0xFF0D7A5F),
    surfaceDim: Color(0xFFD5DBD8),
    surfaceBright: Color(0xFFF5FAF7),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0F5F2),
    surfaceContainer: Color(0xFFEAEFF0),
    surfaceContainerHigh: Color(0xFFE4EAE7),
    surfaceContainerHighest: Color(0xFFDEE4E1),

    // ── Background ──
    background: Color(0xFFFAFDFB),
    onBackground: Color(0xFF191C1B),

    // ── Inverse ──
    inverseSurface: Color(0xFF2D312F),
    onInverseSurface: Color(0xFFEFF1EF),
    inversePrimary: Color(0xFF8CD6C2),

    // ── Outline ──
    outline: Color(0xFF6F7975),
    outlineVariant: Color(0xFFBFC9C4),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // ── Disabled ──
    disabled: Color(0xFFBFC9C4),
    onDisabled: Color(0xFF6F7975),

    // ── Divider ──
    divider: Color(0xFFD5DBD8),

    // ── Gradient ──
    primaryGradient: [Color(0xFF0D7A5F), Color(0xFF1ABC9C), Color(0xFF2ECC71)],
  );

  static final darkColors = AppColors(
    // ── Primary ──
    primary: Color(0xFF8CD6C2),
    onPrimary: Color(0xFF00382A),
    primaryContainer: Color(0xFF005C45),
    onPrimaryContainer: Color(0xFFB8F0E0),
    primaryFixed: Color(0xFFB8F0E0),
    primaryFixedDim: Color(0xFF8CD6C2),
    onPrimaryFixed: Color(0xFF00382A),
    onPrimaryFixedVariant: Color(0xFFB8F0E0),

    // ── Secondary (Teal) ──
    secondary: Color(0xFF9EE8D8),
    onSecondary: Color(0xFF004D3D),
    secondaryContainer: Color(0xFF007A60),
    onSecondaryContainer: Color(0xFFC8F5EC),
    secondaryFixed: Color(0xFFC8F5EC),
    secondaryFixedDim: Color(0xFF9EE8D8),
    onSecondaryFixed: Color(0xFF004D3D),
    onSecondaryFixedVariant: Color(0xFFC8F5EC),

    // ── Tertiary (Green Mint) ──
    tertiary: Color(0xFFA8E6BF),
    onTertiary: Color(0xFF004D25),
    tertiaryContainer: Color(0xFF006E38),
    onTertiaryContainer: Color(0xFFD0F5DD),
    tertiaryFixed: Color(0xFFD0F5DD),
    tertiaryFixedDim: Color(0xFFA8E6BF),
    onTertiaryFixed: Color(0xFF004D25),
    onTertiaryFixedVariant: Color(0xFF006E38),

    // ── Error ──
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    onErrorVariant: Color(0xFFFFDAD6),

    // ── Success ──
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF1B5E20),
    successContainer: Color(0xFF2E7D32),
    onSuccessContainer: Color(0xFFC8E6C9),
    onSuccessVariant: Color(0xFFC8E6C9),

    // ── Warning ──
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF6D4C00),
    warningContainer: Color(0xFFF57C00),
    onWarningContainer: Color(0xFFFFE0B2),
    onWarningVariant: Color(0xFFFFE0B2),

    // ── Info ──
    info: Color(0xFF90CAF9),
    onInfo: Color(0xFF0D47A1),
    infoContainer: Color(0xFF1976D2),
    onInfoContainer: Color(0xFFBBDEFB),
    onInfoVariant: Color(0xFFBBDEFB),

    // ── Surface ──
    surface: Color(0xFF0A1F14),
    onSurface: Color(0xFFE0E3E1),
    surfaceVariant: Color(0xFF1A3A28),
    onSurfaceVariant: Color(0xFFBFC9C4),
    surfaceTint: Color(0xFF8CD6C2),
    surfaceDim: Color(0xFF0A1F14),
    surfaceBright: Color(0xFF2D312F),
    surfaceContainerLowest: Color(0xFF050F0A),
    surfaceContainerLow: Color(0xFF0D3A28),
    surfaceContainer: Color(0xFF0F3D2A),
    surfaceContainerHigh: Color(0xFF124530),
    surfaceContainerHighest: Color(0xFF144A35),

    // ── Background ──
    background: Color(0xFF050F0A),
    onBackground: Color(0xFFE0E3E1),

    // ── Inverse ──
    inverseSurface: Color(0xFFE0E3E1),
    onInverseSurface: Color(0xFF191C1B),
    inversePrimary: Color(0xFF0D7A5F),

    // ── Outline ──
    outline: Color(0xFF89938E),
    outlineVariant: Color(0xFF3F4945),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // ── Disabled ──
    disabled: Color(0xFF3F4945),
    onDisabled: Color(0xFF89938E),

    // ── Divider ──
    divider: Color(0xFF1A3A28),

    // ── Gradient ──
    primaryGradient: [Color(0xFF8CD6C2), Color(0xFF9EE8D8), Color(0xFFA8E6BF)],
  );
}
