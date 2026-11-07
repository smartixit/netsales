import 'package:flutter/material.dart';

import '../models/chart_data_point.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';

class ChartDataTable extends StatelessWidget {
  const ChartDataTable({super.key, required this.series});

  final List<ChartSeries> series;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final points = <({ChartSeries series, ChartDataPoint point})>[
      for (final item in series)
        for (final point in item.dataSource)
          (series: item, point: point),
    ];
    if (points.isEmpty) return const SizedBox.shrink();

    final columns = <({String title, String Function(ChartDataPoint) value})>[
      (title: 'السلسلة', value: (_) => ''),
      (title: 'الفئة / الوقت', value: (point) => _string(point.label ?? point.x)),
      if (points.any((row) => row.point.y != null))
        (title: 'القيمة', value: (point) => _string(point.y)),
      if (points.any((row) => row.point.low != null))
        (title: 'الأدنى', value: (point) => _string(point.low)),
      if (points.any((row) => row.point.high != null))
        (title: 'الأعلى', value: (point) => _string(point.high)),
      if (points.any((row) => row.point.open != null))
        (title: 'الافتتاح', value: (point) => _string(point.open)),
      if (points.any((row) => row.point.close != null))
        (title: 'الإغلاق', value: (point) => _string(point.close)),
      if (points.any((row) => row.point.volume != null))
        (title: 'الحجم', value: (point) => _string(point.volume)),
      if (points.any((row) => row.point.size != null))
        (title: 'الحجم النسبي', value: (point) => _string(point.size)),
      if (points.any((row) => row.point.samples?.isNotEmpty ?? false))
        (title: 'العينات', value: (point) => point.samples?.join('، ') ?? '—'),
      if (points.any(
        (row) => row.point.isIntermediateSum || row.point.isTotalSum,
      ))
        (
          title: 'نوع الإجمالي',
          value: (point) => point.isTotalSum
              ? 'الإجمالي النهائي'
              : point.isIntermediateSum
                  ? 'مجموع مرحلي'
                  : '—',
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.cardRadius),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(theme.surface),
              columns: [
                for (final column in columns)
                  DataColumn(label: Text(column.title)),
              ],
              rows: [
                for (final row in points)
                  DataRow(
                    cells: [
                      for (var index = 0; index < columns.length; index++)
                        DataCell(
                          Text(
                            index == 0
                                ? row.series.name
                                : columns[index].value(row.point),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _string(Object? value) {
    if (value == null) return '—';
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }
}
