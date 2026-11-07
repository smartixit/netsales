import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  testWidgets('maps trendlines and axis plot bands to Syncfusion', (
    tester,
  ) async {
    final definition = ChartDefinition(
      family: ChartFamily.cartesian,
      type: ChartType.line,
      options: const ChartOptions(
        animate: false,
        yAxis: ChartAxisConfig(
          kind: ChartAxisKind.numeric,
          plotBands: [
            ChartPlotBandConfig.referenceLine(
              value: 25,
              text: 'الحد المستهدف',
              borderColor: Color(0xFF0D7A5F),
              borderWidth: 2,
            ),
          ],
        ),
      ),
      series: [
        ChartSeries(
          id: 'monthly-sales',
          name: 'المبيعات',
          data: const [
            ChartDataPoint(x: 'Jan', y: 12),
            ChartDataPoint(x: 'Feb', y: 18),
            ChartDataPoint(x: 'Mar', y: 29),
            ChartDataPoint(x: 'Apr', y: 33),
          ],
          trendlines: const [
            ChartTrendlineConfig(
              type: ChartTrendlineType.movingAverage,
              name: 'متوسط متحرك',
              period: 3,
              forwardForecast: 2,
              backwardForecast: 1,
            ),
            ChartTrendlineConfig(
              type: ChartTrendlineType.linear,
              name: 'اتجاه خطي',
              opacity: 0.6,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 520,
          height: 300,
          child: ChartRenderer(definition: definition),
        ),
      ),
    );
    await tester.pump();

    final chart = tester.widget<sf.SfCartesianChart>(
      find.byType(sf.SfCartesianChart),
    );
    final line = chart.series.single as sf.LineSeries<ChartDataPoint, dynamic>;
    expect(line.trendlines, hasLength(2));
    expect(line.trendlines.first.type, sf.TrendlineType.movingAverage);
    expect(line.trendlines.first.period, 3);
    expect(line.trendlines.first.forwardForecast, 2);
    expect(line.trendlines.first.backwardForecast, 1);
    expect(line.trendlines.last.type, sf.TrendlineType.linear);

    final yAxis = chart.primaryYAxis as sf.NumericAxis;
    expect(yAxis.plotBands, hasLength(1));
    expect(yAxis.plotBands!.single.start, 25);
    expect(yAxis.plotBands!.single.end, 25);
    expect(yAxis.plotBands!.single.text, 'الحد المستهدف');
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects trendlines on unsupported horizontal bars', (
    tester,
  ) async {
    final definition = ChartDefinition(
      family: ChartFamily.comparison,
      type: ChartType.bar,
      series: [
        ChartSeries(
          id: 'bar',
          name: 'Bar',
          data: const [ChartDataPoint(x: 'A', y: 1)],
          trendlines: const [ChartTrendlineConfig()],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 360,
          height: 240,
          child: ChartRenderer(definition: definition),
        ),
      ),
    );

    expect(tester.takeException(), isA<ArgumentError>());
  });

  testWidgets('renders waterfall subtotal and total metadata in the table', (
    tester,
  ) async {
    final series = [
      ChartSeries(
        id: 'cash-flow',
        name: 'التدفق',
        data: const [
          ChartDataPoint(x: 'تشغيلي', y: 10, isIntermediateSum: true),
          ChartDataPoint(x: 'إجمالي', y: 10, isTotalSum: true),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChartDataTable(series: series)),
      ),
    );

    expect(find.text('نوع الإجمالي'), findsOneWidget);
    expect(find.text('مجموع مرحلي'), findsOneWidget);
    expect(find.text('الإجمالي النهائي'), findsOneWidget);
  });

  test('keeps an initially empty visible live source renderable', () {
    final source = ChartLiveDataSource<ChartDataPoint>();
    final definition = ChartDefinition(
      family: ChartFamily.cartesian,
      type: ChartType.line,
      series: [
        ChartSeries(id: 'live', name: 'Live', liveDataSource: source),
      ],
    );
    expect(definition.hasData, isFalse);
    expect(definition.hasLiveSources, isTrue);
    expect(definition.canRender, isTrue);
    source.dispose();
  });
}
