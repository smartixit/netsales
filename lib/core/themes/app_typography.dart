import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ============================================================================
/// نظام التيبوغرافي المركزي الموحد (Enterprise Design System Typography)
/// ============================================================================
/// مصمم وفق أعلى معايير أنظمة التصميم العالمية (Material 3, Apple HIG, Stripe).
/// يمثل المصدر المركزي الوحيد والنهائي لكافة نصوص التطبيق بدون أي أرقام عشوائية.
class AppTypography {
  AppTypography._();

  /// اسم الخط الأساسي الموحد للنظام
  static const String fontFamily = 'ibm';

  // ---------------------------------------------------------------------------
  // أوزان الخطوط القياسية (Font Weights)
  // ---------------------------------------------------------------------------
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ===========================================================================
  // 1. شاشات العرض الكبرى (Display - Hero & Big Stats)
  // ===========================================================================

  /// displayLarge (57sp, Bold)
  static TextStyle get displayLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 57.sp,
        fontWeight: bold,
        letterSpacing: -0.25.sp,
        height: 1.15.h,
      );

  /// displayMedium (45sp, Bold)
  static TextStyle get displayMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 45.sp,
        fontWeight: bold,
        letterSpacing: 0.sp,
        height: 1.18.h,
      );

  /// displaySmall (36sp, Bold)
  static TextStyle get displaySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36.sp,
        fontWeight: bold,
        letterSpacing: 0.sp,
        height: 1.22.h,
      );

  // ===========================================================================
  // 2. عناوين الشاشات والأقسام (Headline - Screen & Section Titles)
  // ===========================================================================

  /// headlineLarge (32sp, Bold)
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.sp,
        fontWeight: bold,
        letterSpacing: 0.sp,
        height: 1.25.h,
      );

  /// headlineMedium (28sp, SemiBold)
  static TextStyle get headlineMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.sp,
        fontWeight: semiBold,
        letterSpacing: 0.sp,
        height: 1.28.h,
      );

  /// headlineSmall (24sp, SemiBold)
  static TextStyle get headlineSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.sp,
        fontWeight: semiBold,
        letterSpacing: 0.sp,
        height: 1.32.h,
      );

  // ===========================================================================
  // 3. عناوين البطاقات والقوائم (Title - Cards, Lists, AppBar)
  // ===========================================================================

  /// titleLarge (20sp, Bold)
  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.sp,
        fontWeight: bold,
        letterSpacing: 0.sp,
        height: 1.3.h,
      );

  /// titleMedium (16sp, SemiBold)
  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: semiBold,
        letterSpacing: 0.15.sp,
        height: 1.35.h,
      );

  /// titleSmall (14sp, SemiBold)
  static TextStyle get titleSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: semiBold,
        letterSpacing: 0.1.sp,
        height: 1.4.h,
      );

  // ===========================================================================
  // 4. نصوص المحتوى والفقرات (Body - Paragraphs & Content)
  // ===========================================================================

  /// bodyLarge (16sp, Regular)
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: regular,
        letterSpacing: 0.15.sp,
        height: 1.5.h,
      );

  /// bodyMedium (14sp, Regular)
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: regular,
        letterSpacing: 0.25.sp,
        height: 1.45.h,
      );

  /// bodySmall (12sp, Regular)
  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: regular,
        letterSpacing: 0.3.sp,
        height: 1.4.h,
      );

  // ===========================================================================
  // 5. خطوط الأزرار المركزية (Button Tokens - Enterprise Hierarchy)
  // ===========================================================================

  /// زر بحجم كبير (Large Button - Hero / CTAs / Auth)
  static TextStyle get buttonLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: bold,
        letterSpacing: 0.2.sp,
        height: 1.15.h,
      );

  /// زر بحجم قياسي (Medium Button - Standard / Dialogs / Forms)
  static TextStyle get buttonMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: semiBold,
        letterSpacing: 0.1.sp,
        height: 1.15.h,
      );

  /// زر بحجم صغير (Small Button - Compact / Tables / Inline)
  static TextStyle get buttonSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: semiBold,
        letterSpacing: 0.sp,
        height: 1.15.h,
      );

  /// خط الزر التقليدي (للتوافقية العكسية)
  static TextStyle get buttonText => buttonLarge;

  /// Material 3 Label Aliases
  static TextStyle get labelLarge => buttonLarge;
  static TextStyle get labelMedium => buttonMedium;
  static TextStyle get labelSmall => buttonSmall;

  /// Input Helper & Error Aliases
  static TextStyle get errorText => inputError;
  static TextStyle get helperText => caption;

  // ===========================================================================
  // 6. حقول الإدخال والنماذج (Input & Form Tokens)
  // ===========================================================================

  /// النص المدخل داخل الحقل
  static TextStyle get inputText => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.sp,
        fontWeight: medium,
        letterSpacing: 0.sp,
        height: 1.3.h,
      );

  /// نص التلميح داخل الحقل (Hint / Placeholder)
  static TextStyle get inputHint => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: regular,
        letterSpacing: 0.sp,
        height: 1.3.h,
      );

  /// عنوان الحقل العلوي (Label)
  static TextStyle get inputLabel => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.sp,
        fontWeight: semiBold,
        letterSpacing: 0.1.sp,
        height: 1.3.h,
      );

  /// رسالة خطأ التحقق (Validation Error)
  static TextStyle get inputError => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: medium,
        letterSpacing: 0.sp,
        height: 1.25.h,
      );

  // ===========================================================================
  // 7. المعاملات المالية والمبالغ (Financial & Currency Tokens)
  // ===========================================================================

  /// رصيد المحفظة الرئيسي الكبير
  static TextStyle get currencyHero => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.sp,
        fontWeight: extraBold,
        letterSpacing: -0.5.sp,
        height: 1.1.h,
      );

  /// أسعار الكروت وبنود الفواتير
  static TextStyle get currencyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.sp,
        fontWeight: bold,
        letterSpacing: 0.sp,
        height: 1.2.h,
      );

  /// رمز العملة المصغر بجانب الرقم
  static TextStyle get currencySymbol => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: semiBold,
        letterSpacing: 0.sp,
        height: 1.2.h,
      );

  // ===========================================================================
  // 8. الوسوم والبادجات والملاحظات (Chips, Badges, & Metadata)
  // ===========================================================================

  /// نصوص الشرائح والفلترة (Filter Chips)
  static TextStyle get chipText => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.sp,
        fontWeight: medium,
        letterSpacing: 0.sp,
        height: 1.2.h,
      );

  /// شارات الحالة (Badges)
  static TextStyle get badgeText => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.sp,
        fontWeight: bold,
        letterSpacing: 0.2.sp,
        height: 1.15.h,
      );

  /// نصوص التواريخ والتوقيتات التوضيحية (Captions)
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: regular,
        letterSpacing: 0.2.sp,
        height: 1.35.h,
      );

  // ===========================================================================
  // 9. مولّد ثيم فلاتر الرسمي (Material 3 TextTheme Generator)
  // ===========================================================================

  /// يُحقن مباشرة داخل `ThemeData(textTheme: AppTypography.textTheme)`
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonLarge,
        labelMedium: buttonMedium,
        labelSmall: buttonSmall,
      );
}
