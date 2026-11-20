import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_dashboard_mapper.dart';

void main() {
  group('NetworkWorkspaceDashboardMapper', () {
    test('maps only supported operational metrics and sales trend', () {
      final overview = NetworkWorkspaceOverviewEntity(
        networkId: 7,
        networkName: 'شبكة صنعاء',
        generatedAt: '2026-11-16T10:00:00Z',
        periodKey: '30d',
        metrics: {
          'sales': {
            'total_amount': '2500.00',
            'growth_rate': 12.5,
            'invoice_count': 2,
            'trend': [
              {'date': '2026-11-15', 'total': 2500},
            ],
          },
          'points_of_sale': {'total': 5, 'active': 4, 'inactive': 1},
          'requests': {'total': 3, 'pending': 2},
          'packages': {'total': 4, 'active': 3},
          'expenses': {'count': 1, 'total_amount': '300.00'},
        },
        recentPendingRequests: const [],
      );

      final result = NetworkWorkspaceDashboardMapper.map(overview);

      expect(result.showSalesSection, isTrue);
      expect(result.pendingRequestsCount, 2);
      expect(result.salesVelocitySummary.invoiceCount, 2);
      expect(result.salesVelocitySummary.totalSales, '2,500.00');
      expect(result.kpiMetrics, hasLength(5));
      expect(
        result.kpiMetrics.map((metric) => metric.id),
        isNot(contains('wallet')),
      );
      expect(result.salesChartDefinition.state.name, 'data');
    });

    test('returns an empty presentation model when overview is absent', () {
      final result = NetworkWorkspaceDashboardMapper.map(null);

      expect(result.showSalesSection, isFalse);
      expect(result.pendingRequestsCount, isNull);
      expect(result.kpiMetrics, isEmpty);
      expect(result.salesChartDefinition.state.name, 'empty');
    });

    test('does not manufacture an amount when the server contract is invalid', () {
      final overview = NetworkWorkspaceOverviewEntity(
        networkId: 7,
        networkName: 'شبكة صنعاء',
        generatedAt: '2026-11-16T10:00:00Z',
        periodKey: '30d',
        metrics: {
          'sales': {'invoice_count': 2, 'growth_rate': 12.5},
        },
        recentPendingRequests: const [],
      );

      expect(
        () => NetworkWorkspaceDashboardMapper.map(overview),
        throwsFormatException,
      );
    });
  });
}
