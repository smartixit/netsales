import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';

/// ============================================================================
/// شريط المؤشرات السريعة للعمليات (OperationsKpiSummaryStrip)
/// ============================================================================
/// يعرض ثلاثة مؤشرات حيوية موجزة: إجمالي المبيعات، المتبقي الآجل، والطلبات المعلقة.
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
      final totalSales = controller.totalInvoicesAmount;
      final unpaidCredit = controller.unpaidRemainingAmount;
      final pendingCount = controller.pendingRequestsCount;

      return Row(
        children: [
          // 1. إجمالي المبيعات
          Expanded(
            child: _MiniKpiCard(
              title: 'إجمالي المبيعات',
              value: AmountFormatter.formatValue(totalSales),
              unit: 'ر.ي',
              icon: Icons.payments_outlined,
              iconColor: colors.primary,
            ),
          ),

          AppSpacing.hSm,

          // 2. المديونية المعلقة
          Expanded(
            child: _MiniKpiCard(
              title: 'المديونية (الآجل)',
              value: AmountFormatter.formatValue(unpaidCredit),
              unit: 'ر.ي',
              icon: Icons.pending_actions_outlined,
              iconColor: unpaidCredit > 0 ? colors.warning : colors.onSurfaceVariant,
            ),
          ),

          AppSpacing.hSm,

          // 3. الطلبات المعلقة
          Expanded(
            child: _MiniKpiCard(
              title: 'طلبات معلقة',
              value: pendingCount.toString(),
              unit: 'طلب',
              icon: Icons.assignment_late_outlined,
              iconColor: pendingCount > 0 ? colors.error : colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    });
  }
}

class _MiniKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const _MiniKpiCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16.r,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  unit,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
