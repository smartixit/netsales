import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// شريط ملخص مؤشرات حالات الطلبات (Orders KPI Summary Strip - Executive Edition)
///
/// يعرض إجمالي الطلبات، والطلبات قيد المراجعة، والطلبات المعتمدة مع استخدام
/// الـ CustomSkeletonShimmer الموحد للنصوص أثناء التحميل ودعم النقر للتصفية السريعة.
class PosProcurementOrdersSummaryStrip extends StatelessWidget {
  const PosProcurementOrdersSummaryStrip({
    super.key,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    this.isLoading = false,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final bool isLoading;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      _SummaryCardData(
        label: 'إجمالي الطلبات',
        count: totalCount,
        statusValue: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      _SummaryCardData(
        label: 'قيد المراجعة',
        count: pendingCount,
        statusValue: 'PENDING',
        icon: Icons.hourglass_top_rounded,
        accentColor: colors.warning,
      ),
      _SummaryCardData(
        label: 'معتمدة',
        count: approvedCount,
        statusValue: 'APPROVED',
        icon: Icons.check_circle_rounded,
        accentColor: colors.success,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) AppSpacing.hSm,
            Expanded(
              child: _KpiSummaryCard(
                data: cards[i],
                isLoading: isLoading,
                isSelected: selectedStatus == cards[i].statusValue,
                onTap: onStatusTap != null
                    ? () => onStatusTap!(cards[i].statusValue)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.count,
    required this.statusValue,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final int count;
  final String? statusValue;
  final IconData icon;
  final Color accentColor;
}

class _KpiSummaryCard extends StatelessWidget {
  const _KpiSummaryCard({
    required this.data,
    required this.isLoading,
    required this.isSelected,
    this.onTap,
  });

  final _SummaryCardData data;
  final bool isLoading;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 12.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? data.accentColor
                : colors.outlineVariant.withValues(alpha: .5),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? data.accentColor.withValues(alpha: .12)
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
              children: [
                Icon(data.icon, size: 16.r, color: data.accentColor),
                AppSpacing.hXxs,
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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
                  height: 22.h,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              )
            else
              Text(
                '${data.count}',
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
