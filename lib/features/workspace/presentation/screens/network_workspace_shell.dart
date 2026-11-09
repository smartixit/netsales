import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/commercial/presentation/screens/network_pos_directory_screen.dart';
import 'package:netsales/features/finance/presentation/widgets/network_finance_workspace_hub.dart';
import 'package:netsales/features/requests/presentation/screens/network_supply_requests_review_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/features/membership/presentation/screens/membership_screen.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';

class NetworkWorkspaceShell extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      const WorkspaceNavItem(
        label: 'الرئيسية',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        content: CustomEmptyState(
          icon: Icons.hub_rounded,
          title: 'لوحة مساحة عمل الشبكة',
          subtitle: 'يجري تجهيز مؤشرات التشغيل المباشرة لهذه الشبكة.',
        ),
      ),
      const WorkspaceNavItem(
        label: 'طلبات التوريد',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        content: NetworkSupplyRequestsReviewScreen(),
      ),
      const WorkspaceNavItem(
        label: 'نقاط البيع',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: NetworkPosDirectoryScreen(),
      ),
      const WorkspaceNavItem(
        label: 'فريق العمل',
        icon: Icons.groups_outlined,
        activeIcon: Icons.groups_rounded,
        content: MembershipScreen(),
      ),
      const WorkspaceNavItem(
        label: 'المالية والديون',
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        content: NetworkFinanceWorkspaceHub(),
      ),
    ];

    return Obx(() => AdaptiveWorkspaceScaffold(
      appBar: const WorkspaceAppBar(
        title: 'لوحة التحكم',
        workspace: AppWorkspace.network,
      ),
      items: navItems,
      currentIndex: controller.selectedNavIndex.value,
      onIndexChanged: controller.onNavItemSelected,
    ));
  }
}
