import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// شبكة المؤشرات الحيوية التنفيذية (ExecutiveMetricsGrid)
/// مكون ميزة يربط استجابة الـ API الحقيقية بويدجيت لوحة المؤشرات العامة (DashboardMetricGrid)
/// في شبكة متجاوبة من عمودين على الجوال دون أي تجاوز أو بيانات مصطنعة
class ExecutiveMetricsGrid extends StatelessWidget {
  final List<DashboardMetricData> items;
  final VoidCallback onPointsOfSaleTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onPackagesTap;
  final VoidCallback onSalesTap;
  final VoidCallback onExpensesTap;
  final VoidCallback onWalletTap;

  const ExecutiveMetricsGrid({
    super.key,
    required this.items,
    required this.onPointsOfSaleTap,
    required this.onRequestsTap,
    required this.onPackagesTap,
    required this.onSalesTap,
    required this.onExpensesTap,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
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
