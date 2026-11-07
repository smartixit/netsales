import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// زر تبديل تفاعلي عالي الجودة ومخصص بالكامل (Enterprise CustomSwitch)
/// ودجت عام في lib/widgets/inputs/ قابل لإعادة الاستخدام في أي شاشة أو مشروع.
///
/// يدعم:
/// - حركة ناعمة ومحسوبة للمؤشر (Thumb) والمسار (Track) عبر [AppMotion].
/// - تفاعل نبضي عبر [CustomInteractiveBounce].
/// - ألوان مخصصة للحالة النشطة وغير النشطة للمسار والمؤشر.
/// - أيقونات اختيارية تظهر داخل المقبض (Thumb) حسب الحالة.
/// - دعم كامل لسمات التصميم المعتمدة (Light/Dark via context.colors).
/// - معايير إمكانية الوصول والتفاعل (Semantics).
class CustomSwitch extends StatelessWidget {
  /// الحالة الحالية للزر (مفعل / معطل)
  final bool value;

  /// دالة الاستدعاء عند تبديل الحالة
  final ValueChanged<bool>? onChanged;

  /// عرض الزر بالبكسل المنطقي (افتراضياً 48.0)
  final double width;

  /// ارتفاع الزر بالبكسل المنطقي (افتراضياً 28.0)
  final double height;

  /// قطر المقبض (Thumb) (افتراضياً 22.0)
  final double thumbSize;

  /// لون المسار عند التفعيل (الافتراضي colors.primary)
  final Color? activeTrackColor;

  /// لون المسار عند عدم التفعيل (الافتراضي colors.surfaceContainerHigh)
  final Color? inactiveTrackColor;

  /// لون المقبض عند التفعيل (الافتراضي colors.onPrimary)
  final Color? activeThumbColor;

  /// لون المقبض عند عدم التفعيل (الافتراضي colors.outline)
  final Color? inactiveThumbColor;

  /// أيقونة اختيارية داخل المقبض عند التفعيل
  final IconData? activeIcon;

  /// أيقونة اختيارية داخل المقبض عند عدم التفعيل
  final IconData? inactiveIcon;

  /// لون الأيقونة داخل المقبض عند التفعيل
  final Color? activeIconColor;

  /// لون الأيقونة داخل المقبض عند عدم التفعيل
  final Color? inactiveIconColor;

  /// هل الزر مفعل للتفاعل أم معطل
  final bool enabled;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 48.0,
    this.height = 28.0,
    this.thumbSize = 22.0,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.activeIcon,
    this.inactiveIcon,
    this.activeIconColor,
    this.inactiveIconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectiveActiveTrack = activeTrackColor ?? colors.primary;
    final effectiveInactiveTrack =
        inactiveTrackColor ?? colors.surfaceContainerHighest;

    final effectiveActiveThumb = activeThumbColor ?? colors.onPrimary;
    final effectiveInactiveThumb = inactiveThumbColor ?? colors.surface;

    final effectiveActiveIconColor = activeIconColor ?? colors.primary;
    final effectiveInactiveIconColor =
        inactiveIconColor ?? colors.onSurfaceVariant;

    final trackColor = enabled
        ? (value ? effectiveActiveTrack : effectiveInactiveTrack)
        : (value
              ? effectiveActiveTrack.withValues(alpha: 0.5)
              : effectiveInactiveTrack.withValues(alpha: 0.5));

    final thumbColor = enabled
        ? (value ? effectiveActiveThumb : effectiveInactiveThumb)
        : colors.outlineVariant;

    final icon = value ? activeIcon : inactiveIcon;
    final iconColor = value
        ? effectiveActiveIconColor
        : effectiveInactiveIconColor;

    final padding = (height - thumbSize) / 2.0;

    final switchWidget = Semantics(
      toggled: value,
      enabled: enabled,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        width: width.w,
        height: height.h,
        padding: EdgeInsets.all(padding.r),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: value
                ? trackColor
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: value && enabled
              ? [
                  BoxShadow(
                    color: effectiveActiveTrack.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize.r,
            height: thumbSize.r,
            decoration: BoxDecoration(
              color: thumbColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: icon != null
                ? Center(
                    child: Icon(
                      icon,
                      size: (thumbSize * 0.65).r,
                      color: iconColor,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );

    if (!enabled || onChanged == null) {
      return switchWidget;
    }

    return CustomInteractiveBounce(
      onTap: () => onChanged!(!value),
      child: switchWidget,
    );
  }
}
