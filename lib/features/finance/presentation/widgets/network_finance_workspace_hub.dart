import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// مركز دخول عمليات المالية في مساحة عمل مزود الشبكة.
/// لا يجري أي حساب أو تحميل مالي؛ يوجّه إلى الشاشات التي تجلب بياناتها من API.
class NetworkFinanceWorkspaceHub extends GetView<NetworkWorkspaceController> {
  const NetworkFinanceWorkspaceHub({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: colors.onPrimary,
                    size: 28,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز العمليات المالية',
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        'إدارة محافظ الشبكة، تحصيل مديونيات نقاط البيع، ومراجعة سندات السداد.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vXl,
          _NetworkFinanceSnapshot(controller: controller),
          AppSpacing.vXl,
          Text(
            'الإجراءات المالية',
            style: AppTypography.titleMedium.copyWith(color: colors.onSurface),
          ),
          AppSpacing.vXs,
          Text(
            'اختر الإجراء المطلوب. الأرصدة والتسويات النهائية مصدرها الخادم.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (PermissionService.to.can(AppPermissions.posWalletsCreate) ||
              PermissionService.to.can(AppPermissions.posWalletsManage)) ...[
            AppSpacing.vLg,
            SizedBox(
              width: double.infinity,
              child: CustomButton.primary(
                text: 'تحصيل سداد مديونية نقطة بيع',
                prefix: Icons.payments_rounded,
                size: AppButtonSize.large,
                width: double.infinity,
                onPressed: () => Get.toNamed<void>(AppRoutes.repaymentCollection),
              ),
            ),
          ],
          AppSpacing.vMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final actionWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.md) / 2;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: actionWidth,
                    child: _FinanceHubAction(
                      icon: Icons.receipt_long_outlined,
                      title: 'المصروفات التشغيلية',
                      subtitle: 'سندات الصرف والبنود والمرفقات',
                      onTap: () =>
                          Get.toNamed<void>(AppRoutes.operatingExpenses),
                    ),
                  ),
                  if (PermissionService.to.can(AppPermissions.networksReport))
                    SizedBox(
                      width: actionWidth,
                      child: _FinanceHubAction(
                        icon: Icons.analytics_outlined,
                        title: 'التقارير وكشف اشتراك المنصة',
                        subtitle: 'تقارير الشبكة وكشف فواتير ودفعات الاشتراك',
                        onTap: () =>
                            Get.toNamed<void>(AppRoutes.networkReports),
                      ),
                    ),
                  SizedBox(
                    width: actionWidth,
                    child: _FinanceHubAction(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'محفظة الشبكة',
                      subtitle: 'الرصيد والحركات ودفتر الأستاذ',
                      onTap: () =>
                          Get.toNamed<void>(AppRoutes.networkWalletStatement),
                    ),
                  ),
                  SizedBox(
                    width: actionWidth,
                    child: _FinanceHubAction(
                      icon: Icons.receipt_long_outlined,
                      title: 'سجل سندات السداد',
                      subtitle: 'تصفية السندات ومراجعة حالاتها',
                      onTap: () =>
                          Get.toNamed<void>(AppRoutes.repaymentHistory),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FinanceHubAction extends StatelessWidget {
  const _FinanceHubAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomButton.outline(
      onPressed: onTap,
      width: double.infinity,
      height: 88,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      foregroundColor: colors.onSurface,
      borderColor: colors.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.onPrimaryContainer, size: 21),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hXs,
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _NetworkFinanceSnapshot extends StatelessWidget {
  const _NetworkFinanceSnapshot({required this.controller});

  final NetworkWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) {
        if (controller.errorMessage.value != null) {
          return CustomErrorState.boxed(
            title: 'تعذر تحميل الملخص المالي',
            subtitle: controller.errorMessage.value,
            onRetry: controller.loadWorkspace,
          );
        }
        if (controller.isLoading.value) {
          return const CustomSkeletonFeed(itemCount: 2, cardHeight: 92);
        }
        return const SizedBox.shrink();
      }
      final metrics = overview.metrics;
      final cards = <Widget>[];
      final wallet = metrics['wallet'];
      if (wallet is Map<String, dynamic>) {
        cards.add(
          _FinanceSnapshotCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'رصيد محفظة الشبكة',
            value: AmountFormatter.format(overview.amount('wallet', 'balance')),
          ),
        );
      }
      if (metrics.containsKey('sales')) {
        cards.add(
          _FinanceSnapshotCard(
            icon: Icons.receipt_long_rounded,
            label: 'مبيعات الفترة',
            value: AmountFormatter.format(
              overview.amount('sales', 'total_amount'),
            ),
          ),
        );
        cards.add(
          _FinanceSnapshotCard(
            icon: Icons.pending_actions_rounded,
            label: 'المبالغ المتبقية على الفواتير',
            value: AmountFormatter.format(
              overview.amount('sales', 'outstanding_amount'),
            ),
          ),
        );
        cards.add(
          _FinanceSnapshotCard(
            icon: Icons.payments_rounded,
            label: 'المبالغ المحصلة',
            value: AmountFormatter.format(
              overview.amount('sales', 'paid_amount'),
            ),
          ),
        );
      }
      if (metrics.containsKey('expenses')) {
        cards.add(
          _FinanceSnapshotCard(
            icon: Icons.trending_down_rounded,
            label: 'مصروفات الشبكة خلال الفترة',
            value: AmountFormatter.format(
              overview.amount('expenses', 'total_amount'),
            ),
          ),
        );
      }
      if (cards.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: AppRadius.lgRadius,
          ),
          child: Text(
            'لا تتوفر مؤشرات مالية لهذا الحساب وفق صلاحياته الحالية.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        );
      }
      final columns = MediaQuery.sizeOf(context).width < 600 ? 1 : 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوضع المالي للشبكة',
            style: AppTypography.titleMedium.copyWith(color: colors.onSurface),
          ),
          AppSpacing.vXs,
          Text(
            'قيم مباشرة غيّر الفترة من لوحة الرئيسية لتحديث مؤشرات الفترة.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = AppSpacing.sm;
              final itemWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: cards
                    .map((card) => SizedBox(width: itemWidth, child: card))
                    .toList(growable: false),
              );
            },
          ),
        ],
      );
    });
  }
}

class _FinanceSnapshotCard extends StatelessWidget {
  const _FinanceSnapshotCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
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
