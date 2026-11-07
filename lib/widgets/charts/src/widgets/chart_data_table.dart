import 'package:flutter/material.dart';

import '../models/chart_series.dart';
import '../theme/charts_theme.dart';

/// Accessible tabular alternative to a visual chart.
class ChartDataTable extends StatelessWidget {
  const ChartDataTable({super.key, required this.series});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final columns = <DataColumn>[
      const DataColumn(label: Text('السلسلة')),
      const DataColumn(label: Text('الفئة / الوقت')),
      const DataColumn(label: Text('القيمة')),
    ];
    final rows = <DataRow>[];

    for (final item in series) {
      for (final point in item.dataSource) {
        rows.add(
          DataRow(
            cells: [
              DataCell(Text(item.name)),
              DataCell(Text(point.label ?? point.x?.toString() ?? '—')),
              DataCell(Text(point.y?.toString() ?? '—')),
            ],
          ),
        );
      }
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.cardRadius),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(theme.surface),
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}
