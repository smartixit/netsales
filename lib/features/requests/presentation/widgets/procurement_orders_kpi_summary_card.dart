import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_card_data.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class ProcurementOrdersKpiSummaryCard extends StatelessWidget {
  const ProcurementOrdersKpiSummaryCard({
    super.key,
    required this.data,
    required this.isLoading,
    required this.isSelected,
    this.onTap,
  });

  final ProcurementOrdersSummaryCardData data;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        constraints: BoxConstraints(minWidth: 106.w),
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
        decoration: BoxDecoration(
          color: isSelected
              ? data.accentColor.withValues(alpha: .08)
              : colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? data.accentColor
                : colors.outlineVariant.withValues(alpha: .5),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? data.accentColor.withValues(alpha: .14)
                  : Colors.black.withValues(alpha: .03),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, size: 15.r, color: data.accentColor),
                AppSpacing.hXxs,
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? data.accentColor
                          : colors.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vXs,
            if (isLoading)
              CustomSkeletonShimmer(
                child: Container(
                  width: 36.w,
                  height: 20.h,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${data.count}',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
