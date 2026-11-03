import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// رقاقة العرض الحيادية الموحدة (Enterprise Neutral Chip)
/// مخصصة لعرض التصنيفات، أنواع الأجهزة، الأدوار، والنطاقات دون ألوان تحذيرية مضللة
class CustomChip extends StatelessWidget {
  /// النص المعروض
  final String label;

  /// أيقونة بادئة اختيارية
  final IconData? icon;

  /// استدعاء تفاعلي عند النقر
  final VoidCallback? onTap;

  /// استدعاء تفاعلي عند الحذف/الإلغاء
  final VoidCallback? onDeleted;

  /// وضع الكثافة المصغرة
  final bool isCompact;

  const CustomChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDeleted,
    this.isCompact = false,
  });

  /// إنشاء رقاقة من كائن العرض الدلالي
  factory CustomChip.fromPresentation(
    EnumPresentation presentation, {
    Key? key,
    VoidCallback? onTap,
    VoidCallback? onDeleted,
    bool isCompact = false,
  }) {
    return CustomChip(
      key: key,
      label: presentation.label,
      icon: presentation.icon,
      onTap: onTap,
      onDeleted: onDeleted,
      isCompact: isCompact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final horizontalPadding = isCompact ? 8.w : 10.w;
    final verticalPadding = isCompact ? 3.h : 4.h;
    final iconSize = isCompact ? 13.r : 15.r;
    final textStyle = isCompact
        ? AppTypography.badgeText.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          )
        : AppTypography.labelSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          );

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: colors.onSurfaceVariant),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDeleted != null) ...[
            SizedBox(width: 4.w),
            CustomButton.icon(
              icon: Icons.close_rounded,
              iconSize: 12.r,
              dimension: 18.r,
              backgroundColor: Colors.transparent,
              tooltip: 'إزالة',
              onPressed: onDeleted,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return CustomInteractiveBounce(onTap: onTap, child: content);
    }

    return content;
  }
}
