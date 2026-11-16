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
    final wallet = overview.metric('wallet');
    final sales = overview.metric('sales');
    final pos = overview.metric('points_of_sale');
    final hasWallet = wallet != null;
    final hasSales = sales != null;

    final balance = hasWallet
        ? AmountFormatter.format(overview.amount('wallet', 'balance'))
        : hasSales
        ? AmountFormatter.format(overview.amount('sales', 'total_amount'))
        : '0.00';
    final rawGrowth = sales?['growth_rate'];
    final growthRate = rawGrowth is num ? rawGrowth.toDouble() : 0.0;
    final posTotal = pos == null ? '0' : overview.count('points_of_sale', 'total');
    final posActive = pos == null ? '0' : overview.count('points_of_sale', 'active');

    final liquidity = (
      balance: balance,
      hasWallet: hasWallet,
      isWalletActive: wallet?['is_active'] == true,
      hasSales: hasSales,
      growthRate: growthRate,
      cashSales: hasSales
          ? AmountFormatter.format(overview.amount('sales', 'paid_amount'))
          : '0.00',
      outstandingReceivables: hasSales
          ? AmountFormatter.format(overview.amount('sales', 'outstanding_amount'))
          : '0.00',
      posCoverage: '$posActive/$posTotal',
    );

    final invoiceCountValue = sales?['invoice_count'];
    final salesSummary = (
      totalSales: sales?['total_amount'] == null
          ? '0.00'
          : AmountFormatter.format(sales!['total_amount'].toString()),
      invoiceCount: invoiceCountValue is num
          ? invoiceCountValue.toInt()
          : int.tryParse(invoiceCountValue?.toString() ?? '0') ?? 0,
      growthRate: growthRate,
    );

    final trend = sales?['trend'];
    final points = <ChartDataPoint>[];
    if (trend is List) {
      for (final item in trend) {
        if (item is! Map) continue;
        final rawDate = item['date']?.toString() ?? '';
        final rawTotal = item['total'];
        final total = rawTotal is num
            ? rawTotal.toDouble()
            : double.tryParse(rawTotal?.toString() ?? '0') ?? 0.0;
        points.add(ChartDataPoint(x: _formatChartDate(rawDate), y: total));
      }
    }

    return NetworkWorkspaceDashboardViewModel(
      showLiquiditySection: hasWallet || hasSales,
      showSalesSection: hasSales,
      pendingRequestsCount: _pendingRequestsCount(overview),
      liquiditySummary: liquidity,
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
            ? 'لا توجد فواتير مبيعات مسجلة في هذه الفترة'
            : null,
      ),
      kpiMetrics: _mapMetrics(overview, metrics),
    );
  }

  static String formatNetworkSales(
    NetworkWorkspaceOverviewEntity? overview, {
    required bool isSelected,
  }) {
    if (!isSelected) return '••••';
    final sales = overview?.metric('sales');
    final total = sales?['total_amount'] ?? sales?['total'];
    if (total is num) {
      return '${AmountFormatter.formatValue(total, decimalPlaces: 0)} YER';
    }
    return '0 YER';
  }

  static String formatNetworkPosCount(
    NetworkWorkspaceOverviewEntity? overview, {
    required bool isSelected,
  }) {
    if (!isSelected) return 'وكلاء معتمدين';
    final total = overview?.metric('points_of_sale')?['total'] ??
        overview?.metric('pos')?['total'];
    return total == null ? 'وكلاء معتمدين' : '$total نقطة بيع';
  }

  static NetworkWorkspaceDashboardViewModel _empty() {
    return NetworkWorkspaceDashboardViewModel(
      showLiquiditySection: false,
      showSalesSection: false,
      pendingRequestsCount: 0,
      liquiditySummary: (
        balance: '0.00',
        hasWallet: false,
        isWalletActive: false,
        hasSales: false,
        growthRate: 0,
        cashSales: '0.00',
        outstandingReceivables: '0.00',
        posCoverage: '0/0',
      ),
      salesVelocitySummary: (
        totalSales: '0.00',
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
        stateMessage: 'لا توجد فواتير مبيعات مسجلة في هذه الفترة',
      ),
      kpiMetrics: const [],
    );
  }

  static int _pendingRequestsCount(NetworkWorkspaceOverviewEntity overview) {
    final value = overview.metric('requests')?['pending'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static List<DashboardMetricData> _mapMetrics(
    NetworkWorkspaceOverviewEntity overview,
    Map<String, dynamic> metrics,
  ) {
    final items = <DashboardMetricData>[];

    if (metrics.containsKey('points_of_sale')) {
      final total = overview.count('points_of_sale', 'total');
      final active = overview.count('points_of_sale', 'active');
      final inactive = overview.count('points_of_sale', 'inactive');
      items.add(DashboardMetricData(
        id: 'pos',
        title: 'نقاط البيع',
        value: total,
        unit: 'نقطة',
        icon: Icons.storefront_rounded,
        tone: DashboardMetricTone.primary,
        variant: DashboardMetricVariant.standard,
        description: 'نشطة $active · غير نشطة $inactive',
      ));
    }

    if (metrics.containsKey('requests')) {
      final total = overview.count('requests', 'total');
      final pending = overview.count('requests', 'pending');
      items.add(DashboardMetricData(
        id: 'requests',
        title: 'طلبات التوريد',
        value: total,
        unit: 'طلب',
        icon: Icons.inbox_rounded,
        tone: DashboardMetricTone.warning,
        variant: DashboardMetricVariant.standard,
        description: 'بانتظار الاعتماد $pending',
      ));
    }

    if (metrics.containsKey('packages')) {
      final total = overview.count('packages', 'total');
      final active = overview.count('packages', 'active');
      items.add(DashboardMetricData(
        id: 'packages',
        title: 'باقات الكتالوج',
        value: total,
        unit: 'باقة',
        icon: Icons.widgets_rounded,
        tone: DashboardMetricTone.info,
        variant: DashboardMetricVariant.standard,
        description: 'باقات نشطة: $active',
      ));
    }

    if (metrics.containsKey('sales')) {
      final invoiceCount = overview.count('sales', 'invoice_count');
      final totalAmount = AmountFormatter.format(
        overview.amount('sales', 'total_amount'),
      );
      items.add(DashboardMetricData(
        id: 'sales',
        title: 'فواتير المبيعات',
        value: totalAmount,
        unit: 'ر.ي',
        icon: Icons.receipt_long_rounded,
        tone: DashboardMetricTone.success,
        variant: DashboardMetricVariant.standard,
        description: '$invoiceCount فاتورة معتمدة',
      ));
    }

    if (metrics.containsKey('expenses')) {
      final expenseCount = overview.count('expenses', 'count');
      final totalAmount = AmountFormatter.format(
        overview.amount('expenses', 'total_amount'),
      );
      items.add(DashboardMetricData(
        id: 'expenses',
        title: 'مصروفات الشبكة',
        value: totalAmount,
        unit: 'ر.ي',
        icon: Icons.trending_down_rounded,
        tone: DashboardMetricTone.danger,
        variant: DashboardMetricVariant.standard,
        description: '$expenseCount سند موثق',
      ));
    }

    final wallet = overview.metric('wallet');
    if (wallet != null) {
      final isActive = wallet['is_active'] == true;
      items.add(DashboardMetricData(
        id: 'wallet',
        title: 'رصيد المحفظة',
        value: AmountFormatter.format(overview.amount('wallet', 'balance')),
        unit: 'ر.ي',
        icon: Icons.account_balance_wallet_rounded,
        tone: isActive
            ? DashboardMetricTone.primary
            : DashboardMetricTone.danger,
        variant: DashboardMetricVariant.status,
        statusLabel: isActive ? 'المحفظة نشطة' : 'المحفظة معطلة',
        description: isActive ? 'جاهزة للعمليات' : 'غير مفعلة',
      ));
    }

    return List.unmodifiable(items);
  }

  static String _formatChartDate(String rawDate) {
    if (rawDate.length < 10) return rawDate;
    final parts = rawDate.split('-');
    return parts.length < 3 ? rawDate : '${parts[2]}/${parts[1]}';
  }
}
