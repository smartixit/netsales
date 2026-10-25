import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_view.dart';
import 'package:netsales/features/home/presentation/widgets/home_app_bar.dart';
import 'package:netsales/widgets/feedback/custom_offline_banner.dart';
import 'package:netsales/features/operations/presentation/screens/operations_screen.dart';
import 'package:netsales/features/partners/presentation/screens/partners_screen.dart';
import 'package:netsales/features/more/presentation/screens/more_screen.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';
import 'package:netsales/widgets/navigations/double_back_exit_scope.dart';

/// ============================================================================
/// الشاشة الرئيسية المجمعة للتطبيق (HomeLayoutScreen)
/// ============================================================================
/// الهيكل الأساسي الحاوي لكافة التبويبات والمحمي بنظام الجلسات،
/// يعتمد المعمارية التركيبية الرشيقة بدون أي دوال مساعدة محلية.
class HomeLayoutScreen extends GetView<HomeLayoutController> {
  const HomeLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return DoubleBackExitScope(
      onFallback: () async => controller.canPopTab(),
      child: CustomAppScaffold(
        appBar: HomeAppBar(controller: controller),
        body: Column(
          children: [
            // شريط التنبيه اللحظي لقطع الاتصال الشبكي
            Obx(
              () => CustomOfflineBanner(isOffline: !controller.isOnline.value),
            ),

            // الحاوية متعددة التبويبات مع الحفاظ التام على الحالة (IndexedStack)
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    // Tab 0: لوحة القيادة والتوزيع (Dashboard)
                    DashboardView(),

                    // Tab 1: فواتير المبيعات وطلبات التوريد (Operations)
                    OperationsScreen(),

                    // Tab 2: شبكة الشركاء ونقاط التوزيع (Partners & Distribution)
                    PartnersScreen(),

                    // Tab 3: المحافظ والمالية والإعدادات (More & Financial Hub)
                    MoreScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Obx(
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
    );
  }
}
