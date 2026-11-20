import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/domain/entities/network_expenses_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_packages_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_points_of_sale_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_requests_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_trend_point_entity.dart';
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
        sales: const NetworkSalesMetricsEntity(
          totalAmount: '2500.00',
          invoiceCount: 2,
          growthRate: 12.5,
          trend: [
            NetworkSalesTrendPointEntity(
              date: '2026-11-15',
              totalAmount: 2500,
              invoiceCount: 1,
            ),
          ],
        ),
        pointsOfSale: const NetworkPointsOfSaleMetricsEntity(
          total: 5,
          active: 4,
          inactive: 1,
        ),
        requests: const NetworkRequestsMetricsEntity(
          total: 3,
          pending: 2,
          approved: 1,
          rejected: 0,
          cancelled: 0,
        ),
        packages: const NetworkPackagesMetricsEntity(
          total: 4,
          active: 3,
          inactive: 1,
        ),
        expenses: const NetworkExpensesMetricsEntity(
          count: 1,
          totalAmount: '300.00',
        ),
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
