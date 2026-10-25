import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// لوحة المفاتيح الرقمية المدمجة الموحدة (Custom Numeric Keyboard)
/// ============================================================================
/// مستوحاة من كبرى التطبيقات المالية والمصرفية العالمية (Revolut, STC Pay, Binance):
/// - مظهر أنيق انسيابي يتناغم تلقائياً مع نظام الألوان الموحد والوضعين الفاتح والداكن
/// - حركة فيزيائية ناعمة واستجابة لمسية ذكية (Haptic Feedback) لكل ضغطة
/// - تحكم برمجي مباشر في متحكم النص (TextEditingController) دون استدعاء كيبورد النظام
/// - متوافقة 100% مع flutter_screenutil وميثاق منع الألوان والأرقام السحرية
class CustomNumericKeyboard extends StatelessWidget {
  const CustomNumericKeyboard({
    super.key,
    this.controller,
    this.maxLength = 6,
    this.onChanged,
    this.onCompleted,
    this.onToggleKeyboard,
    this.leftActionWidget,
    this.enableHapticFeedback = true,
    this.keyWidth,
    this.keyHeight,
  });

  /// متحكم النص المرتبط بحقل الرمز
  final TextEditingController? controller;

  /// الحد الأقصى لعدد الخانات (افتراضياً 6)
  final int maxLength;

  /// رد النداء عند كل تغيير في القيمة
  final ValueChanged<String>? onChanged;

  /// رد النداء فور اكتمال إدخال كامل الخانات
  final ValueChanged<String>? onCompleted;

  /// رد النداء عند النقر على زر التبديل إلى لوحة مفاتيح النظام
  final VoidCallback? onToggleKeyboard;

  /// ودجت مخصص للزر السفلي الأيسر (بديل لزر التبديل)
  final Widget? leftActionWidget;

  /// تفعيل ردود الفعل اللمسية (الاهتزاز الناعم)
  final bool enableHapticFeedback;

  /// عرض الزر المخصص (إن لم يُحدد، يعتمد 74.w)
  final double? keyWidth;

  /// ارتفاع الزر المخصص (إن لم يُحدد، يعتمد 54.h)
  final double? keyHeight;

  void _handleDigitTap(String digit) {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    final text = controller?.text ?? '';
    if (text.length < maxLength) {
      final newText = text + digit;
      controller?.text = newText;
      onChanged?.call(newText);
      if (newText.length == maxLength) {
        if (enableHapticFeedback) {
          HapticFeedback.mediumImpact();
        }
        onCompleted?.call(newText);
      }
    }
  }

  void _handleDelete() {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    final text = controller?.text ?? '';
    if (text.isNotEmpty) {
      final newText = text.substring(0, text.length - 1);
      controller?.text = newText;
      onChanged?.call(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKeyWidth = keyWidth ?? 74.w;
    final effectiveKeyHeight = keyHeight ?? 54.h;

    // تثبيت الاتجاه LTR لضمان الترتيب القياسي للوحة المفاتيح (1 2 3) عالمياً
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 320.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصف الأول: 1 - 2 - 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NumericKey(
                    digit: '1',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('1'),
                  ),
                  _NumericKey(
                    digit: '2',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('2'),
                  ),
                  _NumericKey(
                    digit: '3',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('3'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // الصف الثاني: 4 - 5 - 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NumericKey(
                    digit: '4',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('4'),
                  ),
                  _NumericKey(
                    digit: '5',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('5'),
                  ),
                  _NumericKey(
                    digit: '6',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('6'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // الصف الثالث: 7 - 8 - 9
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NumericKey(
                    digit: '7',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('7'),
                  ),
                  _NumericKey(
                    digit: '8',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('8'),
                  ),
                  _NumericKey(
                    digit: '9',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('9'),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // الصف الرابع: إجراء سفلي - 0 - حذف
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // الزر الأيسر: تبديل الكيبورد أو إجراء مخصص
                  leftActionWidget ??
                      (onToggleKeyboard != null
                          ? _ActionKey(
                              width: effectiveKeyWidth,
                              height: effectiveKeyHeight,
                              icon: Icons.keyboard_outlined,
                              tooltip: 'استخدام لوحة مفاتيح النظام',
                              onTap: onToggleKeyboard!,
                            )
                          : SizedBox(
                              width: effectiveKeyWidth,
                              height: effectiveKeyHeight,
                            )),

                  // رقم الصفر: 0
                  _NumericKey(
                    digit: '0',
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    onTap: () => _handleDigitTap('0'),
                  ),

                  // زر الحذف: Backspace ⌫
                  _ActionKey(
                    width: effectiveKeyWidth,
                    height: effectiveKeyHeight,
                    icon: Icons.backspace_outlined,
                    tooltip: 'حذف',
                    onTap: _handleDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر رقمي ذري مستقل ومغلف بالارتداد الفيزيائي (_NumericKey)
class _NumericKey extends StatelessWidget {
  const _NumericKey({
    required this.digit,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final String digit;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            width: 1.w,
          ),
          boxShadow: AppElevation.level0(context),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTypography.headlineMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// زر إجرائي ذري مستقل ومغلف بالارتداد الفيزيائي (_ActionKey)
class _ActionKey extends StatelessWidget {
  const _ActionKey({
    required this.width,
    required this.height,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final double width;
  final double height;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: tooltip,
      child: CustomInteractiveBounce(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.15),
              width: 1.w,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22.r,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
