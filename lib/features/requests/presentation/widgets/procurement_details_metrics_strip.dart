import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_metric_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_metric_data.dart';

/// شبكة المؤشرات التنفيذية لطلب التوريد (ProcurementDetailsMetricsStrip)
///
/// صممت لتجسد أعلى معايير العمق البصري والتسلسل الهرمي في المنصات العالمية:
/// - بطاقات مستقلة متجاوبة مع ظلال وتدرجات ناعمة وعمق بصري مميز.
/// - أيقونات بحاويات ملونة وفق طبيعة المؤشر (مالي، كروت، أوراق، باقات).
/// - خط الهوية المعتمد مع أرقام جدولية موحدة العرض [FontFeature.tabularFigures] وخالية تماماً من الخطوط الأحادية الدخيلة.
/// - تكيف كامل عبر [LayoutBuilder] مع حماية الأرقام بواسطة [FittedBox].
class ProcurementDetailsMetricsStrip extends StatelessWidget {
  const ProcurementDetailsMetricsStrip({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final sheetsFormatted = request.formattedTotalSheets;

    // بيانات المؤشرات الأربعة الأساسية
    final metrics = [
      ProcurementDetailsMetricData(
        label: 'إجمالي الطلب',
        value: AmountFormatter.formatValue(request.requestTotalAmount),
        unit: 'ر.ي',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: colors.primary,
        isPrimary: true,
        caption: request.items.isNotEmpty ? 'صافي الطلب' : null,
      ),
      ProcurementDetailsMetricData(
        label: 'عدد الكروت',
        value: '${request.totalVouchers}',
        unit: 'كرت',
        icon: Icons.confirmation_number_rounded,
        accentColor: const Color(0xFF0284C7),
        caption: 'رصيد إجمالي',
      ),
      ProcurementDetailsMetricData(
        label: 'إجمالي الأوراق',
        value: sheetsFormatted,
        unit: 'ورقة',
        icon: Icons.layers_rounded,
        accentColor: const Color(0xFF7C3AED),
        caption: 'أوراق A4',
      ),
      ProcurementDetailsMetricData(
        label: 'الباقات المطلوبة',
        value: '${request.items.length}',
        unit: 'باقات',
        icon: Icons.widgets_rounded,
        accentColor: const Color(0xFFD97706),
        caption: 'فئات مختلفة',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;

        if (isCompact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: ProcurementDetailsMetricCard(data: metrics[0])),
                  AppSpacing.hSm,
                  Expanded(child: ProcurementDetailsMetricCard(data: metrics[1])),
                ],
              ),
              AppSpacing.vSm,
              Row(
                children: [
                  Expanded(child: ProcurementDetailsMetricCard(data: metrics[2])),
                  AppSpacing.hSm,
                  Expanded(child: ProcurementDetailsMetricCard(data: metrics[3])),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < metrics.length; i++) ...[
              if (i > 0) AppSpacing.hSm,
              Expanded(child: ProcurementDetailsMetricCard(data: metrics[i])),
            ],
          ],
        );
      },
    );
  }
}
