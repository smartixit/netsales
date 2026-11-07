import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  const point = ChartDataPoint(x: 'Jan', y: 12);

  final cases = <({ChartFamily family, ChartType type, ChartDataPoint point})>[
    (family: ChartFamily.cartesian, type: ChartType.line, point: point),
    (family: ChartFamily.comparison, type: ChartType.column, point: point),
    (family: ChartFamily.circular, type: ChartType.doughnut, point: point),
    (family: ChartFamily.funnel, type: ChartType.funnel, point: point),
    (
      family: ChartFamily.statistical,
      type: ChartType.boxAndWhisker,
      point: const ChartDataPoint(
        x: 'Q1',
        samples: [4, 6, 8, 9, 12],
      ),
    ),
    (
      family: ChartFamily.financial,
      type: ChartType.candle,
      point: const ChartDataPoint(
        x: 'Jan',
        low: 7,
        high: 14,
        open: 9,
        close: 12,
      ),
    ),
    (family: ChartFamily.spark, type: ChartType.sparkLine, point: point),
  ];

  testWidgets('detaches zoom controls while the chart is not renderable',
      (tester) async {
    final controller = ChartController();
    final series = [
      ChartSeries(id: 'sales', name: 'Sales', data: const [point]),
    ];

    ChartDefinition definition(ChartState state) => ChartDefinition(
          family: ChartFamily.cartesian,
          type: ChartType.line,
          options: const ChartOptions(enableZoom: true, animate: false),
          state: state,
          series: series,
        );

    Widget host(ChartState state) => MaterialApp(
          home: SizedBox(
            width: 520,
            height: 300,
            child: ChartRenderer(
              key: const ValueKey('sales-chart'),
              definition: definition(state),
              controller: controller,
            ),
          ),
        );

    await tester.pumpWidget(host(ChartState.data));
    await tester.pump();
    expect(controller.isAttached, isTrue);

    await tester.pumpWidget(host(ChartState.loading));
    expect(controller.isAttached, isFalse);

    await tester.pumpWidget(host(ChartState.data));
    await tester.pump();
    expect(controller.isAttached, isTrue);

    await tester.pumpWidget(host(ChartState.empty));
    expect(controller.isAttached, isFalse);
  });


  for (final chartCase in cases) {
    testWidgets('renders ${chartCase.family.name} chart family', (tester) async {
      final definition = ChartDefinition(
        family: chartCase.family,
        type: chartCase.type,
        options: const ChartOptions(animate: false),
        series: [
          ChartSeries(
            id: chartCase.family.name,
            name: chartCase.family.name,
            data: [chartCase.point],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 520,
                height: 300,
                child: ChartRenderer(definition: definition),
              ),
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
