import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/flows/network_pos_invite_flow.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_liquidity_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_metrics_grid.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_sales_velocity_chart.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_welcome_hero_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_live_pending_orders_stream.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_provider_carousel_section.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// الشاشة الرئيسية لمساحة عمل الشبكة (NetworkWorkspaceDashboard)
/// متوافقة هندسياً وتنظيمياً بنسبة 100% مع معايير مساحات العمل وشاشة PosHomeDashboard
class NetworkWorkspaceDashboard extends StatelessWidget {
  final NetworkWorkspaceController controller;

  const NetworkWorkspaceDashboard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage(
      onRefresh: controller.loadWorkspace,
      padding: EdgeInsets.fromLTRB(
        AppBreakpoints.screenMargin(context),
        MediaQuery.paddingOf(context).top + 20.h,
        AppBreakpoints.screenMargin(context),
        115.h + MediaQuery.paddingOf(context).bottom,
      ),
      maxContentWidth: 760,
      child: Obx(() {
        if (controller.isLoading.value && controller.overview.value == null) {
          return const Column(
            children: [
              CustomStateView.loading(presentation: CustomStatePresentation.skeletonOnly, skeleton: CustomStateSkeleton(layout: CustomStateSkeletonLayout.cards, itemCount: 1, cardHeight: 126, maxColumns: 1, minItemWidth: 180)),
              SizedBox(height: 20),
              CustomStateView.loading(presentation: CustomStatePresentation.skeletonOnly, skeleton: CustomStateSkeleton(layout: CustomStateSkeletonLayout.cards, itemCount: 1, cardHeight: 210, maxColumns: 1, minItemWidth: 180)),
              SizedBox(height: 16),
              CustomStateView.loading(presentation: CustomStatePresentation.skeletonOnly, skeleton: CustomStateSkeleton(layout: CustomStateSkeletonLayout.cards, itemCount: 1, cardHeight: 156, maxColumns: 1, minItemWidth: 180)),
            ],
          );
        }
        if (controller.errorMessage.value != null &&
            controller.overview.value == null) {
          return CustomErrorState.boxed(
            title: 'تعذر تحميل لوحة الشبكة',
            subtitle: controller.errorMessage.value,
            onRetry: controller.loadWorkspace,
          );
        }
        if (controller.networks.isEmpty) {
          return const CustomEmptyState(
            icon: Icons.hub_outlined,
            title: 'لا توجد شبكة مرتبطة بالحساب',
            subtitle:
                'لا يمكن عرض مؤشرات مساحة العمل قبل توفر شبكة مصرح بها.',
          );
        }

        final overview = controller.overview.value;
        if (overview == null) {
          return CustomErrorState.boxed(
            title: 'بيانات لوحة الشبكة غير متاحة',
            subtitle:
                controller.errorMessage.value ??
                'لم تصل استجابة صالحة من الخادم.',
            onRetry: () => controller.loadOverview(),
          );
        }

        final dashboard = controller.dashboardViewModel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. كرت الترحيب القيادي
            ExecutiveWelcomeHeroCard(
              controller: controller,
              onPendingTap: () => controller.onNavItemSelected(1),
            ),
            AppSpacing.vLg,

            // 2. قسم كاروسيل بطاقات الشبكات التابعة للمزود
            if (controller.networks.isNotEmpty) ...[
              NetworkProviderCarouselSection(
                controller: controller,
                onInvitePos: NetworkPosInviteFlow(controller).start,
              ),
              AppSpacing.vLg,
            ],

            // 4. كرت السيولة والعمليات السريعة
            if (dashboard.showLiquiditySection) ...[
              ExecutiveLiquidityCard(
                summary: dashboard.liquiditySummary,
                onCreateSaleInvoice: controller.openCreateSaleInvoice,
                onCollectRepayment: controller.openRepaymentCollection,
                onOpenWalletStatement: controller.openNetworkWalletStatement,
              ),
              AppSpacing.vLg,
            ],

            // 5. منحنى وتيرة المبيعات والطلبات
            if (dashboard.showSalesSection) ...[
              ExecutiveSalesVelocityChart(
                chartDefinition: dashboard.salesChartDefinition,
                summary: dashboard.salesVelocitySummary,
                selectedPeriod: controller.selectedPeriod.value,
                onPeriodChanged: controller.selectPeriod,
              ),
              AppSpacing.vLg,
            ],

            // 6. شبكة المؤشرات الحيوية التنفيذية (2 أعمدة متوازية)
            ExecutiveMetricsGrid(
              items: dashboard.kpiMetrics,
              onPointsOfSaleTap: () => controller.onNavItemSelected(2),
              onRequestsTap: () => controller.onNavItemSelected(1),
              onPackagesTap: controller.openPackagesCatalog,
              onSalesTap: controller.openWholesaleInvoices,
              onExpensesTap: () => controller.onNavItemSelected(3),
              onWalletTap: () => controller.onNavItemSelected(3),
            ),
            AppSpacing.vXl,

            // 7. شريط أحدث طلبات التوريد بانتظار الاعتماد
            if (controller.recentPendingOrderItems.isNotEmpty) ...[
              NetworkLivePendingOrdersStream(
                items: controller.recentPendingOrderItems,
                totalPendingCount: dashboard.pendingRequestsCount > 0
                    ? dashboard.pendingRequestsCount
                    : controller.recentPendingOrderItems.length,
                onViewAll: () => controller.onNavItemSelected(1),
              ),
              AppSpacing.vXl,
            ],
          ],
        );
      }),
    );
  }
}
