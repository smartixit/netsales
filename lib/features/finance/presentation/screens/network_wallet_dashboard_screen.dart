import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class NetworkWalletDashboardScreen
    extends GetView<NetworkWalletDashboardController> {
  const NetworkWalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('محافظ مزودي الشبكات ودفتر الأستاذ')),
      body: RefreshIndicator(
        onRefresh: controller.loadWallets,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحافظ التشغيلية للشبكة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Obx(() {
                if (controller.isLoading.value && controller.wallets.isEmpty) {
                  return const CustomSkeletonFeed(itemCount: 2);
                }

                if (controller.wallets.isEmpty) {
                  return CustomEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'لا توجد محافظ',
                    subtitle: 'لم يتم العثور على أي محفظة شبكة مصرح بها.',
                    actionLabel: 'إعادة المحاولة',
                    onAction: controller.loadWallets,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.wallets.length,
                  separatorBuilder: (context, index) => AppSpacing.vSm,
                  itemBuilder: (context, index) {
                    final wallet = controller.wallets[index];
                    final isSelected =
                        controller.selectedWallet.value?.walletId ==
                        wallet.walletId;

                    return CustomInteractiveBounce(
                      onTap: () => controller.selectWallet(wallet),
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.05)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.5),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.networkName ??
                                      'شبكة #${wallet.networkId}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppSpacing.vXs,
                                Text(
                                  'الرصيد المالي المتاح',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomStatusBadge(
                                  label: wallet.status ? 'نشطة' : 'مجمدة',
                                  tone: wallet.status
                                      ? SemanticTone.success
                                      : SemanticTone.danger,
                                ),
                                AppSpacing.vXs,
                                Text(
                                  AmountFormatter.format(
                                    wallet.walletBalance.toString(),
                                  ),
                                  style: AppTypography.titleLarge.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              AppSpacing.vLg,
              Text(
                'دفتر الأستاذ وحركات المحفظة المحددة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingLogs.value &&
                      controller.logs.isEmpty) {
                    return const CustomSkeletonFeed(itemCount: 3);
                  }

                  if (controller.logs.isEmpty) {
                    return CustomEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد حركات مالية',
                      subtitle: 'لم تسجل أي قيود دفتر أستاذ لهذه المحفظة بعد.',
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200 &&
                          controller.hasMoreLogs &&
                          !controller.isLoadingMoreLogs.value) {
                        controller.loadMoreLogs();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount:
                          controller.logs.length +
                          (controller.hasMoreLogs ? 1 : 0),
                      separatorBuilder: (context, index) => AppSpacing.vXs,
                      itemBuilder: (context, index) {
                        if (index == controller.logs.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.cardPadding),
                              child: CircularProgressIndicator(
                                color: colors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final log = controller.logs[index];
                        final isDeposit = log.logAmount >= 0;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? colors.surfaceContainerLowest
                                : colors.surfaceContainerHighest.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDeposit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isDeposit
                                    ? colors.primary
                                    : colors.error,
                                size: 18,
                              ),
                              AppSpacing.hSm,
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.logOperationLabel ??
                                          log.logOperation ??
                                          'حركة مالية',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (log.logStatement != null)
                                      Text(
                                        log.logStatement!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (log.logDate != null)
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    log.logDate!.substring(0, 10),
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  AmountFormatter.format(
                                    log.logAmount.abs().toString(),
                                  ),
                                  textAlign: TextAlign.end,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: isDeposit
                                        ? colors.primary
                                        : colors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
