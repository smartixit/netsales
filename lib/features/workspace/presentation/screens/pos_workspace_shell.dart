import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';

/// هيكل مساحة عمل نقطة البيع (POS Workspace Shell)
class PosWorkspaceShell extends GetView<PosWorkspaceController> {
  const PosWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final navItems = [
      WorkspaceNavItem(
        label: 'الرئيسية',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 64, color: colors.secondary),
              const SizedBox(height: 16),
              Text(
                'مساحة عمل نقطة البيع',
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'طلب باقات الكروت بالجملة، إدارة المحفظة، ومتابعة سداد المديونيات للشبكات المزودة',
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
        label: 'طلب باقات',
        icon: Icons.add_shopping_cart_outlined,
        activeIcon: Icons.add_shopping_cart_rounded,
        content: CustomEmptyState(
          title: 'طلب باقات كروت بالجملة',
          subtitle: 'إنشاء طلبات التوريد بأسعار الخصم التعاقدي المعتمدة',
        ),
      ),
      const WorkspaceNavItem(
        label: 'فواتيري',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        content: CustomEmptyState(
          title: 'سجل فواتير المشتريات',
          subtitle: 'استعراض فواتير التوريد الصادرة ومستندات السداد النقدي والآجل',
        ),
      ),
      const WorkspaceNavItem(
        label: 'الرصيد والديون',
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet_rounded,
        content: CustomEmptyState(
          title: 'رصيد المحفظة والمديونيات',
          subtitle: 'متابعة سقف الائتمان وسداد الالتزامات المالية وفق نظام FIFO المعتمد',
        ),
      ),
    ];

    return Obx(() {
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
