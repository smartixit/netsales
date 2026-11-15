import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// شبكة المؤشرات الحيوية التنفيذية (ExecutiveMetricsGrid)
/// مكون ميزة يربط استجابة الـ API الحقيقية بويدجيت لوحة المؤشرات العامة (DashboardMetricGrid)
/// في شبكة متجاوبة من عمودين على الجوال دون أي تجاوز أو بيانات مصطنعة
class ExecutiveMetricsGrid extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final VoidCallback onPointsOfSaleTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onPackagesTap;
  final VoidCallback onSalesTap;
  final VoidCallback onExpensesTap;
  final VoidCallback onWalletTap;

  const ExecutiveMetricsGrid({
    super.key,
    required this.overview,
    required this.onPointsOfSaleTap,
    required this.onRequestsTap,
    required this.onPackagesTap,
    required this.onSalesTap,
    required this.onExpensesTap,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = overview.metrics;
    final items = <DashboardMetricData>[];

    // 1. مؤشر نقاط البيع
    if (metrics.containsKey('points_of_sale')) {
      final total = overview.count('points_of_sale', 'total');
      final active = overview.count('points_of_sale', 'active');
      final inactive = overview.count('points_of_sale', 'inactive');
      items.add(
        DashboardMetricData(
          id: 'pos',
          title: 'نقاط البيع',
          value: total,
          unit: 'نقطة',
          icon: Icons.storefront_rounded,
          tone: DashboardMetricTone.primary,
          variant: DashboardMetricVariant.standard,
          description: 'نشطة $active · غير نشطة $inactive',
        ),
      );
    }

    // 2. مؤشر طلبات التوريد
    if (metrics.containsKey('requests')) {
      final total = overview.count('requests', 'total');
      final pending = overview.count('requests', 'pending');
      items.add(
        DashboardMetricData(
          id: 'requests',
          title: 'طلبات التوريد',
          value: total,
          unit: 'طلب',
          icon: Icons.inbox_rounded,
          tone: DashboardMetricTone.warning,
          variant: DashboardMetricVariant.standard,
          description: 'بانتظار الاعتماد $pending',
        ),
      );
    }

    // 3. مؤشر باقات الكتالوج
    if (metrics.containsKey('packages')) {
      final total = overview.count('packages', 'total');
      final active = overview.count('packages', 'active');
      items.add(
        DashboardMetricData(
          id: 'packages',
          title: 'باقات الكتالوج',
          value: total,
          unit: 'باقة',
          icon: Icons.widgets_rounded,
          tone: DashboardMetricTone.info,
          variant: DashboardMetricVariant.standard,
          description: 'باقات نشطة جاهزة: $active',
        ),
      );
    }

    // 4. مؤشر فواتير المبيعات
    if (metrics.containsKey('sales')) {
      final invoiceCount = overview.count('sales', 'invoice_count');
      final totalSalesAmount = AmountFormatter.format(
        overview.amount('sales', 'total_amount'),
      );
      items.add(
        DashboardMetricData(
          id: 'sales',
          title: 'فواتير المبيعات',
          value: totalSalesAmount,
          unit: 'ر.ي',
          icon: Icons.receipt_long_rounded,
          tone: DashboardMetricTone.success,
          variant: DashboardMetricVariant.standard,
          description: '$invoiceCount فاتورة معتمدة',
        ),
      );
    }

    // 5. مؤشر مصروفات الشبكة
    if (metrics.containsKey('expenses')) {
      final expenseCount = overview.count('expenses', 'count');
      final totalExpensesAmount = AmountFormatter.format(
        overview.amount('expenses', 'total_amount'),
      );
      items.add(
        DashboardMetricData(
          id: 'expenses',
          title: 'مصروفات الشبكة',
          value: totalExpensesAmount,
          unit: 'ر.ي',
          icon: Icons.trending_down_rounded,
          tone: DashboardMetricTone.danger,
          variant: DashboardMetricVariant.standard,
          description: '$expenseCount سند موثق',
        ),
      );
    }

    // 6. مؤشر محفظة الشبكة
    final wallet = metrics['wallet'];
    if (wallet is Map<String, dynamic>) {
      final balance = AmountFormatter.format(
        overview.amount('wallet', 'balance'),
      );
      final isActive = wallet['is_active'] == true;
      items.add(
        DashboardMetricData(
          id: 'wallet',
          title: 'رصيد المحفظة',
          value: balance,
          unit: 'ر.ي',
          icon: Icons.account_balance_wallet_rounded,
          tone: isActive
              ? DashboardMetricTone.primary
              : DashboardMetricTone.danger,
          variant: DashboardMetricVariant.status,
          statusLabel: isActive ? 'المحفظة نشطة' : 'المحفظة معطلة',
          description: isActive ? 'جاهزة للعمليات المالية' : 'غير مفعلة',
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return NetSalesDashboardMetricsThemeAdapter.wrap(
      context: context,
      child: DashboardMetricGrid(
        metrics: items,
        minimumCardWidth: 145.w,
        onMetricTap: (id) {
          switch (id) {
            case 'pos':
              onPointsOfSaleTap();
            case 'requests':
              onRequestsTap();
            case 'packages':
              onPackagesTap();
            case 'sales':
              onSalesTap();
            case 'expenses':
              onExpensesTap();
            case 'wallet':
              onWalletTap();
          }
        },
      ),
    );
  }
}
