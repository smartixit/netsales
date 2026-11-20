import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
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

    final metrics = overview.metrics;
    final sales = overview.metric('sales');
    final hasSales = sales != null;
    final rawGrowth = sales?['growth_rate'];
    if (hasSales && rawGrowth is! num) {
      throw const FormatException('معدل نمو المبيعات غير صالح.');
    }
    final growthRate = rawGrowth is num ? rawGrowth.toDouble() : 0.0;

    final invoiceCountValue = sales?['invoice_count'];
    if (hasSales && invoiceCountValue is! num) {
      throw const FormatException('عدد فواتير المبيعات غير صالح.');
    }
    final salesSummary = (
      totalSales: hasSales
          ? AmountFormatter.format(overview.amount('sales', 'total_amount'))
          : '',
      invoiceCount: invoiceCountValue is num ? invoiceCountValue.toInt() : 0,
      growthRate: growthRate,
    );

    final trend = sales?['trend'];
    final points = <ChartDataPoint>[];
    if (trend is List) {
      for (final item in trend) {
        if (item is! Map) continue;
        final rawDate = item['date'];
        final rawTotal = item['total'];
        if (rawDate is! String || rawDate.isEmpty || rawTotal is! num) {
          continue;
        }
        points.add(
          ChartDataPoint(
            x: _formatChartDate(rawDate),
            y: rawTotal.toDouble(),
          ),
        );
      }
    }

    return NetworkWorkspaceDashboardViewModel(
      showSalesSection: hasSales,
      pendingRequestsCount: _pendingRequestsCount(overview),
      salesVelocitySummary: salesSummary,
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
      kpiMetrics: _mapMetrics(overview, metrics),
    );
  }

  static NetworkWorkspaceDashboardViewModel _empty() =>
      NetworkWorkspaceDashboardViewModel(
        showSalesSection: false,
        pendingRequestsCount: 0,
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

  static int? _pendingRequestsCount(NetworkWorkspaceOverviewEntity overview) {
    final requests = overview.metric('requests');
    if (requests == null) return null;
    final value = requests['pending'];
    if (value is! num) {
      throw const FormatException('عدد طلبات التوريد المعلقة غير صالح.');
    }
    return value.toInt();
  }

  static List<DashboardMetricData> _mapMetrics(
    NetworkWorkspaceOverviewEntity overview,
    Map<String, dynamic> metrics,
  ) {
    final items = <DashboardMetricData>[];

    if (metrics['points_of_sale'] is Map<String, dynamic>) {
      items.add(
        DashboardMetricData(
          id: 'pos',
          title: 'نقاط البيع',
          value: overview.count('points_of_sale', 'total'),
          unit: 'نقطة',
          icon: Icons.storefront_rounded,
          tone: DashboardMetricTone.primary,
          variant: DashboardMetricVariant.standard,
          description:
              'نشطة ${overview.count('points_of_sale', 'active')} · غير نشطة ${overview.count('points_of_sale', 'inactive')}',
        ),
      );
    }

    if (metrics['requests'] is Map<String, dynamic>) {
      items.add(
        DashboardMetricData(
          id: 'requests',
          title: 'طلبات التوريد',
          value: overview.count('requests', 'total'),
          unit: 'طلب',
          icon: Icons.inbox_rounded,
          tone: DashboardMetricTone.warning,
          variant: DashboardMetricVariant.standard,
          description:
              'بانتظار الاعتماد ${overview.count('requests', 'pending')}',
        ),
      );
    }

    if (metrics['packages'] is Map<String, dynamic>) {
      items.add(
        DashboardMetricData(
          id: 'packages',
          title: 'باقات الكتالوج',
          value: overview.count('packages', 'total'),
          unit: 'باقة',
          icon: Icons.widgets_rounded,
          tone: DashboardMetricTone.info,
          variant: DashboardMetricVariant.standard,
          description:
              'باقات نشطة: ${overview.count('packages', 'active')}',
        ),
      );
    }

    if (metrics['sales'] is Map<String, dynamic>) {
      items.add(
        DashboardMetricData(
          id: 'sales',
          title: 'فواتير المبيعات',
          value: AmountFormatter.format(overview.amount('sales', 'total_amount')),
          
          icon: Icons.receipt_long_rounded,
          tone: DashboardMetricTone.success,
          variant: DashboardMetricVariant.standard,
          description:
              '${overview.count('sales', 'invoice_count')} فاتورة',
        ),
      );
    }

    if (metrics['expenses'] is Map<String, dynamic>) {
      items.add(
        DashboardMetricData(
          id: 'expenses',
          title: 'مصروفات الشبكة',
          value: AmountFormatter.format(
            overview.amount('expenses', 'total_amount'),
          ),
          
          icon: Icons.trending_down_rounded,
          tone: DashboardMetricTone.danger,
          variant: DashboardMetricVariant.standard,
          description:
              '${overview.count('expenses', 'count')} سند موثق',
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
