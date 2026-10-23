import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_view.dart';
import 'package:netsales/features/home/presentation/widgets/home_app_bar.dart';
import 'package:netsales/widgets/feedback/custom_offline_banner.dart';
import 'package:netsales/widgets/feedback/custom_tab_placeholder.dart';
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
    final colors = context.colors;

    return DoubleBackExitScope(
      onFallback: () async => controller.canPopTab(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: HomeAppBar(controller: controller),
        body: Column(
          children: [
            // شريط التنبيه اللحظي لقطع الاتصال الشبكي
            Obx(
              () => CustomOfflineBanner(
                isOffline: !controller.isOnline.value,
              ),
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
                    CustomTabPlaceholder(
                      title: 'مركز مبيعات وتوريد الكروت',
                      subtitle:
                          'فواتير مبيعات كروت الشبكة لنقاط البيع ومتابعة طلبات التوريد والاعتماد',
                      icon: Icons.receipt_long_rounded,
                    ),

                    // Tab 2: شبكة الشركاء ونقاط التوزيع (Hub)
                    CustomTabPlaceholder(
                      title: 'شبكة الشركاء ونقاط التوزيع',
                      subtitle:
                          'إدارة نقاط البيع والوكلاء، شبكات الإنترنت، وباقات الكروت والخصومات',
                      icon: Icons.hub_rounded,
                    ),

                    // Tab 3: المحافظ والمالية والإعدادات (More)
                    CustomTabPlaceholder(
                      title: 'المحافظ والمالية والإعدادات',
                      subtitle:
                          'محافظ الشبكات ونقاط البيع، المصروفات التشغيلية، والدعم الفني',
                      icon: Icons.widgets_rounded,
                    ),
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
