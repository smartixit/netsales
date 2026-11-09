import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// رقاقة الفلترة والاختيار الموحدة عالية الجودة (Enterprise CustomFilterChip)
/// ودجت عام في lib/widgets قابل للاستخدام في أي مشروع أو شاشة تتطلب فلترة أو اختياراً
class CustomFilterChip extends StatelessWidget {
  /// النص المعروض داخل الرقاقة
  final String label;

  /// هل الرقاقة محددة حالياً
  final bool isSelected;

  /// دالة الاستدعاء عند النقر أو تبديل التحديد
  final VoidCallback onSelected;

  /// أيقونة توضيحية اختيارية
  final IconData? icon;

  /// عداد اختياري يعرض بجانب النص (مثل عدد العناصر المطابقة)
  final int? count;

  /// تفعيل الحجم المصغر
  final bool isCompact;

  /// لون مخصص للتحديد (الافتراضي colors.primary)
  final Color? selectedColor;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
    this.count,
    this.isCompact = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = selectedColor ?? colors.primary;

    final horizontalPadding = isCompact ? AppSpacing.sm : AppSpacing.md;
    final verticalPadding = isCompact ? AppSpacing.xxs : AppSpacing.xs;

    return CustomInteractiveBounce(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? activeColor
                : colors.outlineVariant.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isCompact ? 14.r : 16.r,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              AppSpacing.hXs,
            ],
            Text(
              label,
              style: isCompact
                  ? AppTypography.labelSmall.copyWith(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    )
                  : AppTypography.labelMedium.copyWith(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
            ),
            if (count != null) ...[
              AppSpacing.hSm,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs / 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.onPrimary.withValues(alpha: 0.22)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.badgeText.copyWith(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
