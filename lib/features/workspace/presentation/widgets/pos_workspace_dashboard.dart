import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/flows/pos_network_linking_flow.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_metrics_grid.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_active_supply_order_tracker.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_linked_network_selector.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_quick_actions_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_function_access_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_recent_transactions_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_welcome_header.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

class PosWorkspaceDashboard extends StatelessWidget {
  const PosWorkspaceDashboard({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage(
      embedded: true,
      onRefresh: controller.loadWorkspace,
      maxContentWidth: 920,
      child: Obx(() {
        if (controller.isLoadingPos.value &&
            controller.activePos.value == null) {
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

        if (controller.posError.value != null &&
            controller.activePos.value == null) {
          return CustomErrorState.boxed(
            title: 'تعذر تحميل نقاط البيع',
            subtitle: controller.posError.value,
            onRetry: controller.loadPosTenants,
          );
        }

        if (controller.activePos.value == null) {
          return const CustomEmptyState(
            icon: Icons.storefront_outlined,
            title: 'اختر نقطة البيع',
            subtitle: 'لا توجد نقطة بيع محددة حالياً لعرض بياناتها.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosWelcomeHeader(
              controller: controller,
              onQrTap: PosNetworkLinkingFlow(controller).start,
            ),
            AppSpacing.vLg,
            PosLinkedNetworkSelector(controller: controller),
            AppSpacing.vLg,
            if (controller.selectedNetworkLink.value != null) ...[
              ExecutiveMetricsGrid(
                items: controller.posKpiMetrics,
                onTodaySalesTap: controller.openPurchaseInvoices,
                onWalletTap: controller.openWalletStatement,
                onMetricTap: (id) {
                  switch (id) {
                    case 'today_procurement':
                      controller.openPurchaseInvoices();
                    case 'wallet' || 'purchasing_power':
                      controller.openWalletStatement();
                    case 'active_orders':
                      final order = controller.activeSupplyOrder;
                      if (order != null) {
                        controller.openProcurementOrder(order.request);
                      }
                  }
                },
              ),
              AppSpacing.vLg,
              PosActiveSupplyOrderTracker(controller: controller),
              AppSpacing.vLg,
            ],
            PosQuickActionsSection(
              onCreateOrder: controller.openNewProcurementOrder,
              onOpenInvoices: controller.openPurchaseInvoices,
            ),
            AppSpacing.vLg,
            WorkspaceFunctionAccessSection(
              title: 'إدارة نقطة البيع',
              subtitle: 'الفريق والشبكات المرتبطة وتقارير الأداء.',
              items: [
                WorkspaceFunctionAccessItem(
                  title: 'فريق العمل',
                  icon: Icons.groups_outlined,
                  onTap: controller.openTeamManagement,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'التقارير التشغيلية',
                  icon: Icons.analytics_outlined,
                  onTap: controller.openOperationalReports,
                ),
                WorkspaceFunctionAccessItem(
                  title: 'الشبكات المرتبطة',
                  icon: Icons.hub_outlined,
                  onTap: controller.openLinkedNetworks,
                ),
              ],
            ),
            AppSpacing.vLg,
            if (controller.selectedNetworkLink.value != null)
              PosRecentTransactionsSection(controller: controller),
          ],
        );
      }),
    );
  }
}
