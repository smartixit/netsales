import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

/// ============================================================================
/// شريط السيولة والنبض المالي الرشيق (OperationsKpiSummaryStrip)
/// ============================================================================
/// يعتمد حصرياً على الودجت القياسي الموحد [CustomKpiCard.compact] لعرض مؤشرات
/// المبيعات والسيولة النقدية ومسار التوريد طبقاً لميثاق الكود النظيف.
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

      if (isInvoiceTab) {
        return Row(
          children: [
            Expanded(
              child: CustomKpiCard.compact(
                title: 'إجمالي المبيعات',
                value: AmountFormatter.formatValue(controller.totalInvoicesAmount),
                unit: 'ر.ي',
                icon: Icons.payments_outlined,
                iconColor: colors.primary,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomKpiCard.compact(
                title: 'الآجل القائم',
                value: AmountFormatter.formatValue(
                  controller.unpaidRemainingAmount,
                ),
                unit: 'ر.ي',
                icon: Icons.pending_actions_rounded,
                iconColor: controller.unpaidRemainingAmount > 0
                    ? colors.warning
                    : colors.primary,
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: CustomKpiCard.compact(
              title: 'بانتظار القرار',
              value: controller.pendingRequestsCount.toString(),
              unit: 'طلب',
              icon: Icons.hourglass_top_rounded,
              iconColor: controller.pendingRequestsCount > 0
                  ? colors.warning
                  : colors.primary,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: CustomKpiCard.compact(
              title: 'طلبات معتمدة',
              value: controller.approvedRequestsCount.toString(),
              unit: 'طلب',
              icon: Icons.check_circle_outline_rounded,
              iconColor: colors.primary,
            ),
          ),
        ],
      );
    });
  }
}
