import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/commercial/presentation/screens/commercial_directory_screen.dart';
import 'package:netsales/features/commercial/presentation/screens/pos_directory_screen.dart';
import 'package:netsales/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:netsales/features/membership/presentation/screens/memberships_screen.dart';
import 'package:netsales/features/profile/presentation/screens/profile_screen.dart';
import 'package:netsales/features/reports/presentation/screens/operational_reports_screen.dart';
import 'package:netsales/features/requests/presentation/screens/procurement_orders_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/flows/workspace_entity_picker_coordinator.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_workspace_dashboard.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/double_back_exit_scope.dart';

class PosWorkspaceShell extends GetView<PosWorkspaceController> {
  const PosWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final items = [
      WorkspaceNavItem(
        label: 'الرئيسية',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: PosWorkspaceDashboard(controller: controller),
      ),
      const WorkspaceNavItem(
        label: 'الطلبات',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        content: ProcurementOrdersScreen(embedded: true),
      ),
      const WorkspaceNavItem(
        label: 'فواتيري',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        content: InvoicesScreen(embedded: true, isNetwork: false),
      ),
      const WorkspaceNavItem(
        label: 'البروفايل',
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle_rounded,
        content: ProfileScreen(embedded: true),
      ),
      if (controller.canViewMembers)
        const WorkspaceNavItem(
          label: 'فريق العمل',
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups_rounded,
          content: MembershipsScreen(embedded: true, isNetwork: false),
        ),
      WorkspaceNavItem(
        label: 'التقارير التشغيلية',
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        content: OperationalReportsScreen(
          networkId: controller.selectedNetworkLink.value?.networkId,
          posId: controller.activePos.value?.posId,
          isNetworkWorkspace: false,
          organizationName: controller.activePos.value?.posName,
          logoUrl: controller.activePos.value?.posProfileLogoUrl,
          embedded: true,
        ),
      ),
      const WorkspaceNavItem(
        label: 'نقاط بيعي',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: PosDirectoryScreen(embedded: true),
      ),
      const WorkspaceNavItem(
        label: 'الشبكات المرتبطة',
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub_rounded,
        content: CommercialDirectoryScreen(embedded: true, isNetwork: false),
      ),
    ];
    final loading =
        controller.isLoadingPos.value && controller.activePos.value == null;
    return DoubleBackExitScope(
      onFallback: controller.handleBackFallback,
      child: AdaptiveWorkspaceScaffold(
        appBar: WorkspaceAppBar(
          title: controller.activePosName.isNotEmpty
              ? controller.activePosName
              : 'اختر نقطة البيع',
          workspace: AppWorkspace.pos,
          isLoading: loading,
          rolePresentation: controller.rolePresentation,
          entityLogo: controller.entityLogo,
          entityInitials: controller.entityInitials,
          onProfileTap: controller.openProfile,
          onEntityPickerTap: () => const WorkspaceEntityPickerCoordinator().open(context, AppWorkspace.pos),
        ),
        items: items,
        mobileItems: items.take(4).toList(growable: false),
        currentIndex: controller.selectedNavIndex.value,
        mobileCurrentIndex: controller.selectedMobileNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
        centerActionIcon: Icons.add_rounded,
        centerActionTooltip: 'طلب توريد جديد',
        onCenterActionTap: controller.openNewProcurementOrder,
      ),
    );
  });
}
