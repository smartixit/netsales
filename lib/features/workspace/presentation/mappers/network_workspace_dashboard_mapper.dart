import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_expenses_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_packages_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_points_of_sale_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_requests_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/models/network_workspace_dashboard_view_model.dart';
import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

class NetworkWorkspaceDashboardMapper {
  const NetworkWorkspaceDashboardMapper._();

  static NetworkWorkspaceDashboardViewModel map(
    NetworkWorkspaceOverviewEntity? overview,
  ) {
    if (overview == null) return _empty();

    final sales = overview.sales;
    final pointsOfSale = overview.pointsOfSale;
    final requests = overview.requests;
    final packages = overview.packages;
    final expenses = overview.expenses;

    final points = sales?.trend
            .map(
              (point) => ChartDataPoint(
                x: _formatChartDate(point.date),
                y: point.totalAmount,
              ),
            )
            .toList(growable: false) ??
        const <ChartDataPoint>[];

    return NetworkWorkspaceDashboardViewModel(
      showSalesSection: sales != null,
      pendingRequestsCount: requests?.pending,
      salesTrendSummary: (
        totalSales: sales == null
            ? ''
            : AmountFormatter.format(sales.totalAmount),
        invoiceCount: sales?.invoiceCount ?? 0,
        growthRate: sales?.growthRate ?? 0,
      ),
      salesChartDefinition: ChartDefinition(
        family: ChartFamily.cartesian,
        type: ChartType.splineArea,
        series: [
          ChartSeries(
            id: 'sales_velocity',
            name: 'المبيعات',
            data: points,
            strokeWidth: 2.8,
            opacity: 0.22,
          ),
        ],
        options: const ChartOptions(
          showMarkers: true,
          showTooltip: true,
          enableTrackball: false,
          showMajorGridLines: false,
        ),
        state: points.isEmpty ? ChartState.empty : ChartState.data,
        stateMessage: points.isEmpty
            ? 'لا توجد بيانات مبيعات لهذه الفترة'
            : null,
      ),
      kpiMetrics: _mapMetrics(
        pointsOfSale: pointsOfSale,
        requests: requests,
        packages: packages,
        sales: sales,
        expenses: expenses,
      ),
    );
  }

  static NetworkWorkspaceDashboardViewModel _empty() =>
      NetworkWorkspaceDashboardViewModel(
        showSalesSection: false,
        pendingRequestsCount: null,
        salesVelocitySummary: (
          totalSales: '',
          invoiceCount: 0,
          growthRate: 0,
        ),
        salesChartDefinition: ChartDefinition(
          family: ChartFamily.cartesian,
          type: ChartType.splineArea,
          series: const [],
          options: const ChartOptions(
            showMarkers: true,
            showTooltip: true,
            enableTrackball: false,
            showMajorGridLines: false,
          ),
          state: ChartState.empty,
          stateMessage: 'لا توجد بيانات مبيعات لهذه الفترة',
        ),
        kpiMetrics: const [],
      );

  static List<DashboardMetricData> _mapMetrics({
    required NetworkPointsOfSaleMetricsEntity? pointsOfSale,
    required NetworkRequestsMetricsEntity? requests,
    required NetworkPackagesMetricsEntity? packages,
    required NetworkSalesMetricsEntity? sales,
    required NetworkExpensesMetricsEntity? expenses,
  }) {
    final items = <DashboardMetricData>[];

    if (pointsOfSale != null) {
      items.add(
        DashboardMetricData(
          id: 'pos',
          title: 'نقاط البيع',
          value: pointsOfSale.total.toString(),
          unit: 'نقطة',
          icon: Icons.storefront_rounded,
          tone: DashboardMetricTone.primary,
          variant: DashboardMetricVariant.standard,
          description:
              'نشطة ${pointsOfSale.active} · غير نشطة ${pointsOfSale.inactive}',
        ),
      );
    }

    if (requests != null) {
      items.add(
        DashboardMetricData(
          id: 'requests',
          title: 'طلبات التوريد',
          value: requests.total.toString(),
          unit: 'طلب',
          icon: Icons.inbox_rounded,
          tone: DashboardMetricTone.warning,
          variant: DashboardMetricVariant.standard,
          description: 'بانتظار الاعتماد ${requests.pending}',
        ),
      );
    }

    if (packages != null) {
      items.add(
        DashboardMetricData(
          id: 'packages',
          title: 'باقات الكتالوج',
          value: packages.total.toString(),
          unit: 'باقة',
          icon: Icons.widgets_rounded,
          tone: DashboardMetricTone.info,
          variant: DashboardMetricVariant.standard,
          description: 'باقات نشطة: ${packages.active}',
        ),
      );
    }

    if (sales != null) {
      items.add(
        DashboardMetricData(
          id: 'sales',
          title: 'فواتير المبيعات',
          value: AmountFormatter.format(sales.totalAmount),
          icon: Icons.receipt_long_rounded,
          tone: DashboardMetricTone.success,
          variant: DashboardMetricVariant.standard,
          description: '${sales.invoiceCount} فاتورة',
        ),
      );
    }

    if (expenses != null) {
      items.add(
        DashboardMetricData(
          id: 'expenses',
          title: 'مصروفات الشبكة',
          value: AmountFormatter.format(expenses.totalAmount),
          icon: Icons.trending_down_rounded,
          tone: DashboardMetricTone.danger,
          variant: DashboardMetricVariant.standard,
          description: '${expenses.count} سند موثق',
        ),
      );
    }

    return List.unmodifiable(items);
  }

  static String _formatChartDate(String rawDate) {
    if (rawDate.length < 10) return rawDate;
    final parts = rawDate.split('-');
    return parts.length < 3 ? rawDate : '${parts[2]}/${parts[1]}';
  }
}
