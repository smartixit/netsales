import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/sms_retriever_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:pinput/pinput.dart';

export 'package:netsales/core/services/sms_retriever_service.dart';
export 'package:pinput/pinput.dart'
    show HapticFeedbackType, PinputAutovalidateMode, SmsRetriever;

/// ============================================================================
/// حقل إدخال رمز التحقق المؤسسي الموحد (Enterprise Unified PIN/OTP Field)
/// ============================================================================
/// مصمم وفق أرقى معايير التطبيقات العالمية الرائدة (Apple, Stripe, Telegram):
/// 1. ثبات هندسي مطلق للحواف المستديرة (منع التشوه أو القفز البصري عند التركيز).
/// 2. تجميع الخانات بنمط (3 - 3 Chunking) مع فاصل انسيابي ناعم لتسهيل القراءة.
/// 3. اهتزاز فيزيائي ذكي عند الخطأ (Physics-based Horizontal Error Shake + Haptic).
/// 4. مؤشر كتابة نابض وأنيق (Blinking Cursor).
/// 5. تكامل أصيل ومباشر مع كيبورد النظام وخدمات استخراج الرمز التلقائي (iOS / Android SMS Autofill).
class CustomPinField extends StatefulWidget {
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
    this.showCursor = true,
    this.cursor,
    this.separatorBuilder,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.smsRetriever,
    this.enableSmsRetriever = true,
    this.closeKeyboardWhenCompleted = true,
    this.pinputAutovalidateMode = PinputAutovalidateMode.onSubmit,
    this.useNativeKeyboard = true,
  });

  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final String obscuringCharacter;
  final HapticFeedbackType hapticFeedbackType;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double? boxWidth;
  final double? boxHeight;
  final bool useShadows;
  final bool showCursor;
  final Widget? cursor;
  final Widget Function(int index)? separatorBuilder;
  final Iterable<String>? autofillHints;
  final SmsRetriever? smsRetriever;
  final bool enableSmsRetriever;
  final bool closeKeyboardWhenCompleted;
  final PinputAutovalidateMode pinputAutovalidateMode;
  final bool useNativeKeyboard;

  @override
  State<CustomPinField> createState() => CustomPinFieldState();
}

class CustomPinFieldState extends State<CustomPinField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;
  late final String? Function(String?) _wrappedValidator;
  bool _hadError = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );

    _shakeAnimation = _shakeController.drive(
      TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-8, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-8, 0), end: const Offset(8, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(8, 0), end: const Offset(-6, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-6, 0), end: const Offset(6, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(6, 0), end: const Offset(-3, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(-3, 0), end: const Offset(3, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: const Offset(3, 0), end: Offset.zero),
          weight: 1,
        ),
      ]),
    );

    _wrappedValidator = (value) {
      final error = widget.validator?.call(value);
      if (error != null && !_hadError) {
        shake();
      }
      _hadError = error != null;
      return error;
    };
  }

  /// إطلاق حركة الاهتزاز الفيزيائي اللمسي عند حدوث خطأ
  void shake() {
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // أبعاد الخانات المتجاوبة بدقة مع إمكانية استيعاب فاصل الـ 3-3 دون طفحان
    final defaultWidth = widget.length <= 4 ? 60.w : 46.w;
    final cellWidth = widget.boxWidth ?? defaultWidth;
    final cellHeight = widget.boxHeight ?? 56.h;
    final cellRadius = BorderRadius.circular(AppRadius.md);

    // 1. الثيم الافتراضي: حواف مستقرة وألوان نقية
    final defaultPinTheme = PinTheme(
      width: cellWidth,
      height: cellHeight,
      textStyle: AppTypography.titleLarge.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: cellRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.2.w,
        ),
        boxShadow: widget.useShadows ? AppElevation.level1(context) : null,
      ),
    );

    // 2. ثيم الخانة المركّز عليها: نفس الحواف المستديرة بدون أي تشوه مع توهج هادئ
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: cellRadius,
        border: Border.all(
          color: colors.primary,
          width: 1.8.w,
        ),
        boxShadow: widget.useShadows
            ? [
                ...AppElevation.level1(context),
                ...AppElevation.glow(context, colors.primary, blur: 8.r, alpha: 0.15),
              ]
            : null,
      ),
    );

    // 3. ثيم الخانة المكتملة
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: cellRadius,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.5),
          width: 1.4.w,
        ),
        boxShadow: widget.useShadows ? AppElevation.level1(context) : null,
      ),
    );

    // 4. ثيم حالة الخطأ: توهج أحمر خفيف وحواف ثابتة
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        borderRadius: cellRadius,
        border: Border.all(
          color: colors.error,
          width: 1.8.w,
        ),
        boxShadow: widget.useShadows
            ? AppElevation.glow(context, colors.error, blur: 8.r, alpha: 0.2)
            : null,
      ),
    );

    // 5. ثيم الحقل المعطل
    final disabledPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: cellRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: null,
      ),
    );

    // مؤشر الكتابة النابض كالتطبيقات العالمية
    final effectiveCursor = widget.cursor ??
        Center(
          child: Container(
            width: 2.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        );

    // استخراج أو تهيئة مستمع الرسائل التلقائي على أندرويد
    final effectiveSmsRetriever = widget.smsRetriever ??
        (widget.enableSmsRetriever &&
                !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.android
            ? SmsRetrieverService.instance.createRetriever()
            : null);

    // بناء فاصل التجميع 3 - 3 الذكي
    Widget defaultSeparatorBuilder(int index) {
      if (widget.length == 6 && index == 2) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Center(
            child: Container(
              width: 8.w,
              height: 2.5.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        );
      }
      return SizedBox(width: AppSpacing.xxs);
    }

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _shakeAnimation.value,
          child: child,
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          length: widget.length,
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          useNativeKeyboard: widget.useNativeKeyboard,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          disabledPinTheme: disabledPinTheme,
          hapticFeedbackType: widget.hapticFeedbackType,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters ??
              [FilteringTextInputFormatter.digitsOnly],
          validator: _wrappedValidator,
          onCompleted: widget.onCompleted,
          onChanged: widget.onChanged,
          showCursor: widget.showCursor,
          cursor: effectiveCursor,
          isCursorAnimationEnabled: true,
          closeKeyboardWhenCompleted: widget.closeKeyboardWhenCompleted,
          pinputAutovalidateMode: widget.pinputAutovalidateMode,
          autofillHints: widget.autofillHints,
          smsRetriever: effectiveSmsRetriever,
          separatorBuilder: widget.separatorBuilder ?? defaultSeparatorBuilder,
        ),
      ),
    );
  }
}
