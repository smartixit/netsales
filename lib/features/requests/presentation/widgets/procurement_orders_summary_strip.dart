import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_kpi_summary_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_card_data.dart';

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
      ProcurementOrdersSummaryCardData(
        label: isNetworkView ? 'الطلبات الواردة' : 'إجمالي الطلبات',
        count: totalCount,
        statusValue: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      ProcurementOrdersSummaryCardData(
        label: isNetworkView ? 'بانتظار الاعتماد' : 'قيد المراجعة',
        count: pendingCount,
        statusValue: 'PENDING',
        icon: Icons.hourglass_top_rounded,
        accentColor: colors.warning,
      ),
      ProcurementOrdersSummaryCardData(
        label: 'معتمدة',
        count: approvedCount,
        statusValue: 'APPROVED',
        icon: Icons.check_circle_rounded,
        accentColor: colors.success,
      ),
      ProcurementOrdersSummaryCardData(
        label: 'مرفوضة',
        count: rejectedCount,
        statusValue: 'REJECTED',
        icon: Icons.cancel_outlined,
        accentColor: colors.error,
      ),
      ProcurementOrdersSummaryCardData(
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
              ProcurementOrdersKpiSummaryCard(
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
