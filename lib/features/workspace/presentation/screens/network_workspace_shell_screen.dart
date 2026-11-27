import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/commercial/presentation/screens/commercial_directory_screen.dart';
import 'package:netsales/features/commercial/presentation/screens/network_directory_screen.dart';
import 'package:netsales/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:netsales/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:netsales/features/membership/presentation/screens/memberships_screen.dart';
import 'package:netsales/features/profile/presentation/screens/profile_screen.dart';
import 'package:netsales/features/reports/presentation/screens/operational_reports_screen.dart';
import 'package:netsales/features/requests/presentation/screens/procurement_orders_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_workspace_dashboard.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/double_back_exit_scope.dart';

class NetworkWorkspaceShell extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final items = [
      WorkspaceNavItem(
        label: 'الرئيسية',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        content: NetworkWorkspaceDashboard(controller: controller),
      ),
      const WorkspaceNavItem(
        label: 'الطلبات',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        content: ProcurementOrdersScreen(embedded: true, isNetwork: true),
      ),
      const WorkspaceNavItem(
        label: 'نقاط البيع',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: CommercialDirectoryScreen(embedded: true, isNetwork: true),
      ),
      const WorkspaceNavItem(
        label: 'البروفايل',
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        content: ProfileScreen(embedded: true),
      ),
      const WorkspaceNavItem(
        label: 'شبكاتي',
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub_rounded,
        content: NetworkDirectoryScreen(embedded: true),
      ),
      const WorkspaceNavItem(
        label: 'فواتير المبيعات',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        content: InvoicesScreen(embedded: true, isNetwork: true),
      ),
      const WorkspaceNavItem(
        label: 'المصروفات التشغيلية',
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments_rounded,
        content: ExpensesScreen(embedded: true),
      ),
      if (controller.canViewMembers)
        const WorkspaceNavItem(
          label: 'فريق العمل',
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups_rounded,
          content: MembershipsScreen(embedded: true, isNetwork: true),
        ),
      WorkspaceNavItem(
        label: 'التقارير التشغيلية',
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        content: OperationalReportsScreen(
          networkId: controller.selectedNetworkId.value,
          isNetworkWorkspace: true,
          organizationName: controller.selectedNetwork?.networkName,
          logoUrl: controller.selectedNetwork?.networkProfileLogoUrl,
          embedded: true,
        ),
      ),
    ];
    final loading =
        (controller.isLoadingNetworks.value ||
            controller.isLoadingOverview.value) &&
        controller.selectedNetwork == null;
    return DoubleBackExitScope(
      onFallback: controller.handleBackFallback,
      child: AdaptiveWorkspaceScaffold(
        appBar: WorkspaceAppBar(
          title: controller.activeNetworkName.isNotEmpty
              ? controller.activeNetworkName
              : 'اختر شبكة العمل',
          workspace: AppWorkspace.network,
          isLoading: loading,
          rolePresentation: controller.rolePresentation,
          entityLogo: controller.entityLogo,
          entityInitials: controller.entityInitials,
          onProfileTap: controller.openProfile,
        ),
        items: items,
        mobileItems: items.take(4).toList(growable: false),
        currentIndex: controller.selectedNavIndex.value,
        mobileCurrentIndex: controller.selectedMobileNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
        centerActionIcon: Icons.add_rounded,
        centerActionTooltip: 'إصدار فاتورة بيع جديدة',
        onCenterActionTap: controller.openCreateSaleInvoice,
      ),
    );
  });
}
