import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_report_chart.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

class BillingReportSummarySection extends StatelessWidget {
  const BillingReportSummarySection({
    required this.summary,
    required this.charts,
    required this.arabicLabel,
    this.title = 'ملخص التقرير',
    super.key,
  });

  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> charts;
  final String Function(String key) arabicLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall),
              ..._summaryWidgets(summary),
            ],
          ),
        ),
        ...charts.map((chart) => BillingReportChart(payload: chart)),
      ],
    );
  }

  List<Widget> _summaryWidgets(Map<String, dynamic> values) {
    final widgets = <Widget>[];
    for (final entry in values.entries) {
      final value = entry.value;
      final label = arabicLabel(entry.key);
      if (value is Map<String, dynamic>) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(label, style: AppTypography.titleSmall),
          ),
        );
        for (final nested in value.entries) {
          widgets.add(
            Text(
              '${arabicLabel(nested.key)}: '
              '${_displayValue(nested.key, nested.value)}',
            ),
          );
        }
      } else if (value is List<dynamic>) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(label, style: AppTypography.titleSmall),
          ),
        );
        for (final item in value.whereType<Map<String, dynamic>>()) {
          widgets.add(
            Text(
              item.entries
                  .map(
                    (field) =>
                        '${arabicLabel(field.key)}: '
                        '${_displayValue(field.key, field.value)}',
                  )
                  .join(' • '),
            ),
          );
        }
      } else {
        widgets.add(
          Text('$label: ${_displayValue(entry.key, value)}'),
        );
      }
    }
    return widgets;
  }

  String _displayValue(String key, dynamic value) {
    if (value == null) return '—';
    final isAmount = key.endsWith('_minor') ||
        key == 'amount' ||
        key == 'mrr' ||
        key == 'arr' ||
        key.contains('revenue');
    if (isAmount &&
        (value is num || num.tryParse(value.toString()) != null)) {
      return AmountFormatter.format(value.toString());
    }
    return value.toString();
  }
}
