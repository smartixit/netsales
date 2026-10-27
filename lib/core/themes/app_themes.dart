import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class AppThemes {
  AppThemes._();

  /// ── Light Theme ──
  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      colors: AppColors.lightColors,
    );
  }

  /// ── Dark Theme ──
  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: AppColors.darkColors,
    );
  }

  /// ── Build Theme ──
  static ThemeData _buildTheme({
    required Brightness brightness,
    required dynamic colors,
  }) {
    // final isDark = brightness == Brightness.dark;
    final c = colors;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // ── Color Scheme ──
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        primaryContainer: c.primaryContainer,
        onPrimaryContainer: c.onPrimaryContainer,
        secondary: c.secondary,
        onSecondary: c.onSecondary,
        secondaryContainer: c.secondaryContainer,
        onSecondaryContainer: c.onSecondaryContainer,
        tertiary: c.tertiary,
        onTertiary: c.onTertiary,
        tertiaryContainer: c.tertiaryContainer,
        onTertiaryContainer: c.onTertiaryContainer,
        error: c.error,
        onError: c.onError,
        errorContainer: c.errorContainer,
        onErrorContainer: c.onErrorContainer,
        surface: c.surface,
        onSurface: c.onSurface,
        surfaceContainerHighest: c.surfaceVariant,
        onSurfaceVariant: c.onSurfaceVariant,
        outline: c.outline,
        outlineVariant: c.outlineVariant,
        shadow: c.shadow,
        scrim: c.scrim,
        inverseSurface: c.inverseSurface,
        onInverseSurface: c.onInverseSurface,
        inversePrimary: c.inversePrimary,
        surfaceTint: c.surfaceTint,
      ),

      // ── Text Theme ──
      textTheme: _buildTextTheme(brightness: brightness),

      // ── Scaffold ──
      scaffoldBackgroundColor: c.background,

      // ── App Bar ──
      appBarTheme: _buildAppBarTheme(colors: c),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: _buildBottomNavTheme(colors: c),

      // ── Buttons ──
      elevatedButtonTheme: _buildElevatedButtonTheme(colors: c),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colors: c),
      textButtonTheme: _buildTextButtonTheme(colors: c),
      filledButtonTheme: _buildFilledButtonTheme(colors: c),

      // ── Input ──
      inputDecorationTheme: _buildInputDecorationTheme(colors: c),

      // ── Card ──
      cardTheme: _buildCardTheme(colors: c),

      // ── Dialog ──
      dialogTheme: _buildDialogTheme(colors: c),

      // ── Bottom Sheet ──
      bottomSheetTheme: _buildBottomSheetTheme(colors: c),

      // ── Snackbar ──
      snackBarTheme: _buildSnackbarTheme(colors: c),

      // ── Chip ──
      chipTheme: _buildChipTheme(colors: c),

      // ── Divider ──
      dividerTheme: _buildDividerTheme(colors: c),

      // ── List Tile ──
      listTileTheme: _buildListTileTheme(colors: c),

      // ── Switch ──
      switchTheme: _buildSwitchTheme(colors: c),

      // ── Checkbox ──
      checkboxTheme: _buildCheckboxTheme(colors: c),

      // ── Radio ──
      radioTheme: _buildRadioTheme(colors: c),

      // ── Slider ──
      sliderTheme: _buildSliderTheme(colors: c),

      // ── Progress Indicator ──
      progressIndicatorTheme: _buildProgressIndicatorTheme(colors: c),

      // ── Tooltip ──
      tooltipTheme: _buildTooltipTheme(colors: c),

      // ── Floating Action Button ──
      floatingActionButtonTheme: _buildFabTheme(colors: c),

      // ── Tab Bar ──
      tabBarTheme: _buildTabBarTheme(colors: c),

      // ── Splash & Ripple ──
      splashColor: c.primary.withValues(alpha: 0.1),
      highlightColor: c.primary.withValues(alpha: 0.05),

      // ── Font Family ──
      fontFamily: AppTypography.fontFamily,

      // ── Visual Density ──
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// ── Text Theme Builder ──
  static TextTheme _buildTextTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final color = isDark
        ? AppColors.darkColors.onSurface
        : AppColors.lightColors.onSurface;

    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: color),
      displayMedium: AppTypography.displayMedium.copyWith(color: color),
      displaySmall: AppTypography.displaySmall.copyWith(color: color),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: color),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: color),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: color),
      titleLarge: AppTypography.titleLarge.copyWith(color: color),
      titleMedium: AppTypography.titleMedium.copyWith(color: color),
      titleSmall: AppTypography.titleSmall.copyWith(color: color),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: color),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: color),
      bodySmall: AppTypography.bodySmall.copyWith(color: color),
      labelLarge: AppTypography.labelLarge.copyWith(color: color),
      labelMedium: AppTypography.labelMedium.copyWith(color: color),
      labelSmall: AppTypography.labelSmall.copyWith(color: color),
    );
  }

  /// ── App Bar Theme ──
  static AppBarTheme _buildAppBarTheme({required dynamic colors}) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: colors.onSurface,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colors == AppColors.lightColors
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: colors.background,
        systemNavigationBarIconBrightness: colors == AppColors.lightColors
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  /// ── Bottom Nav Theme ──
  static BottomNavigationBarThemeData _buildBottomNavTheme({
    required dynamic colors,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      selectedLabelStyle: AppTypography.labelMedium,
      unselectedLabelStyle: AppTypography.labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  /// ── Elevated Button Theme ──
  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    required dynamic colors,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.disabled,
        disabledForegroundColor: colors.onDisabled,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        textStyle: AppTypography.buttonText,
        minimumSize: Size(double.infinity, 56.h),
      ),
    );
  }

  /// ── Outlined Button Theme ──
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required dynamic colors,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.disabled,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        side: BorderSide(color: colors.outline, width: 1.5.w),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        textStyle: AppTypography.labelLarge,
        minimumSize: Size(double.infinity, 56.h),
      ),
    );
  }

  /// ── Text Button Theme ──
  static TextButtonThemeData _buildTextButtonTheme({required dynamic colors}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.disabled,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTypography.labelLarge,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// ── Filled Button Theme ──
  static FilledButtonThemeData _buildFilledButtonTheme({
    required dynamic colors,
  }) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  /// ── Input Decoration Theme ──
  static InputDecorationTheme _buildInputDecorationTheme({
    required dynamic colors,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPadding,
        vertical: AppSpacing.inputPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.outline, width: 1.w),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: colors.outline.withValues(alpha: .25),
          width: 1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.primary, width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.error, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.error, width: 2.w),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.disabled, width: 1.w),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurfaceVariant,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      errorStyle: AppTypography.errorText.copyWith(color: colors.error),
      prefixIconColor: colors.primary,
      suffixIconColor: colors.onSurfaceVariant,
      counterStyle: AppTypography.helperText,
    );
  }

  /// ── Card Theme ──
  static CardThemeData _buildCardTheme({required dynamic colors}) {
    return CardThemeData(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      margin: EdgeInsets.zero,
    );
  }

  /// ── Dialog Theme ──
  static DialogThemeData _buildDialogTheme({required dynamic colors}) {
    return DialogThemeData(
      backgroundColor: colors.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlRadius),
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: colors.onSurface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  }

  /// ── Bottom Sheet Theme ──
  static BottomSheetThemeData _buildBottomSheetTheme({
    required dynamic colors,
  }) {
    return BottomSheetThemeData(
      backgroundColor: colors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.topXl),
      modalBackgroundColor: colors.surfaceContainerLow,
      modalElevation: 0,
    );
  }

  /// ── Snackbar Theme ──
  static SnackBarThemeData _buildSnackbarTheme({required dynamic colors}) {
    return SnackBarThemeData(
      backgroundColor: colors.inverseSurface,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onInverseSurface,
      ),
      actionTextColor: colors.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );
  }

  /// ── Chip Theme ──
  static ChipThemeData _buildChipTheme({required dynamic colors}) {
    return ChipThemeData(
      backgroundColor: colors.surfaceContainerHighest,
      disabledColor: colors.disabled,
      selectedColor: colors.primaryContainer,
      secondarySelectedColor: colors.secondaryContainer,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      labelStyle: AppTypography.labelMedium.copyWith(color: colors.onSurface),
      secondaryLabelStyle: AppTypography.labelMedium.copyWith(
        color: colors.onSecondaryContainer,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
      side: BorderSide.none,
    );
  }

  /// ── Divider Theme ──
  static DividerThemeData _buildDividerTheme({required dynamic colors}) {
    return DividerThemeData(
      color: colors.divider,
      thickness: 1.w,
      space: AppSpacing.lg,
    );
  }

  /// ── List Tile Theme ──
  static ListTileThemeData _buildListTileTheme({required dynamic colors}) {
    return ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      minLeadingWidth: 24.w,
      iconColor: colors.onSurfaceVariant,
      textColor: colors.onSurface,
      titleTextStyle: AppTypography.bodyLarge,
      subtitleTextStyle: AppTypography.bodyMedium.copyWith(
        color: colors.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
    );
  }

  /// ── Switch Theme ──
  static SwitchThemeData _buildSwitchTheme({required dynamic colors}) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primaryContainer;
        }
        return colors.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  /// ── Checkbox Theme ──
  static CheckboxThemeData _buildCheckboxTheme({required dynamic colors}) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(colors.onPrimary),
      side: BorderSide(color: colors.outline, width: 1.5.w),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xsRadius),
    );
  }

  /// ── Radio Theme ──
  static RadioThemeData _buildRadioTheme({required dynamic colors}) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
    );
  }

  /// ── Slider Theme ──
  static SliderThemeData _buildSliderTheme({required dynamic colors}) {
    return SliderThemeData(
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.surfaceContainerHighest,
      thumbColor: colors.primary,
      overlayColor: colors.primary.withValues(alpha: 0.1),
      trackHeight: 4.h,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
    );
  }

  /// ── Progress Indicator Theme ──
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme({
    required dynamic colors,
  }) {
    return ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.surfaceContainerHighest,
      circularTrackColor: colors.surfaceContainerHighest,
      linearMinHeight: 4.h,
    );
  }

  /// ── Tooltip Theme ──
  static TooltipThemeData _buildTooltipTheme({required dynamic colors}) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: AppRadius.lgRadius,
      ),
      textStyle: AppTypography.labelSmall.copyWith(
        color: colors.onInverseSurface,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),
      // يمنع تفعيل التلميح بنقرة واحدة على سطح المكتب (سلوك Flutter
      // الافتراضي triggerMode = tap هناك)، إذ تُطلق نقرات الأزرار التي
      // تتنقّل (طباعة/تعديل...) حركة التلميح أثناء الانتقال فترمي
      // "TooltipState ... multiple tickers" و"!semantics.parentDataDirty".
      // الوضع longPress يطابق سلوك الهاتف ويجعل التلميح يظهر فقط بالضغط
      // المطوّل.
      triggerMode: TooltipTriggerMode.longPress,
    );
  }

  /// ── FAB Theme ──
  static FloatingActionButtonThemeData _buildFabTheme({
    required dynamic colors,
  }) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.fullRadius),
      sizeConstraints: BoxConstraints.tightFor(width: 56.w, height: 56.h),
    );
  }

  /// ── Tab Bar Theme ──
  static TabBarThemeData _buildTabBarTheme({required dynamic colors}) {
    return TabBarThemeData(
      labelColor: colors.primary,
      unselectedLabelColor: colors.onSurfaceVariant,
      labelStyle: AppTypography.labelLarge,
      unselectedLabelStyle: AppTypography.labelLarge,
      indicatorColor: colors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: colors.divider,
    );
  }
}
