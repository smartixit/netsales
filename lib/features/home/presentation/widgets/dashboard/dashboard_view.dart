import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_bento_grid.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_header_section.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_hero_liquidity_card.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_operational_radar.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_quick_shortcuts_bar.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_recent_operations_feed.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_skeleton_view.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';

/// ============================================================================
/// واجهة لوحة القيادة التجميعية الرشيقة (DashboardView)
/// ============================================================================
/// تمثل التجميع الرشيق (Lean Composite Assembler) لودجات لوحة القيادة
/// دون أي دوال مساعدة محلية، مع إدارة كاملة لحالات التحميل والخطأ والسحب للتحديث.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي عبر الهيكل التشكيلي الموحد (Skeleton Shimmer)
      if (controller.isLoading.value) {
        return const DashboardSkeletonView();
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة (الودجت الموحد §26)
      if (controller.errorMessage.isNotEmpty && controller.overview.value == null) {
        return CustomErrorState(
          title: 'تعذر تحميل لوحة القيادة',
          subtitle: controller.errorMessage.value,
          onRetry: () => controller.loadDashboard(),
        );
      }

      final overview = controller.overview.value;
      if (overview == null) {
        return const SizedBox.shrink();
      }

      // 3. حالة النجاح وعرض البيانات الكاملة
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadDashboard(isRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ResponsiveContentWrapper(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ترويسة الكيان ومنتقي الفترات
                  DashboardHeaderSection(controller: controller),

                  AppSpacing.vLg,

                  // 2. بطاقة السيولة المالية المركزية
                  DashboardHeroLiquidityCard(
                    liquidity: overview.liquidity,
                  ),

                  AppSpacing.vLg,

                  // 3. رادار التنبيهات والطلبات المعلقة (إن وجدت)
                  if (overview.alerts.isNotEmpty) ...[
                    DashboardOperationalRadar(
                      alerts: overview.alerts,
                    ),
                    AppSpacing.vLg,
                  ],

                  // 4. شريط الإجراءات والعمليات السريعة
                  const DashboardQuickShortcutsBar(),

                  AppSpacing.vLg,

                  // 5. شبكة بينتو للمؤشرات التحليلية
                  DashboardBentoGrid(kpis: overview.kpis),

                  AppSpacing.vLg,

                  // 6. شريط العمليات والحركات الأخيرة
                  DashboardRecentOperationsFeed(
                    activities: overview.recentActivities,
                  ),

                  // مسافة سفلية مريحة تعلو شريط التنقل العائم
                  AppSpacing.vHuge,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
