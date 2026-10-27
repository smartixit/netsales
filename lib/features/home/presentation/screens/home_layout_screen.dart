import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        useSurfaceMesh: true,
        extendBodyBehindAppBar: true,
        extendBody: true,
        safeAreaTop: false,
        safeAreaBottom: false,
        appBar: HomeAppBar(controller: controller),
        body: Builder(
          builder: (bodyContext) {
            final mediaQuery = MediaQuery.of(bodyContext);
            final topPadding = mediaQuery.padding.top + 68.h;

            return MediaQuery(
              data: mediaQuery.copyWith(
                viewPadding: mediaQuery.viewPadding.copyWith(
                  bottom: mediaQuery.padding.bottom,
                ),
              ),
              child: Stack(
                children: [
                  // الحاوية متعددة التبويبات الممتدة بكامل الشاشة خلف الـ AppBar الزجاجي
                  Positioned.fill(
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

                  // شريط التنبيه اللحظي لقطع الاتصال الشبكي أسفل الـ AppBar الزجاجي
                  Positioned(
                    top: topPadding,
                    left: 0,
                    right: 0,
                    child: Obx(
                      () => CustomOfflineBanner(
                        isOffline: !controller.isOnline.value,
                      ),
                    ),
                  ),
                ],
              ),
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
