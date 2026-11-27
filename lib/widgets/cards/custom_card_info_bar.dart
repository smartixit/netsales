import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عنصر بيانات واحد يظهر داخل شريط المعلومات الغائر للبطاقة التنفيذية.
class CustomCardInfoItem {
  const CustomCardInfoItem({
    required this.icon,
    required this.text,
    this.onTap,
    this.showCopyIcon = false,
    this.color,
    this.isMonospace = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool showCopyIcon;
  final Color? color;
  final bool isMonospace;
}

/// شريط معلومات غائر وموحّد داخل البطاقات لعرض التواريخ والمعرفات وعناوين الشبكة.
class CustomCardInfoBar extends StatelessWidget {
  const CustomCardInfoBar({
    super.key,
    required this.items,
    this.isCompact = false,
  });

  final List<CustomCardInfoItem> items;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final validItems =
        items.where((i) => i.text.trim().isNotEmpty).toList(growable: false);

    if (validItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2.w,
        vertical: AppSpacing.xs + 3.h,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < validItems.length; i++) ...[
                  if (i > 0) SizedBox(height: 5.h),
                  _InfoBarEntry(item: validItems[i]),
                ],
              ],
            )
          : Row(
              children: [
                for (int i = 0; i < validItems.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 14.h,
                      width: 1,
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  Expanded(child: _InfoBarEntry(item: validItems[i])),
                ],
              ],
            ),
    );
  }
}

class _InfoBarEntry extends StatelessWidget {
  const _InfoBarEntry({required this.item});

  final CustomCardInfoItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = item.color ?? colors.primary;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 14.sp, color: iconColor),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            item.text,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.onTap != null && item.showCopyIcon) ...[
          SizedBox(width: 4.w),
          Icon(
            Icons.copy_rounded,
            size: 12.sp,
            color: colors.onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ],
      ],
    );

    if (item.onTap == null) return row;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: row,
    );
  }
}
