import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// عنصر تبديل متكامل وعالي الجودة قابل لإعادة الاستخدام (Enterprise CustomSwitchListTile)
/// ودجت عام في lib/widgets يمكن استخدامه في أي شاشة أو مشروع لإدارة الحالات التبديلية (On/Off)
class CustomSwitchListTile extends StatelessWidget {
  /// العنوان الرئيسي
  final String title;

  /// الوصف التوضيحي الثانوي
  final String? subtitle;

  /// القيمة الحالية للزر التبديل
  final bool value;

  /// دالة الاستدعاء عند تغيير الحالة
  final ValueChanged<bool>? onChanged;

  /// أيقونة بادئة رئيسية
  final IconData? icon;

  /// أيقونة خاصة بالحالة النشطة (تأخذ الأولوية عند value == true)
  final IconData? activeIcon;

  /// أيقونة خاصة بالحالة غير النشطة (تأخذ الأولوية عند value == false)
  final IconData? inactiveIcon;

  /// لون مؤشر التفعيل المخصص (الافتراضي colors.primary)
  final Color? activeColor;

  /// تفعيل أو تعطيل التفاعل بالكامل
  final bool enabled;

  /// حشوة داخلية مخصصة
  final EdgeInsetsGeometry? contentPadding;

  const CustomSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.activeIcon,
    this.inactiveIcon,
    this.activeColor,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveActiveColor = activeColor ?? colors.primary;

    final resolvedIcon = value
        ? (activeIcon ?? icon)
        : (inactiveIcon ?? icon);

    final resolvedIconColor = value
        ? effectiveActiveColor
        : colors.onSurfaceVariant;

    final tileContent = Container(
      padding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: value
              ? effectiveActiveColor.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (resolvedIcon != null) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: resolvedIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                resolvedIcon,
                color: resolvedIconColor,
                size: 20.r,
              ),
            ),
            AppSpacing.hSm,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: enabled ? colors.onSurface : colors.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: enabled
                          ? colors.onSurfaceVariant
                          : colors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.hSm,
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: effectiveActiveColor,
          ),
        ],
      ),
    );

    if (!enabled || onChanged == null) {
      return tileContent;
    }

    return CustomInteractiveBounce(
      onTap: () => onChanged!(!value),
      child: tileContent,
    );
  }
}
