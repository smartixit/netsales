import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/home/domain/entities/dashboard_quick_action_entity.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_distribution_performance.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_header_section.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_multi_entity_deck.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_quick_shortcuts_bar.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_recent_ledger_feed.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_sales_trend_chart.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_skeleton_view.dart';
import 'package:netsales/features/home/presentation/widgets/dashboard/dashboard_urgent_approvals_hub.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_voucher_request_sheet.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/foundation/home_tab_shell.dart';

/// ============================================================================
/// واجهة لوحة القيادة التجميعية الرشيقة (DashboardView)
/// ============================================================================
/// تمثل التجميع الرشيق (Lean Composite Assembler) لودجات لوحة القيادة التنفيذية
/// وفق ميثاق الهندسة النظيفة الصارم، مع هيكل بصري عالمي لإدارة مبيعات التوزيع.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final List<DashboardQuickActionEntity> actions = [
      DashboardQuickActionEntity(
        icon: Icons.receipt_long_outlined,
        label: 'فاتورة مبيعات',
        gradientColors: [
          colors.onPrimaryFixed,
          colors.primary,
        ],
        permission: AppPermissions.salesCreate,
        onTap: () => CreateSaleInvoiceSheet.show(context),
      ),
      DashboardQuickActionEntity(
        icon: Icons.inventory_2_outlined,
        label: 'توريد كروت',
        gradientColors: [
          colors.onInfoContainer,
          colors.info,
        ],
        permission: AppPermissions.voucherPackagesCreate,
        onTap: () => CreateVoucherRequestSheet.show(context),
      ),
      DashboardQuickActionEntity(
        icon: Icons.storefront_outlined,
        label: 'نقاط التوزيع',
        gradientColors: [
          colors.onErrorContainer,
          colors.error,
        ],
        permission: AppPermissions.posView,
        onTap: controller.navigateToPartners,
      ),

      DashboardQuickActionEntity(
        icon: Icons.account_balance_wallet_outlined,
        label: 'إدارة المحفظة',
        gradientColors: [
          colors.onWarningContainer,
          colors.warning,
        ],
        permission: AppPermissions.networkWalletsView,
        onTap: controller.navigateToWallets,
      ),
    ];

    return Obx(() {
      // 1. حالة التحميل الأولي أو السحب للتحديث عبر الهيكل التشكيلي الموحد (Skeleton Shimmer)
      if ((controller.isLoading.value && controller.overview.value == null) ||
          controller.isRefreshing.value) {
        return const DashboardSkeletonView();
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة (الودجت الموحد §26)
      if (controller.errorMessage.isNotEmpty &&
          controller.overview.value == null) {
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

      final isMasked = controller.isPrivacyMasked.value;

      // 3. حالة النجاح وعرض الشاشة التنفيذية المتكاملة
      return HomeTabShell.scrollable(
        onRefresh: () => controller.loadDashboard(isRefresh: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. منصة بطاقات الكيانات الشبكية المستقلة (Multi-Entity Horizon Deck)
            DashboardMultiEntityDeck(
              controller: controller,
              onActionTap: controller.navigateToWallets,
            ),

            AppSpacing.vLg,

            // 6. منصة العمليات والإجراءات السريعة
            DashboardQuickShortcutsBar(actions: actions),

            AppSpacing.vLg,

            // 4. مركز الاعتمادات والعمليات التشغيلية العاجلة
            DashboardUrgentApprovalsHub(controller: controller),

            AppSpacing.vLg,

            // 2. شريط النطاق الزمني والتحليلات التنفيذية
            DashboardHeaderSection(controller: controller),

            AppSpacing.vMd,

            // 3. المخطط البياني الانسيابي لحجم المبيعات والتوزيع (Sales & Distribution Chart)
            DashboardSalesTrendChart(controller: controller),

            AppSpacing.vLg,

            // 5. مصفوفة أداء وتغطية التوزيع الميداني (Bento Distribution Performance)
            DashboardDistributionPerformance(controller: controller),

            AppSpacing.vLg,

            // 7. سجل العمليات الميدانية والتحصيل المباشر
            DashboardRecentLedgerFeed(
              activities: overview.recentActivities,
              isMasked: isMasked,
            ),
          ],
        ),
      );
    });
  }
}
