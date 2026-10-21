import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:pinput/pinput.dart';

/// ============================================================================
/// حقل إدخال رمز التحقق الموحد فائق المرونة (Enterprise Unified PIN/OTP Field)
/// ============================================================================
/// مدمج كلياً مع:
/// - مكتبة Pinput القياسية
/// - نظام ألوان وثيم NetSales (context.colors.*)
/// - flutter_screenutil (.w, .h, .r, .sp)
/// - دعم الـ RTL/LTR مع فرض اتجاه الأرقام من اليسار لليمين
class CustomPinField extends StatelessWidget {
  const CustomPinField({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.validator,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.boxWidth,
    this.boxHeight,
  });

  /// عدد خانات الرمز (افتراضياً 6 خانات)
  final int length;

  /// متحكم النص لحفظ وقراءة الرمز المدخل
  final TextEditingController? controller;

  /// عقدة التركيز
  final FocusNode? focusNode;

  /// دالة التحقق من صحة القيمة (مثل FormValidators.otpValidator)
  final String? Function(String?)? validator;

  /// رد النداء عند اكتمال إدخال كامل خانات الرمز
  final ValueChanged<String>? onCompleted;

  /// رد النداء عند كل تغيير في القيمة
  final ValueChanged<String>? onChanged;

  /// التركيز التلقائي عند فتح الواجهة
  final bool autofocus;

  /// حالة تفعيل الحقل
  final bool enabled;

  /// للقراءة فقط
  final bool readOnly;

  /// تمويه الرمز المدخل (مثل حقول PIN الحساسة)
  final bool obscureText;

  /// حرف التمويه
  final String obscuringCharacter;

  /// نمط الاهتزاز اللمسي الذكي
  final HapticFeedbackType hapticFeedbackType;

  /// نوع لوحة المفاتيح
  final TextInputType keyboardType;

  /// منسقات المدخلات
  final List<TextInputFormatter>? inputFormatters;

  /// عرض كل خانة مخصصة (إن لم تُحدد، يتم الاعتماد على القياس المتجاوب 48.w)
  final double? boxWidth;

  /// ارتفاع كل خانة مخصصة (إن لم يُحدد، يتم الاعتماد على القياس المتجاوب 54.h)
  final double? boxHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cellWidth = boxWidth ?? 48.w;
    final cellHeight = boxHeight ?? 54.h;

    final defaultPinTheme = PinTheme(
      width: cellWidth,
      height: cellHeight,
      textStyle: AppTypography.titleLarge.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: colors.primary,
          width: 2.w,
        ),
        color: colors.surface,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.6),
          width: 1.5.w,
        ),
        color: colors.surface,
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: colors.error,
          width: 1.5.w,
        ),
      ),
    );

    final disabledPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        disabledPinTheme: disabledPinTheme,
        hapticFeedbackType: hapticFeedbackType,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
        validator: validator,
        onCompleted: onCompleted,
        onChanged: onChanged,
      ),
    );
  }
}
