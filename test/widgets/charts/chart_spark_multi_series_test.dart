import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  testWidgets('renders multiple visible spark series independently', (
    tester,
  ) async {
    final salesSource = ChartLiveDataSource<ChartDataPoint>(
      initialData: const [
        ChartDataPoint(x: 1, y: 10),
        ChartDataPoint(x: 2, y: 14),
      ],
    );
    final profitSource = ChartLiveDataSource<ChartDataPoint>(
      initialData: const [
        ChartDataPoint(x: 1, y: 4),
        ChartDataPoint(x: 2, y: 7),
      ],
    );

    final definition = ChartDefinition(
      family: ChartFamily.spark,
      type: ChartType.sparkLine,
      options: const ChartOptions(animate: false),
      series: [
        ChartSeries(
          id: 'sales',
          name: 'المبيعات',
          liveDataSource: salesSource,
        ),
        ChartSeries(
          id: 'profit',
          name: 'الأرباح',
          type: ChartType.sparkArea,
          liveDataSource: profitSource,
        ),
        ChartSeries(
          id: 'hidden',
          name: 'مخفي',
          isVisible: false,
          data: const [ChartDataPoint(x: 1, y: 99)],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 160,
            child: ChartRenderer(definition: definition),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SfSparkLineChart), findsOneWidget);
    expect(find.byType(SfSparkAreaChart), findsOneWidget);
    expect(find.text('المبيعات'), findsOneWidget);
    expect(find.text('الأرباح'), findsOneWidget);
    expect(find.text('مخفي'), findsNothing);
    expect(tester.takeException(), isNull);

    salesSource.append(const ChartDataPoint(x: 3, y: 18));
    profitSource.updateAt(0, const ChartDataPoint(x: 1, y: 5));
    await tester.pump();

    expect(salesSource.length, 3);
    expect(profitSource.data.first.y, 5);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    salesSource.dispose();
    profitSource.dispose();
  });

  testWidgets('renders an empty spark family without visible series', (
    tester,
  ) async {
    final definition = ChartDefinition(
      family: ChartFamily.spark,
      type: ChartType.sparkLine,
      series: [
        ChartSeries(
          id: 'hidden',
          name: 'Hidden',
          isVisible: false,
          data: const [ChartDataPoint(x: 1, y: 1)],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 300,
          height: 80,
          child: ChartRenderer(definition: definition),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SfSparkLineChart), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
