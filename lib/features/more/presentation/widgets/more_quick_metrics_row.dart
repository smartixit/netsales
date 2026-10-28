import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_support_summary_entity.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

/// ============================================================================
/// شريط المؤشرات السريعة التنفيذية لقطاع المزيد (MoreQuickMetricsRow)
/// ============================================================================
/// يعرض ثلاثة مؤشرات مصغرة للمصروفات، سريان اشتراك المنشأة، وتذاكر الدعم المفتوحة.
class MoreQuickMetricsRow extends StatelessWidget {
  final double totalExpenses;
  final MoreSubscriptionEntity? subscription;
  final MoreSupportSummaryEntity? support;

  const MoreQuickMetricsRow({
    super.key,
    required this.totalExpenses,
    required this.subscription,
    required this.support,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final openTickets = support?.openTicketsCount ?? 0;
    final daysRemaining = subscription?.daysRemaining ?? 30;

    return Row(
      children: [
        // 1. مصروفات الشهر التشغيلية
        Expanded(
          child: CustomKpiCard.compact(
            title: 'مصروفات الشهر',
            value: AmountFormatter.formatValue(totalExpenses, decimalPlaces: 0),
            unit: 'ر.ي',
            icon: Icons.payments_rounded,
            iconColor: colors.primary,
          ),
        ),

        AppSpacing.hSm,

        // 2. سريان اشتراك المنشأة
        Expanded(
          child: CustomKpiCard.compact(
            title: 'اشتراك المنشأة',
            value: '$daysRemaining',
            unit: 'يوم متبقٍ',
            icon: Icons.event_available_rounded,
            iconColor: daysRemaining > 5 ? colors.success : colors.warning,
          ),
        ),

        AppSpacing.hSm,

        // 3. تذاكر الدعم والمساعدة
        Expanded(
          child: CustomKpiCard.compact(
            title: 'تذاكر المساعدة',
            value: '$openTickets',
            unit: 'تذكرة',
            icon: Icons.headset_mic_rounded,
            iconColor:
                openTickets > 0 ? colors.warning : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
