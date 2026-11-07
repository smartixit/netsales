import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  group('Chart framework public contract', () {
    test('exposes all seven chart families', () {
      expect(ChartFamily.values, hasLength(7));
      expect(ChartFamily.values, containsAll([
        ChartFamily.cartesian,
        ChartFamily.comparison,
        ChartFamily.circular,
        ChartFamily.funnel,
        ChartFamily.statistical,
        ChartFamily.financial,
        ChartFamily.spark,
      ]));
    });

    test('covers representative chart types from every family', () {
      expect(ChartType.values, containsAll([
        ChartType.line,
        ChartType.column,
        ChartType.pie,
        ChartType.funnel,
        ChartType.scatter,
        ChartType.candle,
        ChartType.sparkLine,
      ]));
    });

    test('live data source retains a bounded window', () {
      final source = ChartLiveDataSource<int>(initialData: const [1, 2], maxDataPoints: 3);
      source.appendAll([3, 4]);
      expect(source.snapshot, [2, 3, 4]);
      source.dispose();
    });
  });
}
