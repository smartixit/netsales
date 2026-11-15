import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/billing/presentation/screens/billing_reports_screen.dart';
import 'package:netsales/features/billing/presentation/screens/billing_workspace_screen.dart';
import 'package:netsales/features/commercial/presentation/screens/network_pos_directory_screen.dart';
import 'package:netsales/features/finance/presentation/widgets/network_finance_workspace_hub.dart';
import 'package:netsales/features/membership/presentation/screens/membership_screen.dart';
import 'package:netsales/features/reports/presentation/screens/operational_reports_screen.dart';
import 'package:netsales/features/requests/presentation/screens/network_supply_requests_review_screen.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/network_workspace_dashboard.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';

class NetworkWorkspaceShell extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final navItems = [
        const WorkspaceNavItem(
          label: 'الرئيسية',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          content: NetworkWorkspaceDashboard(),
        ),
        const WorkspaceNavItem(
          label: 'الطلبات',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          content: NetworkSupplyRequestsReviewScreen(embedded: true),
        ),
        WorkspaceNavItem(
          label: 'نقاط البيع',
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront_rounded,
          content: NetworkPosDirectoryScreen(
            networkId: controller.selectedNetworkId.value,
            embedded: true,
          ),
        ),
        const WorkspaceNavItem(
          label: 'المالية والديون',
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
          content: NetworkFinanceWorkspaceHub(),
        ),
        const WorkspaceNavItem(
          label: 'الاشتراك والفوترة',
          icon: Icons.workspace_premium_outlined,
          activeIcon: Icons.workspace_premium_rounded,
          content: BillingWorkspaceScreen(),
        ),
        const WorkspaceNavItem(
          label: 'تقارير الاشتراكات',
          icon: Icons.query_stats_outlined,
          activeIcon: Icons.query_stats_rounded,
          content: BillingReportsScreen(),
        ),
        const WorkspaceNavItem(
          label: 'فريق العمل',
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups_rounded,
          content: MembershipScreen(),
        ),
        WorkspaceNavItem(
          label: 'التقارير',
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics_rounded,
          content: OperationalReportsScreen(
            networkId: controller.selectedNetworkId.value,
            isNetworkWorkspace: true,
            organizationName: controller.selectedNetwork?.networkName,
            logoUrl: controller.selectedNetwork?.networkProfileLogoUrl,
          ),
        ),
      ];

      // القائمة المقلصة للتبويبات الأساسية الأربعة على أجهزة الجوال
      final mobileNavItems = [
        navItems[0], // الرئيسية
        navItems[1], // طلبات التوريد
        navItems[2], // نقاط البيع
        navItems[3], // المالية والديون
      ];

      final isAppBarLoading =
          controller.isLoading.value && controller.selectedNetwork == null;
      final networkTitle =
          controller.selectedNetwork?.networkName ?? 'لوحة الشبكة';

      return AdaptiveWorkspaceScaffold(
        appBar: WorkspaceAppBar(
          title: networkTitle,
          workspace: AppWorkspace.network,
          isLoading: isAppBarLoading,
          rolePresentation: controller.rolePresentation,
          userProfileLogo: controller.userProfileLogo,
          userInitials: TextFormatter.avatarInitials(
            controller.userName,
            maxChars: 2,
          ),
        ),
        items: navItems,
        mobileItems: mobileNavItems,
        currentIndex: controller.selectedNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
        centerActionIcon: Icons.add_rounded,
        centerActionTooltip: 'إصدار فاتورة بيع جديدة',
        onCenterActionTap: () {
          Get.toNamed<dynamic>(AppRoutes.networkCreateSaleInvoice);
        },
      );
    });
  }
}
