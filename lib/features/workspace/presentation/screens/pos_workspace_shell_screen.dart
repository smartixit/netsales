import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/finance/presentation/widgets/pos_finance_workspace_hub.dart';
import 'package:netsales/features/invoices/presentation/screens/pos_purchase_invoices_screen.dart';
import 'package:netsales/features/membership/presentation/screens/membership_screen.dart';
import 'package:netsales/features/reports/presentation/screens/operational_reports_screen.dart';
import 'package:netsales/features/requests/presentation/screens/pos_procurement_orders_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_home_dashboard.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';

/// هيكل مساحة عمل نقطة البيع (POS Workspace Shell)
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
          label: 'طلبات التوريد',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          content: PosProcurementOrdersScreen(embedded: true),
        ),
        const WorkspaceNavItem(
          label: 'فواتيري',
          icon: Icons.receipt_outlined,
          activeIcon: Icons.receipt_rounded,
          content: PosPurchaseInvoicesScreen(embedded: true),
        ),
        const WorkspaceNavItem(
          label: 'فريق العمل',
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups_rounded,
          content: MembershipScreen(),
        ),
        const WorkspaceNavItem(
          label: 'الرصيد والديون',
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
          content: PosFinanceWorkspaceHub(),
        ),
        WorkspaceNavItem(
          label: 'التقارير',
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics_rounded,
          content: OperationalReportsScreen(
            networkId: controller.selectedNetworkLink.value?.networkId,
            posId: controller.activePos.value?.posId,
            isNetworkWorkspace: false,
          ),
        ),
      ];

      return AdaptiveWorkspaceScaffold(
        appBar: const WorkspaceAppBar(
          title: 'لوحة التحكم',
          workspace: AppWorkspace.pos,
        ),
        items: navItems,
        currentIndex: controller.selectedNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
      );
    });
  }
}
