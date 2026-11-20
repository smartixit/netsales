import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/cards/custom_metric_display_card.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

/// شبكة المؤشرات المالية والتشغيلية الموحدة لصفحات التفاصيل (CustomDocumentMetricsStrip)
///
/// تجسد المعايير العالمية في التسلسل الهرمي للمؤشرات والبيانات المحورية:
/// - بطاقات قياس متجاوبة مع عمق لوني ناعم وأرقام بخصائص جدولية موحدة [FontFeature.tabularFigures].
/// - تكيف تلقائي عبر [LayoutBuilder] للشبكات المدمجة (< 520) وشاشات الأجهزة اللوحية والمكتبية.
/// - دعم مدمج لشريط تفقيط المبلغ المالي المعتمد [CustomAmountToWordsBanner] عند تمرير [amountForWords].
class CustomDocumentMetricsStrip extends StatelessWidget {
  const CustomDocumentMetricsStrip({
    super.key,
    required this.metrics,
    this.amountForWords,
    this.currencyCode = 'YER',
  });

  final List<CustomMetricCardData> metrics;
  final double? amountForWords;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;

            if (isCompact && metrics.length >= 4) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomMetricDisplayCard(data: metrics[0]),
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: CustomMetricDisplayCard(data: metrics[1]),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,
                  Row(
                    children: [
                      Expanded(
                        child: CustomMetricDisplayCard(data: metrics[2]),
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: CustomMetricDisplayCard(data: metrics[3]),
                      ),
                    ],
                  ),
                  for (var i = 4; i < metrics.length; i++) ...[
                    AppSpacing.vSm,
                    CustomMetricDisplayCard(data: metrics[i]),
                  ],
                ],
              );
            }

            if (isCompact && metrics.length == 2) {
              return Row(
                children: [
                  Expanded(child: CustomMetricDisplayCard(data: metrics[0])),
                  AppSpacing.hSm,
                  Expanded(child: CustomMetricDisplayCard(data: metrics[1])),
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < metrics.length; i++) ...[
                  if (i > 0) AppSpacing.hSm,
                  Expanded(child: CustomMetricDisplayCard(data: metrics[i])),
                ],
              ],
            );
          },
        ),

        // شريط التفقيط المالي إن وجد
        if (amountForWords != null && amountForWords! > 0) ...[
          AppSpacing.vSm,
          CustomAmountToWordsBanner(
            amount: amountForWords!,
            currencyCode: currencyCode,
          ),
        ],
      ],
    );
  }
}
