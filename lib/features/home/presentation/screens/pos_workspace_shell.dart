import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/home/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_view.dart';
import 'package:netsales/features/more/presentation/screens/more_screen.dart';
import 'package:netsales/features/operations/presentation/screens/operations_screen.dart';
import 'package:netsales/features/partners/presentation/screens/partners_screen.dart';
import 'package:netsales/widgets/feedback/custom_offline_banner.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';
import 'package:netsales/widgets/navigations/double_back_exit_scope.dart';

/// ============================================================================
/// هيكل مساحة عمل نقطة البيع والوكيل (POS Workspace Shell)
/// ============================================================================
/// يوفر شريط تنقل سفلي، وقائمة إجراءات سريعة، وهيكل تبويبات مخصص لعمليات الشراء والتوريد.
class PosWorkspaceShell extends GetView<PosWorkspaceController> {
  const PosWorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackExitScope(
      onFallback: () async => controller.canPopTab(),
      child: CustomAppScaffold(
        useSurfaceMesh: true,
        extendBodyBehindAppBar: true,
        extendBody: true,
        safeAreaTop: false,
        safeAreaBottom: false,
        body: Builder(
          builder: (bodyContext) {
            final mediaQuery = MediaQuery.of(bodyContext);
            final appBarBottom = mediaQuery.padding.top;

            return Stack(
              children: [
                Positioned.fill(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.selectedIndex.value,
                      children: const [
                        // Tab 0: لوحة قيادة ومشتريات الوكيل (POS-01)
                        DashboardView(),

                        // Tab 1: طلبات التوريد وفواتير الشراء المستلمة (POS-03 / POS-05)
                        OperationsScreen(),

                        // Tab 2: دليل الشبكات المزودة المعتمدة والأسعار (POS-06)
                        PartnersScreen(),

                        // Tab 3: الحساب الجاري والمديونية وموظفو النقطة (POS-04 / POS-07)
                        MoreScreen(),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: appBarBottom,
                  left: 0,
                  right: 0,
                  child: Obx(
                    () => CustomOfflineBanner(
                      isOffline: !controller.isOnline.value,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: ColoredBox(
          color: Colors.transparent,
          child: Obx(
            () => CustomFloatingBottomNavBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeTab,
              items: controller.navItems,
              onCenterActionTap: controller.hasQuickActions
                  ? () => controller.onCenterFabPressed(context)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

