import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/sms_retriever_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:pinput/pinput.dart';

export 'package:netsales/core/services/sms_retriever_service.dart';
export 'package:pinput/pinput.dart'
    show HapticFeedbackType, PinputAutovalidateMode, SmsRetriever;

/// ============================================================================
/// حقل إدخال رمز التحقق الموحد (Enterprise Unified PIN/OTP Field)
/// ============================================================================
/// مبني بدقة على نمط "Rounded With Shadows" القياسي المعتمد من حزمة Pinput الرسمية:
/// - حواف مستديرة انسيابية تتحول بحركة ناعمة عند التركيز
/// - ظلال عمق متكيفة بالكامل عبر AppElevation (دون ألوان أو أرقام سحرية)
/// - مؤشر سفلي أنيق (Bottom Indicator Cursor)
/// - دعم أصيل وشامل للتعبئة التلقائية (iOS OneTimeCode و Android SMS Autofill)
/// - توافق تام مع flutter_screenutil والاتجاه العربي RTL مع إدخال LTR للأرقام
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
    this.useShadows = true,
    this.showCursor = false,
    this.cursor,
    this.separatorBuilder,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.smsRetriever,
    this.enableSmsRetriever = true,
    this.closeKeyboardWhenCompleted = true,
    this.pinputAutovalidateMode = PinputAutovalidateMode.onSubmit,
    this.useNativeKeyboard = true,
  });

  /// عدد خانات الرمز (افتراضياً 6 خانات)
  final int length;

  /// متحكم النص لحفظ وقراءة الرمز المدخل
  final TextEditingController? controller;

  /// عقدة التركيز
  final FocusNode? focusNode;

  /// دالة التحقق من صحة القيمة
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

  /// عرض كل خانة مخصصة (إن لم يُحدد، يتكيف تلقائياً مع حجم الشاشة وعدد الخانات)
  final double? boxWidth;

  /// ارتفاع كل خانة مخصصة (إن لم يُحدد، يعتمد 58.h افتراضياً)
  final double? boxHeight;

  /// تفعيل الظلال لنمط "Rounded With Shadows"
  final bool useShadows;

  /// إظهار المؤشر
  final bool showCursor;

  /// مؤشر مخصص
  final Widget? cursor;

  /// فاصل مخصص بين الخانات
  final Widget Function(int index)? separatorBuilder;

  /// إشارات التعبئة التلقائية للوحة المفاتيح ونظام التشغيل (iOS/Android OTP Autofill)
  final Iterable<String>? autofillHints;

  /// كائن استخراج الرمز التلقائي من رسائل SMS على أندرويد
  final SmsRetriever? smsRetriever;

  /// التفعيل التلقائي للاستماع للرمز عبر SMS Retriever API على منصة Android
  final bool enableSmsRetriever;

  /// إغلاق لوحة المفاتيح تلقائياً فور اكتمال الرمز
  final bool closeKeyboardWhenCompleted;

  /// نمط التحقق التلقائي
  final PinputAutovalidateMode pinputAutovalidateMode;

  /// استخدام لوحة المفاتيح الأصلية للنظام (true) أو الاعتماد على لوحة مفاتيح رقمية مخصصة (false)
  final bool useNativeKeyboard;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // احتساب أبعاد الخانات بما يضمن عدم حدوث تجاوز في الشاشات الصغيرة
    final defaultWidth = length <= 4 ? 60.w : 48.w;
    final cellWidth = boxWidth ?? defaultWidth;
    final cellHeight = boxHeight ?? 58.h;

    // 1. الثيم الافتراضي: نمط Rounded With Shadows
    final defaultPinTheme = PinTheme(
      width: cellWidth,
      height: cellHeight,
      textStyle: AppTypography.titleLarge.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.w,
        ),
        boxShadow: useShadows ? AppElevation.level1(context) : null,
      ),
    );

    // 2. ثيم الخانة المركّز عليها: تحول الحواف المستديرة إلى حواف أصغر مع الظل البارز كما في Pinput الرسمي
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
        border: Border.all(
          color: colors.primary,
          width: 2.w,
        ),
        boxShadow: useShadows
            ? [
                ...AppElevation.level2(context),
                ...AppElevation.glow(context, colors.primary, blur: 12.r, alpha: 0.18),
              ]
            : null,
      ),
    );

    // 3. ثيم الخانة المكتملة (Submitted Pin Theme)
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.6),
          width: 1.5.w,
        ),
        boxShadow: useShadows ? AppElevation.level1(context) : null,
      ),
    );

    // 4. ثيم حالة الخطأ
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(
          color: colors.error,
          width: 1.5.w,
        ),
        boxShadow: useShadows
            ? AppElevation.glow(context, colors.error, blur: 10.r, alpha: 0.2)
            : null,
      ),
    );

    // 5. ثيم الحقل المعطل
    final disabledPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: null,
      ),
    );

    // مؤشر الكتابة السفلي الأنيق المطابق لنموذج Rounded With Shadows
    final effectiveCursor = cursor ??
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 20.w,
            height: 2.h,
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
            ),
          ),
        );

    // استخراج أو تهيئة مستمع الرسائل التلقائي على أندرويد
    final effectiveSmsRetriever = smsRetriever ??
        (enableSmsRetriever &&
                !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.android
            ? SmsRetrieverService.instance.createRetriever()
            : null);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        useNativeKeyboard: useNativeKeyboard,
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
        showCursor: showCursor,
        cursor: effectiveCursor,
        isCursorAnimationEnabled: true,
        closeKeyboardWhenCompleted: closeKeyboardWhenCompleted,
        pinputAutovalidateMode: pinputAutovalidateMode,
        autofillHints: autofillHints,
        smsRetriever: effectiveSmsRetriever,
        separatorBuilder: separatorBuilder ??
            (index) => SizedBox(width: AppSpacing.xs),
      ),
    );
  }
}
