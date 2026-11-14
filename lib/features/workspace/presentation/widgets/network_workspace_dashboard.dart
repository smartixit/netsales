import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NetworkWorkspaceDashboard extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.overview.value == null) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 140);
      }
      if (controller.errorMessage.value != null &&
          controller.overview.value == null) {
        return CustomErrorState.boxed(
          title: 'تعذر تحميل لوحة الشبكة',
          subtitle: controller.errorMessage.value,
          onRetry: controller.loadWorkspace,
        );
      }
      if (controller.networks.isEmpty) {
        return const CustomEmptyState(
          icon: Icons.hub_outlined,
          title: 'لا توجد شبكة مرتبطة بالحساب',
          subtitle: 'لا يمكن عرض مؤشرات مساحة العمل قبل توفر شبكة مصرح بها.',
        );
      }
      final overview = controller.overview.value;
      if (overview == null) {
        return CustomErrorState.boxed(
          title: 'بيانات لوحة الشبكة غير متاحة',
          subtitle:
              controller.errorMessage.value ?? 'لم تصل استجابة صالحة من الخادم.',
          onRetry: () => controller.loadOverview(),
        );
      }
      return _VipDashboardContent(overview: overview);
    });
  }
}

class _VipDashboardContent extends GetView<NetworkWorkspaceController> {
  const _VipDashboardContent({required this.overview});

  final NetworkWorkspaceOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = overview.metrics;

    return RefreshIndicator.adaptive(
      onRefresh: controller.loadWorkspace,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppBreakpoints.screenMargin(context),
          vertical: AppSpacing.md,
        ),
        children: [
          // 1. كرت الترحيب القيادي الديناميكي
          _ExecutiveWelcomeHeroCard(
            overview: overview,
            onPendingTap: () => controller.onNavItemSelected(1),
          ),
          SizedBox(height: AppSpacing.lg),

          // محدد الشبكة النشطة إذا كان المستخدم مرتبطاً بأكثر من شبكة
          if (controller.networks.length > 1) ...[
            CustomDropdown<int>(
              label: 'الشبكة النشطة للعمليات',
              rxValue: controller.selectedNetworkId,
              searchEnabled: controller.networks.length > 5,
              items: controller.networks
                  .map(
                    (network) => DropdownItem<int>(
                      value: network.networkId,
                      child: Text(network.networkName),
                    ),
                  )
                  .toList(growable: false),
              onChanged: controller.selectNetwork,
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // 2. كرت السيولة والعمليات السريعة (يظهر عند توفر بيانات المحفظة أو المبيعات)
          if (metrics.containsKey('wallet') || metrics.containsKey('sales')) ...[
            _HeroLiquidityVaultCard(overview: overview),
            SizedBox(height: AppSpacing.lg),
          ],

          // 3. منحنى وتيرة المبيعات والطلبات (يظهر إذا كان لدى المستخدم صلاحية عرض المبيعات)
          if (metrics.containsKey('sales')) ...[
            _SalesVelocityAreaChartCard(
              overview: overview,
              selectedPeriod: controller.selectedPeriod.value,
              onPeriodChanged: controller.selectPeriod,
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // 4. شبكة المؤشرات الديناميكية المبنية بنسبة 100% على الصلاحيات والبيانات القادمة من الباكيند
          _DynamicMetricsGrid(
            overview: overview,
            onPointsOfSaleTap: () => controller.onNavItemSelected(2),
            onRequestsTap: () => controller.onNavItemSelected(1),
            onPackagesTap: () =>
                Get.toNamed<void>(AppRoutes.voucherPackagesCatalog),
            onSalesTap: () => Get.toNamed<void>(AppRoutes.wholesaleInvoices),
            onExpensesTap: () => controller.onNavItemSelected(3),
            onWalletTap: () => controller.onNavItemSelected(3),
          ),
          SizedBox(height: AppSpacing.xl),

          // 5. شريط أحدث طلبات التوريد الواردة بانتظار الاعتماد
          if (overview.recentPendingRequests.isNotEmpty) ...[
            _LivePendingOrdersStream(
              requests: overview.recentPendingRequests,
              totalPendingCount: int.tryParse(
                    overview.count('requests', 'pending'),
                  ) ??
                  overview.recentPendingRequests.length,
              onViewAll: () => controller.onNavItemSelected(1),
            ),
            SizedBox(height: AppSpacing.xl),
          ],

          // تذييل التوقيت الزمني الحقيقي
          Text(
            'آخر تحديث للبيانات: ${DateFormatter.dateTime(DateTime.tryParse(overview.generatedAt) ?? DateTime.now())}',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. كرت الترحيب القيادي الديناميكي الخالي تماماً من أي بيانات ثابتة
// ============================================================================
class _ExecutiveWelcomeHeroCard extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final VoidCallback onPendingTap;

  const _ExecutiveWelcomeHeroCard({
    required this.overview,
    required this.onPendingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final hour = DateTime.now().hour;
    final greeting = (hour >= 4 && hour < 12) ? 'صباح الخير' : 'مساء الخير';
    final hasRequests = overview.metrics.containsKey('requests');
    final pendingCount = hasRequests
        ? int.tryParse(overview.count('requests', 'pending')) ?? 0
        : 0;

    final realFullName = user?.userFullName ?? 'المستخدم';
    final realRole = user?.role?.roleName ??
        user?.statusLabel ??
        (user?.isSuperAdmin == true ? 'مدير عام النظام' : 'مزود شبكة معتمد');
    final initials = TextFormatter.avatarInitials(realFullName, maxChars: 2);
    final todayStr = DateFormatter.fullDate(DateTime.now());

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : colors.outlineVariant.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.4 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الأفاتار الديناميكي مع نقطة النبض
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.secondary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(1.8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
                        color: isDark ? const Color(0xFF0E1522) : colors.surface,
                      ),
                      alignment: Alignment.center,
                      child: user?.userProfileLogo != null &&
                              user!.userProfileLogo!.isNotEmpty
                          ? CustomCachedImage.avatar(
                              url: user.userProfileLogo,
                              radius: 26.r,
                            )
                          : Text(
                              initials,
                              style: AppTypography.titleLarge.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: -1,
                    child: CustomPulsingIndicator(
                      color: colors.primary,
                      size: 6.r,
                      enablePing: true,
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.md),

              // الاسم والرتبة واسم الشبكة من الجلسة الحقيقية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                        ),
                        Text(
                          'جلسة تشغيل نشطة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      realFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          realRole,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            overview.networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : colors.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
          SizedBox(height: AppSpacing.md),

          // الشريط الأفقي: تاريخ اليوم الحقيقي + حالة الطلبات الحقيقية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ اليوم',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    todayStr,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (hasRequests)
                CustomInteractiveBounce(
                  onTap: onPendingTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(
                        alpha: isDark ? 0.12 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: colors.warning.withValues(
                          alpha: isDark ? 0.35 : 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPulsingIndicator(
                          color: colors.warning,
                          size: 5.r,
                          enablePing: pendingCount > 0,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pendingCount > 0 ? 'بانتظار قرارك' : 'حالة الطلبات',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.warning,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              pendingCount > 0
                                  ? '$pendingCount طلب توريد بانتظار الاعتماد'
                                  : 'لا توجد طلبات معلقة',
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.warning,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13.r,
                          color: colors.warning,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. كرت السيولة والعمليات المالية القيادية (بيانات حقيقية 100%)
// ============================================================================
class _HeroLiquidityVaultCard extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;

  const _HeroLiquidityVaultCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metrics = overview.metrics;

    final hasWallet = metrics.containsKey('wallet');
    final hasSales = metrics.containsKey('sales');
    final hasPos = metrics.containsKey('points_of_sale');

    final wallet = overview.metric('wallet');
    final balanceStr = hasWallet && wallet != null
        ? AmountFormatter.format(overview.amount('wallet', 'balance'))
        : (hasSales
            ? AmountFormatter.format(overview.amount('sales', 'total_amount'))
            : '0.00');

    final isWalletActive = wallet?['is_active'] == true;

    // قراءة نسبة النمو الحقيقية المحسوبة من الباكيند
    final salesMetric = overview.metric('sales');
    final rawGrowth = salesMetric?['growth_rate'];
    final double growthRate = (rawGrowth is num) ? rawGrowth.toDouble() : 0.0;
    final String growthText = growthRate > 0
        ? '+${growthRate.toStringAsFixed(1)}% نمو'
        : (growthRate < 0
            ? '${growthRate.toStringAsFixed(1)}% تراجع'
            : '0.0% استقرار');

    final paidAmountStr = hasSales
        ? AmountFormatter.format(overview.amount('sales', 'paid_amount'))
        : '0.00';
    final outstandingStr = hasSales
        ? AmountFormatter.format(overview.amount('sales', 'outstanding_amount'))
        : '0.00';

    final activePos = hasPos ? overview.count('points_of_sale', 'active') : '0';
    final totalPos = hasPos ? overview.count('points_of_sale', 'total') : '0';

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F1E19),
                  const Color(0xFF0D1726),
                  const Color(0xFF080D15),
                ]
              : [
                  const Color(0xFF047857),
                  const Color(0xFF065F46),
                  const Color(0xFF064E3B),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: isDark
              ? colors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.25 : 0.2),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    hasWallet ? 'صافي السيولة التشغيلية' : 'إجمالي المبيعات',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? colors.primary
                          : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hasSales) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.primary.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            growthRate >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 13.r,
                            color: isDark ? colors.primary : Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            growthText,
                            style: AppTypography.badgeText.copyWith(
                              color: isDark ? colors.primary : Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                hasWallet
                    ? (isWalletActive ? 'المحفظة نشطة' : 'المحفظة غير نشطة')
                    : 'محدث لحظياً',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? colors.onSurfaceVariant
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // الرصيد الرئيسي الحقيقي
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balanceStr,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 34.sp,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'ريال يمني',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? colors.primary : const Color(0xFFA7F3D0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // شريط المؤشرات الفرعية الحقيقية
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبيعات النقدية',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$paidAmountStr ر.ي',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32.h,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الديون المستحقة',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$outstandingStr ر.ي',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: const Color(0xFFFBBF24),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasPos) ...[
                  Container(
                    width: 1,
                    height: 32.h,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نقاط البيع',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$activePos / $totalPos متصلة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              color: const Color(0xFFA7F3D0),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // الأزرار السريعة الثلاثة
          Row(
            children: [
              Expanded(
                flex: 4,
                child: CustomInteractiveBounce(
                  onTap: () => Get.toNamed<void>(
                    AppRoutes.networkCreateSaleInvoice,
                  ),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: isDark ? colors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? colors.primary : Colors.white)
                              .withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18.r,
                          color: isDark
                              ? const Color(0xFF022C22)
                              : const Color(0xFF065F46),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'إصدار فاتورة جملة',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? const Color(0xFF022C22)
                                : const Color(0xFF065F46),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),

              Expanded(
                flex: 4,
                child: CustomInteractiveBounce(
                  onTap: () => Get.toNamed<void>(
                    AppRoutes.repaymentCollection,
                  ),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF131D2E)
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16.r,
                          color: const Color(0xFFA7F3D0),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'تحصيل دفعة',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),

              CustomInteractiveBounce(
                onTap: () => Get.toNamed<void>(
                  AppRoutes.networkWalletStatement,
                ),
                child: Container(
                  height: 46.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131D2E)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16.r,
                        color: const Color(0xFF93C5FD),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'كشف الحساب',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. منحنى وتيرة المبيعات الحقيقي الخالي من أي أرقام مصطنعة
// ============================================================================
class _SalesVelocityAreaChartCard extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const _SalesVelocityAreaChartCard({
    required this.overview,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final salesData = overview.metric('sales');
    final rawTrend = salesData?['trend'];
    final List<dynamic> trendList = (rawTrend is List) ? rawTrend : const [];

    final chartPoints = <_ChartPoint>[];
    for (int i = 0; i < trendList.length; i++) {
      final item = trendList[i];
      if (item is Map) {
        final date = item['date']?.toString() ?? '';
        final total = (item['total'] is num)
            ? (item['total'] as num).toDouble()
            : double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
        chartPoints.add(_ChartPoint(date: date, amount: total));
      }
    }

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'منحنى وتيرة المبيعات اليومية',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'حجم الفواتير الصادرة وسرعة التدفقات النقدية الفعلية',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF070A10)
                      : colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PeriodButton(
                      label: '7 أيام',
                      periodKey: '7d',
                      isSelected: selectedPeriod == '7d',
                      onTap: () => onPeriodChanged('7d'),
                    ),
                    _PeriodButton(
                      label: '30 يوماً',
                      periodKey: '30d',
                      isSelected: selectedPeriod == '30d',
                      onTap: () => onPeriodChanged('30d'),
                    ),
                    _PeriodButton(
                      label: '3 أشهر',
                      periodKey: '90d',
                      isSelected: selectedPeriod == '90d',
                      onTap: () => onPeriodChanged('90d'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // عرض المنحنى الحقيقي إن توفرت فواتير، أو عرض حالة واضحة خالية من التزوير
          if (chartPoints.isNotEmpty)
            SizedBox(
              height: 180.h,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: AxisLine(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  majorGridLines: MajorGridLines(
                    width: 0.8,
                    color: colors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: 'المبيعات',
                  format: 'point.x : point.y ر.ي',
                  textStyle: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                series: <CartesianSeries<_ChartPoint, String>>[
                  SplineAreaSeries<_ChartPoint, String>(
                    dataSource: chartPoints,
                    xValueMapper: (_ChartPoint point, _) => point.date,
                    yValueMapper: (_ChartPoint point, _) => point.amount,
                    color: colors.primary.withValues(alpha: 0.22),
                    borderColor: colors.primary,
                    borderWidth: 2.8,
                    splineType: SplineType.natural,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.35),
                        colors.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderColor: colors.surface,
                      borderWidth: 2,
                      color: colors.primary,
                      width: 6,
                      height: 6,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 100.h,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 30.r,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'لا توجد فواتير مبيعات مسجلة في هذه الفترة الزمنية ($selectedPeriod)',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartPoint {
  final String date;
  final double amount;
  const _ChartPoint({required this.date, required this.amount});
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final String periodKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.periodKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.badgeText.copyWith(
            color: isSelected ? Colors.white : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. شبكة المؤشرات الديناميكية الكاملة المبنية على الصلاحيات الحقيقية
// ============================================================================
class _DynamicMetricsGrid extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final VoidCallback onPointsOfSaleTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onPackagesTap;
  final VoidCallback onSalesTap;
  final VoidCallback onExpensesTap;
  final VoidCallback onWalletTap;

  const _DynamicMetricsGrid({
    required this.overview,
    required this.onPointsOfSaleTap,
    required this.onRequestsTap,
    required this.onPackagesTap,
    required this.onSalesTap,
    required this.onExpensesTap,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = overview.metrics;
    final tiles = <Widget>[];

    // مؤشر نقاط البيع
    if (metrics.containsKey('points_of_sale')) {
      final total = overview.count('points_of_sale', 'total');
      final active = overview.count('points_of_sale', 'active');
      final inactive = overview.count('points_of_sale', 'inactive');
      tiles.add(
        _VipKpiCard(
          title: 'نقاط البيع المرتبطة',
          badgeText: total,
          badgeColor: colors.primary,
          mainValue: total,
          unit: 'نقطة بيع',
          subtitle: 'نشطة $active · غير نشطة $inactive',
          subtitleColor: colors.primary,
          icon: Icons.storefront_rounded,
          onTap: onPointsOfSaleTap,
        ),
      );
    }

    // مؤشر طلبات التوريد
    if (metrics.containsKey('requests')) {
      final total = overview.count('requests', 'total');
      final pending = overview.count('requests', 'pending');
      tiles.add(
        _VipKpiCard(
          title: 'طلبات التوريد',
          badgeText: pending,
          badgeColor: colors.warning,
          mainValue: total,
          unit: 'طلب',
          subtitle: 'بانتظار المراجعة $pending',
          subtitleColor: colors.warning,
          icon: Icons.inbox_rounded,
          onTap: onRequestsTap,
        ),
      );
    }

    // مؤشر باقات الكتالوج
    if (metrics.containsKey('packages')) {
      final total = overview.count('packages', 'total');
      final active = overview.count('packages', 'active');
      tiles.add(
        _VipKpiCard(
          title: 'باقات الكتالوج',
          badgeText: total,
          badgeColor: colors.secondary,
          mainValue: total,
          unit: 'باقة',
          subtitle: 'باقات نشطة جاهزة للتوريد: $active',
          subtitleColor: colors.secondary,
          icon: Icons.widgets_rounded,
          onTap: onPackagesTap,
        ),
      );
    }

    // مؤشر فواتير المبيعات
    if (metrics.containsKey('sales')) {
      final invoiceCount = overview.count('sales', 'invoice_count');
      final totalSalesAmount = AmountFormatter.format(
        overview.amount('sales', 'total_amount'),
      );
      tiles.add(
        _VipKpiCard(
          title: 'فواتير الفترة',
          badgeText: invoiceCount,
          badgeColor: colors.primary,
          mainValue: totalSalesAmount,
          unit: 'ر.ي',
          subtitle: '$invoiceCount فاتورة مبيعات معتمدة',
          subtitleColor: colors.primary,
          icon: Icons.receipt_long_rounded,
          onTap: onSalesTap,
        ),
      );
    }

    // مؤشر المصروفات
    if (metrics.containsKey('expenses')) {
      final expenseCount = overview.count('expenses', 'count');
      final totalExpensesAmount = AmountFormatter.format(
        overview.amount('expenses', 'total_amount'),
      );
      tiles.add(
        _VipKpiCard(
          title: 'مصروفات الشبكة',
          badgeText: expenseCount,
          badgeColor: colors.error,
          mainValue: totalExpensesAmount,
          unit: 'ر.ي',
          subtitle: '$expenseCount سند موثق بالمصروفات',
          subtitleColor: colors.error,
          icon: Icons.trending_down_rounded,
          onTap: onExpensesTap,
        ),
      );
    }

    // مؤشر المحفظة
    final wallet = metrics['wallet'];
    if (wallet is Map<String, dynamic>) {
      final balance = AmountFormatter.format(
        overview.amount('wallet', 'balance'),
      );
      final isActive = wallet['is_active'] == true;
      tiles.add(
        _VipKpiCard(
          title: 'رصيد محفظة الشبكة',
          badgeText: isActive ? 'نشطة' : 'معطلة',
          badgeColor: isActive ? colors.primary : colors.error,
          mainValue: balance,
          unit: 'ر.ي',
          subtitle: isActive ? 'المحفظة تعمل وجاهزة للعمليات' : 'المحفظة غير نشطة',
          subtitleColor: isActive ? colors.primary : colors.error,
          icon: Icons.account_balance_wallet_rounded,
          onTap: onWalletTap,
        ),
      );
    }

    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final columns = isMobile ? 1 : (constraints.maxWidth < 950 ? 2 : 3);
        final gap = AppSpacing.md;
        final itemWidth = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles
              .map((tile) => SizedBox(width: itemWidth, child: tile))
              .toList(growable: false),
        );
      },
    );
  }
}

class _VipKpiCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final String mainValue;
  final String unit;
  final String subtitle;
  final Color subtitleColor;
  final IconData icon;
  final VoidCallback onTap;

  const _VipKpiCard({
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.mainValue,
    required this.unit,
    required this.subtitle,
    required this.subtitleColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerLow : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 18.r, color: badgeColor),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.badgeText.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  mainValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  unit,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: subtitleColor,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. شريط طلبات التوريد الحقيقية بانتظار الاعتماد
// ============================================================================
class _LivePendingOrdersStream extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final int totalPendingCount;
  final VoidCallback onViewAll;

  const _LivePendingOrdersStream({
    required this.requests,
    required this.totalPendingCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomPulsingIndicator(
                    color: colors.warning,
                    size: 6.r,
                    enablePing: true,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'أحدث طلبات التوريد بانتظار الاعتماد',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              CustomInteractiveBounce(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'معاينة الكل ($totalPendingCount)',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.r,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...requests.map((request) => _VipPendingOrderRow(request: request)),
        ],
      ),
    );
  }
}

class _VipPendingOrderRow extends StatelessWidget {
  final Map<String, dynamic> request;

  const _VipPendingOrderRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final requestId = request['request_id'];
    final posName = request['pos_name']?.toString() ?? 'نقطة بيع';
    final requestUuid = request['request_uuid']?.toString() ?? '';
    final saleTypeLabel = request['sale_type_label']?.toString() ?? 'نقد';
    final totalAmount = request['request_total_amount']?.toString() ?? '0.00';
    final isCash = saleTypeLabel.contains('نقد') || saleTypeLabel.contains('كاش');
    final initials = TextFormatter.avatarInitials(posName, maxChars: 2);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isCash
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isCash
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.info.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.titleSmall.copyWith(
                color: isCash ? colors.primary : colors.info,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'طلب #${requestUuid.split('-').first} • $saleTypeLabel',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${AmountFormatter.format(totalAmount)} ر.ي',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              CustomInteractiveBounce(
                onTap: () {
                  if (requestId is num) {
                    Get.toNamed<void>(
                      AppRoutes.voucherRequestDetails,
                      arguments: requestId.toInt(),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'مراجعة واعتماد',
                    style: AppTypography.badgeText.copyWith(
                      color: colors.primary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
