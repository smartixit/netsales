import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  /// Base font family
  static const String fontFamily = 'ibm';

  /// Font weights
  static const FontWeight w400 = FontWeight.w400; // Regular
  static const FontWeight w500 = FontWeight.w500; // Medium
  static const FontWeight w600 = FontWeight.w600; // SemiBold
  static const FontWeight w700 = FontWeight.w700; // Bold

  /// ── Display (Hero titles, large branding) ──
  /// displayLarge: 57sp, w400
  static TextStyle get displayLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 57.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.12.h,
  );

  /// displayMedium: 45sp, w400
  static TextStyle get displayMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 45.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.16.h,
  );

  /// displaySmall: 36sp, w400
  static TextStyle get displaySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.22.h,
  );

  /// ── Headline (Page titles, section headers) ──
  /// headlineLarge: 32sp, w400
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    height: 1.25.h,
  );

  /// headlineMedium: 28sp, w400
  static TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.29.h,
  );

  /// headlineSmall: 24sp, w400
  static TextStyle get headlineSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.33.h,
  );

  /// ── Title (Card titles, list items, app bar) ──
  /// titleLarge: 22sp, w500
  static TextStyle get titleLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.27.h,
  );

  /// titleMedium: 16sp, w500
  static TextStyle get titleMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.5.h,
  );

  /// titleSmall: 14sp, w500
  static TextStyle get titleSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.43.h,
  );

  /// ── Body (Main content text) ──
  /// bodyLarge: 16sp, w400
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.5.h,
  );

  /// bodyMedium: 14sp, w400
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.43.h,
  );

  /// bodySmall: 12sp, w400
  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.33.h,
  );

  /// ── Label (Buttons, chips, captions, overlines) ──
  /// labelLarge: 14sp, w500
  static TextStyle get labelLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.43.h,
  );

  /// labelMedium: 12sp, w500
  static TextStyle get labelMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.33.h,
  );

  /// labelSmall: 11sp, w500
  static TextStyle get labelSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: w500,
    letterSpacing: 0.sp,
    // height: 1.45.h,
  );

  /// ── Custom Styles (Project-specific) ──

  /// Brand name - Large display with tight tracking
  static TextStyle get brandName => TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.sp,
    fontWeight: w700,
    letterSpacing: 0.sp,
    // height: 1.1.h,
  );

  /// Hero title - Bold display
  static TextStyle get heroTitle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.sp,
    fontWeight: w700,
    letterSpacing: 0.sp,
    // height: 1.2.h,
  );

  /// Section title - SemiBold
  static TextStyle get sectionTitle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.sp,
    fontWeight: w700,
    letterSpacing: 0.sp,
    // height: 1.3.h,
  );

  /// Card title - Medium weight
  static TextStyle get cardTitle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: w600,
    letterSpacing: 0.sp,
    // height: 1.4.h,
  );

  /// Button text - Bold with tracking
  static TextStyle get buttonText => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: w700,
    letterSpacing: 0.sp,
    // height: 1.0.h,
  );

  /// Caption - Small muted text
  static TextStyle get caption => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.4.h,
  );

  /// Overline - Uppercase small text
  static TextStyle get overline => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: w600,
    // letterSpacing: 2.sp,
    // height: 1.0.h,
  );

  /// Error text
  static TextStyle get errorText => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: w500,
    // letterSpacing: 0.sp,
    // height: 1.33.h,
  );

  /// Helper text - Small secondary
  static TextStyle get helperText => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: w400,
    letterSpacing: 0.sp,
    // height: 1.4.h,
  );

  /// ── Responsive Helpers ──

  /// Scale font size based on screen width
  static double responsiveFont(double baseSize) {
    return baseSize.sp;
  }

  /// Get appropriate headline size for screen
  static TextStyle get responsiveHeadline {
    return headlineLarge;
  }

  /// Get appropriate body size for screen
  static TextStyle get responsiveBody {
    return bodyLarge;
  }
}
