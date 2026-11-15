import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_liquidity_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_network_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_sales_velocity_chart.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_welcome_hero_card.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';

class NetworkWorkspaceDashboard extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.overview.value == null) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 10.h,
            bottom: AppSpacing.xxl,
            left: AppBreakpoints.screenMargin(context),
            right: AppBreakpoints.screenMargin(context),
          ),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 140),
        );
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
              controller.errorMessage.value ??
              'لم تصل استجابة صالحة من الخادم.',
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
    final metrics = overview.metrics;

    return RefreshIndicator.adaptive(
      onRefresh: controller.loadWorkspace,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 10.h,
          bottom: AppSpacing.xxl,
          left: AppBreakpoints.screenMargin(context),
          right: AppBreakpoints.screenMargin(context),
        ),
        children: [
          // 1. كرت الترحيب القيادي الديناميكي
          ExecutiveWelcomeHeroCard(
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
            SizedBox(height: AppSpacing.md),
          ],

          // كاروسيل بطاقات الشبكات التابعة للمزود بأسلوب البطاقات المصرفية الفاخرة
          if (controller.networks.isNotEmpty) ...[
            _ProviderNetworksBankCardCarousel(
              controller: controller,
              overview: overview,
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // 2. كرت السيولة والعمليات السريعة (يظهر عند توفر بيانات المحفظة أو المبيعات)
          if (metrics.containsKey('wallet') ||
              metrics.containsKey('sales')) ...[
            ExecutiveLiquidityCard(overview: overview),
            SizedBox(height: AppSpacing.lg),
          ],

          // 3. منحنى وتيرة المبيعات والطلبات (يظهر إذا كان لدى المستخدم صلاحية عرض المبيعات)
          if (metrics.containsKey('sales')) ...[
            ExecutiveSalesVelocityChart(
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
              totalPendingCount:
                  int.tryParse(overview.count('requests', 'pending')) ??
                  overview.recentPendingRequests.length,
              onViewAll: () => controller.onNavItemSelected(1),
            ),
            SizedBox(height: AppSpacing.xl),
          ],

          // تذييل التوقيت الزمني الحقيقي
          // Text(
          //   'آخر تحديث للبيانات: ${DateFormatter.dateTime(DateTime.tryParse(overview.generatedAt) ?? DateTime.now())}',
          //   textAlign: TextAlign.center,
          //   style: AppTypography.labelSmall.copyWith(
          //     color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          //   ),
          // ),
          SizedBox(height: AppSpacing.huge),
          SizedBox(height: AppSpacing.huge),
        ],
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
          subtitle: isActive
              ? 'المحفظة تعمل وجاهزة للعمليات'
              : 'المحفظة غير نشطة',
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
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
    final isCash =
        saleTypeLabel.contains('نقد') || saleTypeLabel.contains('كاش');
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

/// كاروسيل بطاقات الشبكات التابعة للمزود المعتمد بأسلوب البطاقات المصرفية التنفيذية (VIP Bank Card Carousel).
class _ProviderNetworksBankCardCarousel extends StatelessWidget {
  const _ProviderNetworksBankCardCarousel({
    required this.controller,
    required this.overview,
  });

  final NetworkWorkspaceController controller;
  final NetworkWorkspaceOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final networks = controller.networks;
    final selectedId = controller.selectedNetworkId.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.hub_rounded, color: colors.primary, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'الشبكات التابعة لحسابك',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${networks.length} شبكات',
                  style: AppTypography.badgeText.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        CustomCarouselSlider<NetworkEntity>(
          items: networks,
          currentIndex: networks
              .indexWhere((n) => n.networkId == selectedId)
              .clamp(0, networks.length - 1),
          height: 205,
          viewportFraction: 0.88,
          itemBuilder: (context, network, index) {
            final isSelected = network.networkId == selectedId;
            final salesMetric = overview.metric('sales');
            final salesTotal = salesMetric?['total'];
            final salesValue = isSelected && salesTotal is num
                ? '${AmountFormatter.formatValue(salesTotal, decimalPlaces: 0)} YER'
                : '•••• YER';

            final posMetric = overview.metric('pos');
            final posTotal = posMetric?['total'];
            final posCount = isSelected && posTotal != null
                ? '$posTotal نقطة بيع'
                : 'وكلاء معتمدين';

            return ExecutiveNetworkCard(
              network: network,
              isSelected: isSelected,
              cardIndex: index,
              salesValue: salesValue,
              posCountText: posCount,
              onTap: () => controller.selectNetwork(network.networkId),
            );
          },
          onPageChanged: (index) {
            if (index >= 0 && index < networks.length) {
              controller.selectNetwork(networks[index].networkId);
            }
          },
        ),
      ],
    );
  }
}
