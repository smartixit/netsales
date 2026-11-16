import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_liquidity_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_metrics_grid.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_sales_velocity_chart.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_welcome_hero_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_live_pending_orders_stream.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_provider_carousel_section.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// الشاشة الرئيسية لمساحة عمل الشبكة (NetworkWorkspaceDashboard)
/// متوافقة هندسياً وتنظيمياً بنسبة 100% مع معايير مساحات العمل وشاشة PosHomeDashboard
class NetworkWorkspaceDashboard extends StatelessWidget {
  final NetworkWorkspaceController? controller;

  const NetworkWorkspaceDashboard({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? Get.find<NetworkWorkspaceController>();

    return RefreshIndicator.adaptive(
      onRefresh: ctrl.loadWorkspace,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppBreakpoints.screenMargin(context),
          MediaQuery.paddingOf(context).top + 20.h,
          AppBreakpoints.screenMargin(context),
          115.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.overview.value == null) {
                return const Column(
                  children: [
                    CustomSkeletonCard(height: 126),
                    SizedBox(height: 20),
                    CustomSkeletonCard(height: 210),
                    SizedBox(height: 16),
                    CustomSkeletonCard(height: 156),
                  ],
                );
              }
              if (ctrl.errorMessage.value != null &&
                  ctrl.overview.value == null) {
                return CustomErrorState.boxed(
                  title: 'تعذر تحميل لوحة الشبكة',
                  subtitle: ctrl.errorMessage.value,
                  onRetry: ctrl.loadWorkspace,
                );
              }
              if (ctrl.networks.isEmpty) {
                return const CustomEmptyState(
                  icon: Icons.hub_outlined,
                  title: 'لا توجد شبكة مرتبطة بالحساب',
                  subtitle:
                      'لا يمكن عرض مؤشرات مساحة العمل قبل توفر شبكة مصرح بها.',
                );
              }

              final overview = ctrl.overview.value;
              if (overview == null) {
                return CustomErrorState.boxed(
                  title: 'بيانات لوحة الشبكة غير متاحة',
                  subtitle:
                      ctrl.errorMessage.value ??
                      'لم تصل استجابة صالحة من الخادم.',
                  onRetry: () => ctrl.loadOverview(),
                );
              }

              final dashboard = ctrl.dashboardViewModel;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. كرت الترحيب القيادي
                  ExecutiveWelcomeHeroCard(
                    controller: ctrl,
                    onPendingTap: () => ctrl.onNavItemSelected(1),
                  ),
                  AppSpacing.vLg,

                  // 2. محدد الشبكة النشطة إذا كان للمزود أكثر من شبكة
                  if (ctrl.networks.length > 1) ...[
                    CustomDropdown<int>(
                      label: 'الشبكة النشطة للعمليات',
                      rxValue: ctrl.selectedNetworkId,
                      searchEnabled: ctrl.networks.length > 5,
                      items: ctrl.networks
                          .map(
                            (NetworkEntity network) => DropdownItem<int>(
                              value: network.networkId,
                              child: Text(network.networkName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: ctrl.selectNetwork,
                    ),
                    AppSpacing.vMd,
                  ],

                  // 3. كاروسيل بطاقات الشبكات التابعة للمزود
                  if (ctrl.networks.isNotEmpty) ...[
                    NetworkProviderCarouselSection(controller: ctrl),
                    AppSpacing.vLg,
                  ],

                  // 4. كرت السيولة والعمليات السريعة
                  if (dashboard.showLiquiditySection) ...[
                    ExecutiveLiquidityCard(summary: dashboard.liquiditySummary),
                    AppSpacing.vLg,
                  ],

                  // 5. منحنى وتيرة المبيعات والطلبات
                  if (dashboard.showSalesSection) ...[
                    ExecutiveSalesVelocityChart(
                      chartDefinition: dashboard.salesChartDefinition,
                      summary: dashboard.salesVelocitySummary,
                      selectedPeriod: ctrl.selectedPeriod.value,
                      onPeriodChanged: ctrl.selectPeriod,
                    ),
                    AppSpacing.vLg,
                  ],

                  // 6. شبكة المؤشرات الحيوية التنفيذية (2 أعمدة متوازية)
                  ExecutiveMetricsGrid(
                    items: dashboard.kpiMetrics,
                    onPointsOfSaleTap: () => ctrl.onNavItemSelected(2),
                    onRequestsTap: () => ctrl.onNavItemSelected(1),
                    onPackagesTap: ctrl.openPackagesCatalog,
                    onSalesTap: ctrl.openWholesaleInvoices,
                    onExpensesTap: () => ctrl.onNavItemSelected(3),
                    onWalletTap: () => ctrl.onNavItemSelected(3),
                  ),
                  AppSpacing.vXl,

                  // 7. شريط أحدث طلبات التوريد بانتظار الاعتماد
                  if (ctrl.recentPendingOrderItems.isNotEmpty) ...[
                    NetworkLivePendingOrdersStream(
                      items: ctrl.recentPendingOrderItems,
                      totalPendingCount: dashboard.pendingRequestsCount > 0
                          ? dashboard.pendingRequestsCount
                          : ctrl.recentPendingOrderItems.length,
                      onViewAll: () => ctrl.onNavItemSelected(1),
                    ),
                    AppSpacing.vXl,
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
