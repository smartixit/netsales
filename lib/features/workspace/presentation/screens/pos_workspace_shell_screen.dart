import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:netsales/features/membership/presentation/views/pos_members_view.dart';
import 'package:netsales/features/reports/presentation/screens/operational_reports_screen.dart';
import 'package:netsales/features/requests/presentation/screens/procurement_orders_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_home_dashboard.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';

/// هيكل مساحة عمل نقطة البيع (POS Workspace Shell - Executive Edition)
class PosWorkspaceShell extends GetView<PosWorkspaceController> {
  const PosWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final navItems = [
        WorkspaceNavItem(
          label: 'الرئيسية',
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront_rounded,
          content: PosHomeDashboard(controller: controller),
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
          content: InvoicesScreen(embedded: true),
        ),
        const WorkspaceNavItem(
          label: 'فريق العمل',
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups_rounded,
          content: PosMembersView(embedded: true),
        ),
        WorkspaceNavItem(
          label: 'التقارير',
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics_rounded,
          content: OperationalReportsScreen(
            networkId: controller.selectedNetworkLink.value?.networkId,
            posId: controller.activePos.value?.posId,
            isNetworkWorkspace: false,
            organizationName: controller.activePos.value?.posName,
            logoUrl: controller.activePos.value?.posProfileLogoUrl,
          ),
        ),
      ];

      // القائمة المقلصة للتبويبات الأربعة الأساسية على الجوال
      final mobileNavItems = [
        navItems[0], // الرئيسية
        navItems[1], // طلبات التوريد
        navItems[2], // فواتيري
        navItems[3], // الرصيد والديون
      ];

      final isAppBarLoading =
          controller.isLoadingPos.value && controller.activePos.value == null;
      final posTitle = controller.activePos.value?.posName ?? 'لوحة نقطة البيع';

      return AdaptiveWorkspaceScaffold(
        appBar: WorkspaceAppBar(
          title: posTitle,
          workspace: AppWorkspace.pos,
          isLoading: isAppBarLoading,
          rolePresentation: controller.rolePresentation,
          userProfileLogo: controller.userProfileLogo,
          userInitials: controller.userInitials,
        ),
        items: navItems,
        mobileItems: mobileNavItems,
        currentIndex: controller.selectedNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
        centerActionIcon: Icons.add_rounded,
        centerActionTooltip: 'طلب توريد جديد',
        onCenterActionTap: controller.openNewProcurementOrder,
      );
    });
  }
}
