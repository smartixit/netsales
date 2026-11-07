import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/adapters/netsales_charts_export_adapter.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  group('NetSalesChartsExportAdapter CSV', () {
    test('writes UTF-8 BOM and escapes CSV delimiters correctly', () {
      final series = [
        ChartSeries(
          id: 'branches',
          name: 'فروع, نشطة',
          data: const [
            ChartDataPoint(
              x: 'فرع "أ"',
              label: 'السطر الأول\nالسطر الثاني',
              y: 20,
              low: 18,
              high: 24,
            ),
          ],
        ),
      ];

      final bytes = NetSalesChartsExportAdapter.buildCsvBytes(series);
      final csv = utf8.decode(bytes);

      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(csv, contains('"فروع, نشطة"'));
      expect(csv, contains('"فرع ""أ"""'));
      expect(csv, contains('"السطر الأول\nالسطر الثاني"'));
      expect(csv, contains('branches'));
    });

    test('writes headers for an empty series collection', () {
      final csv = utf8.decode(
        NetSalesChartsExportAdapter.buildCsvBytes(const []),
      );
      expect(csv, contains('series_id,series_name,index'));
    });
  });
}
