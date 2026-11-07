import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  final cases = <({ChartFamily family, ChartType type, ChartDataPoint point})>[
    for (final type in [
      ChartType.line,
      ChartType.spline,
      ChartType.fastLine,
      ChartType.area,
      ChartType.splineArea,
      ChartType.stepLine,
      ChartType.stepArea,
      ChartType.rangeArea,
      ChartType.splineRangeArea,
    ])
      (family: ChartFamily.cartesian, type: type, point: const ChartDataPoint(x: 1, y: 12, low: 8, high: 16)),
    for (final type in [
      ChartType.column,
      ChartType.bar,
      ChartType.stackedColumn,
      ChartType.stackedBar,
      ChartType.stackedArea,
      ChartType.stackedLine,
      ChartType.stackedColumn100,
      ChartType.stackedBar100,
      ChartType.stackedArea100,
      ChartType.stackedLine100,
      ChartType.waterfall,
    ])
      (family: ChartFamily.comparison, type: type, point: const ChartDataPoint(x: 'Jan', y: 12)),
    for (final type in [ChartType.scatter, ChartType.bubble, ChartType.histogram])
      (family: ChartFamily.statistical, type: type, point: const ChartDataPoint(x: 2, y: 12, size: 5)),
    (
      family: ChartFamily.statistical,
      type: ChartType.boxAndWhisker,
      point: const ChartDataPoint(x: 'Q1', samples: [4, 6, 8, 9, 12]),
    ),
    (
      family: ChartFamily.statistical,
      type: ChartType.errorBar,
      point: const ChartDataPoint(x: 2, y: 12),
    ),
    (
      family: ChartFamily.statistical,
      type: ChartType.rangeColumn,
      point: const ChartDataPoint(x: 'Q1', low: 4, high: 12),
    ),
    for (final type in [ChartType.candle, ChartType.hilo, ChartType.ohlc])
      (
        family: ChartFamily.financial,
        type: type,
        point: const ChartDataPoint(x: 'Jan', low: 7, high: 14, open: 9, close: 12, volume: 100),
      ),
    for (final type in [ChartType.pie, ChartType.doughnut, ChartType.radialBar])
      (family: ChartFamily.circular, type: type, point: const ChartDataPoint(x: 'Jan', y: 12)),
    for (final type in [ChartType.funnel, ChartType.pyramid])
      (family: ChartFamily.funnel, type: type, point: const ChartDataPoint(x: 'Visits', y: 12)),
    for (final type in [ChartType.sparkLine, ChartType.sparkArea, ChartType.sparkBar, ChartType.sparkWinLoss])
      (family: ChartFamily.spark, type: type, point: const ChartDataPoint(x: 1, y: 12)),
  ];

  for (final chartCase in cases) {
    testWidgets('renders ${chartCase.type.name}', (tester) async {
      final definition = ChartDefinition(
        family: chartCase.family,
        type: chartCase.type,
        options: const ChartOptions(animate: false),
        series: [
          ChartSeries(
            id: chartCase.type.name,
            name: chartCase.type.name,
            data: [chartCase.point],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 520,
              height: 300,
              child: ChartRenderer(definition: definition),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ChartRenderer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
