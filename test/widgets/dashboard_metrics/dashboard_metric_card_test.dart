import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

void main() {
  final metric = DashboardMetricData(
    id: 'active-networks',
    title: 'Active networks',
    value: '1,284',
    variant: DashboardMetricVariant.trend,
    icon: Icons.hub_outlined,
    trend: DashboardMetricTrend(
      direction: DashboardMetricDirection.increase,
      tone: DashboardMetricTone.success,
      valueLabel: '+12.5%',
      comparisonLabel: 'Compared with previous period',
    ),
    sparkline: [0.2, 0.35, 0.3, 0.55, 0.7, 0.62, 0.9],
    source: DashboardMetricSource(
      label: 'Platform reporting',
      updatedAtLabel: 'Updated 2 minutes ago',
      freshnessLabel: 'Fresh',
      freshness: DashboardMetricFreshness.fresh,
    ),
  );

  Widget harness(Widget child, {TextDirection direction = TextDirection.ltr}) {
    return MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(child: SizedBox(width: 340, child: child)),
        ),
      ),
    );
  }

  testWidgets('renders value, interpreted trend and source freshness', (
    tester,
  ) async {
    await tester.pumpWidget(harness(DashboardMetricCard(metric: metric)));

    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('+12.5%'), findsOneWidget);
    expect(find.text('Compared with previous period'), findsOneWidget);
    expect(find.textContaining('Platform reporting'), findsOneWidget);
  });

  testWidgets('renders target boundaries and progress metadata', (
    tester,
  ) async {
    final targetMetric = DashboardMetricData(
      id: 'quota',
      title: 'Monthly target',
      value: '72%',
      variant: DashboardMetricVariant.target,
      target: DashboardMetricTarget(
        progress: 0.72,
        currentLabel: '72%',
        targetLabel: '100%',
        thresholds: [
          DashboardMetricThreshold(
            position: 0.5,
            label: 'Warning boundary',
            tone: DashboardMetricTone.warning,
          ),
          DashboardMetricThreshold(
            position: 0.85,
            label: 'Target boundary',
            tone: DashboardMetricTone.success,
          ),
        ],
      ),
    );

    await tester.pumpWidget(harness(DashboardMetricCard(metric: targetMetric)));

    expect(find.text('72% / 100%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('renders loading and error states', (tester) async {
    await tester.pumpWidget(
      harness(
        DashboardMetricCard(
          metric: metric,
          state: DashboardMetricState.loading,
        ),
      ),
    );
    expect(find.text('1,284'), findsNothing);

    await tester.pumpWidget(
      harness(
        DashboardMetricCard(
          metric: metric,
          state: DashboardMetricState.error,
          errorMessage: 'Could not refresh',
        ),
      ),
    );
    expect(find.text('Could not refresh'), findsOneWidget);
  });

  testWidgets('supports RTL without changing metric semantics', (tester) async {
    await tester.pumpWidget(
      harness(
        DashboardMetricCard(metric: metric),
        direction: TextDirection.rtl,
      ),
    );

    expect(find.text('Active networks'), findsOneWidget);
    expect(find.text('1,284'), findsOneWidget);
  });
}
