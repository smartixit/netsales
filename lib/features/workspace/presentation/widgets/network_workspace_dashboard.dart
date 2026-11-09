import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class NetworkWorkspaceDashboard extends GetView<NetworkWorkspaceController> {
  const NetworkWorkspaceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.overview.value == null) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 116);
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
          subtitle: controller.errorMessage.value ?? 'لم تصل استجابة صالحة من الخادم.',
          onRetry: () => controller.loadOverview(),
        );
      }
      return _DashboardContent(overview: overview);
    });
  }
}

class _DashboardContent extends GetView<NetworkWorkspaceController> {
  const _DashboardContent({required this.overview});

  final NetworkWorkspaceOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final columns = AppBreakpoints.kpiColumnsFor(context);
    return RefreshIndicator.adaptive(
      onRefresh: controller.loadWorkspace,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppBreakpoints.screenMargin(context)),
        children: [
          _NetworkIdentityPanel(
            name: overview.networkName,
            networkCount: controller.networks.length,
          ),
          if (controller.networks.length > 1) ...[
            AppSpacing.vMd,
            CustomDropdown<int>(
              label: 'الشبكة النشطة',
              rxValue: controller.selectedNetworkId,
              searchEnabled: controller.networks.length > 5,
              items: controller.networks
                  .map((network) => DropdownItem<int>(
                        value: network.networkId,
                        child: Text(network.networkName),
                      ))
                  .toList(growable: false),
              onChanged: controller.selectNetwork,
            ),
          ],
          AppSpacing.vXl,
          Row(
            children: [
              Expanded(
                child: Text(
                  'مؤشرات التشغيل',
                  style: AppTypography.titleLarge.copyWith(color: colors.onSurface),
                ),
              ),
              SizedBox(
                width: 138,
                child: CustomDropdown<String>(
                  label: 'الفترة',
                  rxValue: controller.selectedPeriod,
                  searchEnabled: false,
                  items: const [
                    DropdownItem(value: '7d', child: Text('7 أيام')),
                    DropdownItem(value: '30d', child: Text('30 يوماً')),
                    DropdownItem(value: '90d', child: Text('90 يوماً')),
                    DropdownItem(value: '12m', child: Text('12 شهراً')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.selectPeriod(value);
                  },
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          _MetricsGrid(overview: overview, columns: columns),
          AppSpacing.vXl,
          _SectionTitle(
            title: 'مركز العمليات',
            subtitle: 'اختصارات مباشرة للمهام اليومية في شبكتك.',
          ),
          AppSpacing.vMd,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _QuickAction(
                label: 'مراجعة طلبات التوريد',
                icon: Icons.fact_check_outlined,
                onTap: () => controller.onNavItemSelected(1),
              ),
              _QuickAction(
                label: 'نقاط البيع',
                icon: Icons.storefront_outlined,
                onTap: () => controller.onNavItemSelected(2),
              ),
              _QuickAction(
                label: 'كتالوج الباقات',
                icon: Icons.widgets_outlined,
                onTap: () => Get.toNamed<void>(AppRoutes.voucherPackagesCatalog),
              ),
              _QuickAction(
                label: 'فواتير الجملة',
                icon: Icons.receipt_long_outlined,
                onTap: () => Get.toNamed<void>(AppRoutes.wholesaleInvoices),
              ),
              _QuickAction(
                label: 'إصدار فاتورة',
                icon: Icons.add_card_rounded,
                onTap: () => Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice),
              ),
              _QuickAction(
                label: 'المالية والديون',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => controller.onNavItemSelected(4),
              ),
            ],
          ),
          if (overview.recentPendingRequests.isNotEmpty) ...[
            AppSpacing.vXl,
            _SectionTitle(
              title: 'طلبات بانتظار قرارك',
              subtitle: 'أحدث طلبات التوريد الواردة من نقاط البيع.',
              action: CustomButton.text(
                text: 'عرض الكل',
                onPressed: () => controller.onNavItemSelected(1),
              ),
            ),
            AppSpacing.vSm,
            ...overview.recentPendingRequests.map(
              (request) => _PendingRequestTile(request: request),
            ),
          ],
          AppSpacing.vLg,
          Text(
            'آخر تحديث: ${overview.generatedAt.replaceFirst('T', ' ').split('+').first}',
            textAlign: TextAlign.end,
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.overview, required this.columns});

  final NetworkWorkspaceOverviewEntity overview;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppBreakpoints.gridGutter(context);
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        final metrics = overview.metrics;
        final tiles = <Widget>[];

        if (metrics.containsKey('points_of_sale')) {
          tiles.add(
            _MetricCard(
              icon: Icons.storefront_rounded,
              title: 'نقاط البيع المرتبطة',
              value: overview.count('points_of_sale', 'total'),
              detail:
                  'نشطة ${overview.count('points_of_sale', 'active')} · غير نشطة ${overview.count('points_of_sale', 'inactive')}',
            ),
          );
        }
        if (metrics.containsKey('requests')) {
          tiles.add(
            _MetricCard(
              icon: Icons.inbox_rounded,
              title: 'طلبات التوريد',
              value: overview.count('requests', 'total'),
              detail:
                  'بانتظار المراجعة ${overview.count('requests', 'pending')}',
              highlighted: true,
            ),
          );
        }
        if (metrics.containsKey('packages')) {
          tiles.add(
            _MetricCard(
              icon: Icons.widgets_rounded,
              title: 'باقات الكتالوج',
              value: overview.count('packages', 'total'),
              detail: 'نشطة ${overview.count('packages', 'active')}',
            ),
          );
        }
        if (metrics.containsKey('sales')) {
          tiles.add(
            _MetricCard(
              icon: Icons.receipt_long_rounded,
              title: 'فواتير الفترة',
              value: overview.count('sales', 'invoice_count'),
              detail:
                  'إجمالي ${AmountFormatter.format(overview.amount('sales', 'total_amount'))}',
            ),
          );
        }
        if (metrics.containsKey('expenses')) {
          tiles.add(
            _MetricCard(
              icon: Icons.trending_down_rounded,
              title: 'مصروفات الشبكة',
              value: AmountFormatter.format(
                overview.amount('expenses', 'total_amount'),
              ),
              detail:
                  '${overview.count('expenses', 'count')} سند خلال الفترة',
            ),
          );
        }
        final wallet = metrics['wallet'];
        if (wallet is Map<String, dynamic>) {
          tiles.add(
            _MetricCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'رصيد محفظة الشبكة',
              value: AmountFormatter.format(
                overview.amount('wallet', 'balance'),
              ),
              detail: wallet['is_active'] == true
                  ? 'المحفظة نشطة'
                  : 'المحفظة غير نشطة',
              highlighted: true,
            ),
          );
        }

        if (tiles.isEmpty) {
          return const CustomEmptyState(
            icon: Icons.analytics_outlined,
            title: 'لا توجد مؤشرات متاحة لهذا الدور',
            subtitle:
                'لا يمتلك حسابك صلاحيات عرض مؤشرات التشغيل في هذه الشبكة.',
          );
        }

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

class _NetworkIdentityPanel extends StatelessWidget {
  const _NetworkIdentityPanel({required this.name, required this.networkCount});

  final String name;
  final int networkCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlRadius,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colors.primary, colors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.16),
              borderRadius: AppRadius.lgRadius,
            ),
            child: Icon(Icons.hub_rounded, color: colors.onPrimary, size: 28),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مساحة عمل مزود الشبكة',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(color: colors.onPrimary),
                ),
                Text(
                  networkCount == 1 ? 'إدارة عمليات شبكتك من مكان واحد' : '$networkCount شبكات مرتبطة بحسابك',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.86),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: highlighted
            ? colors.primary.withValues(alpha: 0.07)
            : colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: highlighted
              ? colors.primary.withValues(alpha: 0.24)
              : colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.11),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                AppSpacing.vXs,
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(color: colors.onSurface)),
                Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge.copyWith(color: colors.onSurface)),
              Text(subtitle, style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton.outline(
      text: label,
      prefix: icon,
      onPressed: onTap,
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request});

  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final requestId = request['request_id'];
    final requestUuid = request['request_uuid'];
    final posName = request['pos_name'];
    final saleTypeLabel = request['sale_type_label'];
    final totalAmount = request['request_total_amount'];
    final requestDate = request['request_date'];
    if (requestId is! num || requestUuid is! String ||
        posName is! String || saleTypeLabel is! String ||
        totalAmount is! String || requestDate is! String) {
      throw const FormatException('بيانات الطلب المعلق غير مكتملة.');
    }
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomButton.outline(
        width: double.infinity,
        onPressed: () => Get.toNamed<void>(
          AppRoutes.voucherRequestDetails,
          arguments: requestId.toInt(),
        ),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: colors.primary),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(posName, style: AppTypography.titleSmall.copyWith(color: colors.onSurface)),
                  Text(requestUuid, style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                  Text(requestDate, style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(saleTypeLabel, style: AppTypography.bodySmall.copyWith(color: colors.primary)),
                Text(
                  AmountFormatter.format(totalAmount),
                  style: AppTypography.titleSmall.copyWith(color: colors.onSurface),
                ),
              ],
            ),
            AppSpacing.hXs,
            Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
