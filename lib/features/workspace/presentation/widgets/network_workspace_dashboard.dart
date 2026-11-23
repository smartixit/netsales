import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_metrics_grid.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_sales_trend_chart.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_welcome_hero_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_pending_requests_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_function_access_section.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

class NetworkWorkspaceDashboard extends StatelessWidget {
  const NetworkWorkspaceDashboard({super.key, required this.controller});

  final NetworkWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage(
      embedded: true,
      onRefresh: controller.loadWorkspace,
      maxContentWidth: 920,
      child: Obx(() {
        if (controller.isLoadingNetworks.value && controller.networks.isEmpty) {
          return const CustomStateView.loading(
            presentation: CustomStatePresentation.skeletonOnly,
            skeleton: CustomStateSkeleton(
              layout: CustomStateSkeletonLayout.cards,
              itemCount: 3,
              cardHeight: 150,
              maxColumns: 1,
              minItemWidth: 180,
            ),
          );
        }

        if (controller.networksError.value != null &&
            controller.networks.isEmpty) {
          return CustomErrorState.boxed(
            title: 'تعذر تحميل الشبكات',
            subtitle: controller.networksError.value,
            onRetry: controller.retryNetworks,
          );
        }

        if (controller.networks.isEmpty) {
          return const CustomEmptyState(
            icon: Icons.hub_outlined,
            title: 'لا توجد شبكة مرتبطة بالحساب',
            subtitle: 'لا توجد شبكة مصرح بها لعرض لوحة العمل.',
          );
        }

        if (controller.selectedNetworkId.value == null) {
          return const CustomEmptyState(
            icon: Icons.hub_outlined,
            title: 'اختر شبكة العمل',
            subtitle: 'يحتوي الحساب على أكثر من شبكة. اختر الشبكة من شريط العنوان لعرض بياناتها.',
          );
        }

        if (controller.isLoadingOverview.value &&
            controller.overview.value == null) {
          return const CustomStateView.loading(
            presentation: CustomStatePresentation.skeletonOnly,
            skeleton: CustomStateSkeleton(
              layout: CustomStateSkeletonLayout.cards,
              itemCount: 3,
              cardHeight: 150,
              maxColumns: 1,
              minItemWidth: 180,
            ),
          );
        }

        if (controller.overviewError.value != null &&
            controller.overview.value == null) {
          return CustomErrorState.boxed(
            title: 'تعذر تحميل لوحة الشبكة',
            subtitle: controller.overviewError.value,
            onRetry: controller.retryOverview,
          );
        }

        final overview = controller.overview.value;
        if (overview == null) {
          return CustomErrorState.boxed(
            title: 'بيانات لوحة الشبكة غير متاحة',
            subtitle: 'لم تصل استجابة صالحة من الخادم.',
            onRetry: controller.retryOverview,
          );
        }

        final dashboard = controller.dashboardViewModel;
        final pendingItems = controller.recentPendingOrderItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExecutiveWelcomeHeroCard(controller: controller),
            AppSpacing.vLg,
            ExecutiveMetricsGrid(
              items: dashboard.kpiMetrics,
              isLoading: controller.isLoadingOverview.value,
              onMetricTap: controller.onMetricTap,
            ),
            if (dashboard.kpiMetrics.isNotEmpty) AppSpacing.vLg,
            if (dashboard.showSalesSection) ...[
              ExecutiveSalesTrendChart(
                chartDefinition: dashboard.salesChartDefinition,
                summary: dashboard.salesTrendSummary,
                selectedPeriod: controller.selectedPeriod.value,
                isLoading: controller.isLoadingOverview.value,
                onPeriodChanged: controller.selectPeriod,
              ),
              AppSpacing.vLg,
            ],
            NetworkPendingRequestsSection(
              items: pendingItems,
              totalPendingCount: dashboard.pendingRequestsCount,
              onViewAll: () => controller.onNavItemSelected(1),
            ),
            AppSpacing.vLg,
            WorkspaceFunctionAccessSection(
              title: 'إدارة النشاط التجاري',
              subtitle: 'الفواتير والكتالوج والمصروفات التشغيلية.',
              items: [
                WorkspaceFunctionAccessItem(
                  title: 'فواتير المبيعات',
                  icon: Icons.receipt_long_outlined,
                  onTap: controller.openWholesaleInvoices,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'المصروفات',
                  icon: Icons.payments_outlined,
                  onTap: controller.openOperatingExpenses,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'كتالوج الباقات',
                  icon: Icons.inventory_2_rounded,
                  onTap: controller.openPackagesCatalog,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'فريق العمل',
                  icon: Icons.groups_outlined,
                  onTap: controller.openTeamManagement,
                ),
              ],
            ),
            AppSpacing.vLg,
            WorkspaceFunctionAccessSection(
              title: 'الإدارة والمتابعة',
              subtitle: 'الفريق واشتراك المنصة وتقارير الأداء.',
              items: [
                WorkspaceFunctionAccessItem(
                  title: 'اشتراك المنصة',
                  icon: Icons.workspace_premium_outlined,
                  onTap: controller.openPlatformBilling,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'تقارير الاشتراكات',
                  icon: Icons.query_stats_outlined,
                  onTap: controller.openBillingReports,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'التقارير التشغيلية',
                  icon: Icons.analytics_outlined,
                  onTap: controller.openOperationalReports,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
