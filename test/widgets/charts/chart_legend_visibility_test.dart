import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  ChartDefinition definition(ChartFamily family, ChartType type, {
    bool toggleSeriesVisibility = true,
  }) => ChartDefinition(
    family: family,
    type: type,
    options: ChartOptions(
      animate: false,
      toggleSeriesVisibility: toggleSeriesVisibility,
    ),
    series: [
      ChartSeries(
        id: 'series',
        name: 'Series',
        data: const [ChartDataPoint(x: 'A', y: 5)],
      ),
    ],
  );

  testWidgets('enables legend series visibility toggling by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 480,
          height: 280,
          child: ChartRenderer(
            definition: definition(ChartFamily.cartesian, ChartType.line),
          ),
        ),
      ),
    );
    final chart = tester.widget<sf.SfCartesianChart>(
      find.byType(sf.SfCartesianChart),
    );
    expect(chart.legend.toggleSeriesVisibility, isTrue);
  });

  testWidgets('supports disabling legend toggling for Cartesian charts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 480,
          height: 280,
          child: ChartRenderer(
            definition: definition(
              ChartFamily.cartesian,
              ChartType.line,
              toggleSeriesVisibility: false,
            ),
          ),
        ),
      ),
    );
    final chart = tester.widget<sf.SfCartesianChart>(
      find.byType(sf.SfCartesianChart),
    );
    expect(chart.legend.toggleSeriesVisibility, isFalse);
  });

  testWidgets('applies legend toggling to circular, funnel and pyramid charts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 480,
          height: 280,
          child: ChartRenderer(
            definition: definition(ChartFamily.circular, ChartType.pie),
          ),
        ),
      ),
    );
    final circular = tester.widget<sf.SfCircularChart>(
      find.byType(sf.SfCircularChart),
    );
    expect(circular.legend.toggleSeriesVisibility, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 480,
          height: 280,
          child: ChartRenderer(
            definition: definition(ChartFamily.funnel, ChartType.funnel),
          ),
        ),
      ),
    );
    final funnel = tester.widget<sf.SfFunnelChart>(
      find.byType(sf.SfFunnelChart),
    );
    expect(funnel.legend.toggleSeriesVisibility, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 480,
          height: 280,
          child: ChartRenderer(
            definition: definition(ChartFamily.funnel, ChartType.pyramid),
          ),
        ),
      ),
    );
    final pyramid = tester.widget<sf.SfPyramidChart>(
      find.byType(sf.SfPyramidChart),
    );
    expect(pyramid.legend.toggleSeriesVisibility, isTrue);
  });
}
