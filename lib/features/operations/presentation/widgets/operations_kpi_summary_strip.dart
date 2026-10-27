import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';

/// ============================================================================
/// شريط السيولة والنبض المالي الرشيق (OperationsKpiSummaryStrip)
/// ============================================================================
/// كبسولة أفقية مدمجة ومنخفضة الارتفاع (~42dp) توفر قراءة فورية للسيولة اليومية
/// ومسار التوريد دون استهلاك مساحة الشاشة الرأسية أو إجهاد العين.
class OperationsKpiSummaryStrip extends StatelessWidget {
  final OperationsController controller;

  const OperationsKpiSummaryStrip({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isInvoiceTab = controller.activeSegmentIndex.value == 0;

      return Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.22),
            width: 0.8.w,
          ),
        ),
        child: isInvoiceTab
            ? _InvoicesSlimPulse(controller: controller)
            : _RequestsSlimPulse(controller: controller),
      );
    });
  }
}

class _InvoicesSlimPulse extends StatelessWidget {
  final OperationsController controller;

  const _InvoicesSlimPulse({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalSales = controller.totalInvoicesAmount;
    final unpaidRemaining = controller.unpaidRemainingAmount;

    return Row(
      children: [
        // 1. إجمالي مبيعات التداول
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: colors.primary,
                  size: 16.r,
                ),
                AppSpacing.hXxs,
                Text(
                  'المبيعات: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '${AmountFormatter.formatValue(totalSales)} ر.ي',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // فاصل عمودي ناعم
        Container(
          width: 1.w,
          height: 18.h,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),

        // 2. الآجل القائم (المديونية)
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions_rounded,
                  color: unpaidRemaining > 0 ? colors.warning : colors.primary,
                  size: 15.r,
                ),
                AppSpacing.hXxs,
                Text(
                  'الآجل القائم: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '${AmountFormatter.formatValue(unpaidRemaining)} ر.ي',
                  style: AppTypography.labelSmall.copyWith(
                    color: unpaidRemaining > 0 ? colors.warning : colors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestsSlimPulse extends StatelessWidget {
  final OperationsController controller;

  const _RequestsSlimPulse({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pendingCount = controller.pendingRequestsCount;
    final approvedCount = controller.approvedRequestsCount;

    return Row(
      children: [
        // 1. الطلبات بانتظار القرار
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Container(
                  width: 7.r,
                  height: 7.r,
                  decoration: BoxDecoration(
                    color: pendingCount > 0 ? colors.warning : colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.hXxs,
                Text(
                  'بانتظار القرار: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '$pendingCount طلب',
                  style: AppTypography.labelSmall.copyWith(
                    color: pendingCount > 0 ? colors.warning : colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        // فاصل عمودي ناعم
        Container(
          width: 1.w,
          height: 18.h,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),

        // 2. المعتمدة
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  color: colors.primary,
                  size: 15.r,
                ),
                AppSpacing.hXxs,
                Text(
                  'معتمدة: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '$approvedCount من ${controller.requests.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
