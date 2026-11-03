import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';

/// هيكل مساحة عمل مزود الشبكة (Network Workspace Shell)
class NetworkWorkspaceShell extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final navItems = [
      WorkspaceNavItem(
        label: 'الرئيسية',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hub_rounded, size: 64, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'مساحة عمل مزود الشبكة',
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة التوزيع بالجملة، باقات الكروت، واعتماد طلبات التوريد لنقاط البيع',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      const WorkspaceNavItem(
        label: 'طلبات التوريد',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        content: CustomEmptyState(
          title: 'طلبات التوريد بالجملة',
          subtitle: 'سيتم تفعيل استعراض واعتماد وتعديل طلبات التوريد في المرحلة المخصصة لها',
        ),
      ),
      const WorkspaceNavItem(
        label: 'نقاط البيع',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: CustomEmptyState(
          title: 'دليل نقاط البيع المعتمدة',
          subtitle: 'إدارة روابط الشراكة، نسب الخصومات التعاقدية، وسقوف الائتمان',
        ),
      ),
      const WorkspaceNavItem(
        label: 'المالية والديون',
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        content: CustomEmptyState(
          title: 'المحفظة والتسويات المالية',
          subtitle: 'كشوف حسابات المحفظة والرقابة على مديونيات نقاط البيع',
        ),
      ),
    ];

    return Obx(() {
      return AdaptiveWorkspaceScaffold(
        appBar: const WorkspaceAppBar(
          title: 'لوحة التحكم',
          workspace: AppWorkspace.network,
        ),
        items: navItems,
        currentIndex: controller.selectedNavIndex.value,
        onIndexChanged: controller.onNavItemSelected,
      );
    });
  }
}
