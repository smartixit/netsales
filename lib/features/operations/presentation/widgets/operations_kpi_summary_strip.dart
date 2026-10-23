import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

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
            child: CustomKpiCard.compact(
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
            child: CustomKpiCard.compact(
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
            child: CustomKpiCard.compact(
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

