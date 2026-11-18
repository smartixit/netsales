import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// شريط ملخص مؤشرات حالات الطلبات التفاعلي (Orders KPI Summary Strip - Executive Edition)
///
/// يعرض إجمالي الطلبات والحالات الخمس المعتمدة من الخادم:
/// (الكل، قيد المراجعة، معتمدة، مرفوضة، ملغية) مع استخدام الـ CustomSkeletonShimmer
/// ودعم النقر المباشر للتصفية السريعة والتمرير الأفقي الانسيابي.
class ProcurementOrdersSummaryStrip extends StatelessWidget {
  const ProcurementOrdersSummaryStrip({
    super.key,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    this.rejectedCount = 0,
    this.cancelledCount = 0,
    this.isLoading = false,
    this.isNetworkView = false,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int cancelledCount;
  final bool isLoading;
  final bool isNetworkView;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      _SummaryCardData(
        label: isNetworkView ? 'الطلبات الواردة' : 'إجمالي الطلبات',
        count: totalCount,
        statusValue: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      _SummaryCardData(
        label: isNetworkView ? 'بانتظار الاعتماد' : 'قيد المراجعة',
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
      _SummaryCardData(
        label: 'مرفوضة',
        count: rejectedCount,
        statusValue: 'REJECTED',
        icon: Icons.cancel_outlined,
        accentColor: colors.error,
      ),
      _SummaryCardData(
        label: 'ملغية',
        count: cancelledCount,
        statusValue: 'CANCELLED',
        icon: Icons.block_rounded,
        accentColor: colors.onSurfaceVariant,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) AppSpacing.hSm,
              _KpiSummaryCard(
                data: cards[i],
                isLoading: isLoading,
                isSelected: selectedStatus == cards[i].statusValue,
                onTap: onStatusTap != null
                    ? () => onStatusTap!(cards[i].statusValue)
                    : null,
              ),
            ],
          ],
        ),
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
