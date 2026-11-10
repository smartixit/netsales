import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/network_wallet_log_item_row.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_selector_skeleton.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_log_entry_skeleton.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
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
              _NetworkWalletSelector(controller: controller),
              Obx(() {
                if (!controller.canTransfer) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    children: [
                      CustomButton.primary(
                        text: 'تحويل رصيد إلى نقطة بيع',
                        prefix: Icons.swap_horiz_rounded,
                        width: double.infinity,
                        onPressed: controller.openTransferSheet,
                      ),
                      AppSpacing.vXs,
                      CustomButton.outline(
                        text: 'إدراج قيد مالي مباشر بمحفظة الشبكة',
                        prefix: Icons.account_balance_wallet_outlined,
                        width: double.infinity,
                        onPressed: controller.openManualTransactionSheet,
                      ),
                    ],
                  ),
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

                  if (controller.logs.isEmpty &&
                      controller.logsErrorMessage.value != null) {
                    final walletId = controller.selectedWallet.value?.walletId;
                    return CustomErrorState.compact(
                      title: 'تعذر تحميل دفتر الأستاذ',
                      subtitle: controller.logsErrorMessage.value,
                      onRetry: walletId == null
                          ? null
                          : () => controller.loadWalletLogs(
                              walletId,
                              isRefresh: true,
                            ),
                    );
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
                          controller.logsErrorMessage.value == null &&
                          !controller.isLoadingMoreLogs.value) {
                        controller.loadMoreLogs();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount:
                          controller.logs.length +
                          (controller.hasMoreLogs ||
                                  (controller.logsErrorMessage.value != null &&
                                      controller.logs.isNotEmpty)
                              ? 1
                              : 0),
                      separatorBuilder: (context, index) => AppSpacing.vXs,
                      itemBuilder: (context, index) {
                        if (index == controller.logs.length) {
                          if (controller.logsErrorMessage.value != null) {
                            return CustomErrorState.compact(
                              title: 'تعذر تحميل المزيد من الحركات',
                              subtitle: controller.logsErrorMessage.value,
                              onRetry: controller.hasMoreLogs
                                  ? controller.loadMoreLogs
                                  : () => controller.loadWalletLogs(
                                      controller.selectedWallet.value!.walletId,
                                      isRefresh: true,
                                    ),
                            );
                          }
                          return const WalletLogEntrySkeleton();
                        }
                        if (index > controller.logs.length) {
                          return const SizedBox.shrink();
                        }

                        final log = controller.logs[index];
                        return NetworkWalletLogItemRow(log: log, index: index);
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

class _NetworkWalletSelector extends StatelessWidget {
  const _NetworkWalletSelector({required this.controller});

  final NetworkWalletDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoading.value && controller.wallets.isEmpty) {
        return SizedBox(
          height: 142.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                WalletSelectorSkeleton(width: 264.w, height: 128.h),
                AppSpacing.hSm,
                WalletSelectorSkeleton(width: 264.w, height: 128.h),
              ],
            ),
          ),
        );
      }

      if (controller.wallets.isEmpty &&
          controller.walletsErrorMessage.value != null) {
        return SizedBox(
          height: 132.h,
          child: CustomErrorState.compact(
            title: 'تعذر تحميل المحافظ',
            subtitle: controller.walletsErrorMessage.value,
            onRetry: controller.loadWallets,
          ),
        );
      }

      if (controller.wallets.isEmpty) {
        return SizedBox(
          height: 132.h,
          child: CustomEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد محافظ',
            subtitle: 'لم يتم العثور على أي محفظة شبكة مصرح بها.',
            actionLabel: 'إعادة المحاولة',
            onAction: controller.loadWallets,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.walletsErrorMessage.value != null) ...[
            CustomErrorState.compact(
              title: 'تعذر تحديث قائمة المحافظ',
              subtitle: controller.walletsErrorMessage.value,
              onRetry: controller.loadWallets,
            ),
            AppSpacing.vXs,
          ],
          if (controller.walletsLoadMoreErrorMessage.value != null) ...[
            CustomErrorState.compact(
              title: 'تعذر تحميل بقية المحافظ',
              subtitle: controller.walletsLoadMoreErrorMessage.value,
              onRetry: controller.loadMoreWallets,
            ),
            AppSpacing.vXs,
          ],
          SizedBox(
            height: 142.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.horizontal &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 140.w &&
                    controller.hasMoreWallets &&
                    controller.walletsLoadMoreErrorMessage.value == null &&
                    !controller.isLoadingMoreWallets.value) {
                  controller.loadMoreWallets();
                }
                return false;
              },
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount:
                    controller.wallets.length +
                    (controller.hasMoreWallets &&
                            controller.walletsLoadMoreErrorMessage.value == null
                        ? 1
                        : 0),
                separatorBuilder: (context, index) => AppSpacing.hSm,
                itemBuilder: (context, index) {
                  if (index == controller.wallets.length) {
                    return WalletSelectorSkeleton(width: 264.w, height: 128.h);
                  }

                  final wallet = controller.wallets[index];
                  final isSelected =
                      controller.selectedWallet.value?.walletId ==
                      wallet.walletId;

                  return SizedBox(
                    width: 264.w,
                    child: CustomInteractiveBounce(
                      onTap: () => controller.selectWallet(wallet),
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.06)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.5),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    wallet.networkName ??
                                        'شبكة #${wallet.networkId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                AppSpacing.hXs,
                                CustomStatusBadge(
                                  label: wallet.status ? 'نشطة' : 'مجمدة',
                                  tone: wallet.status
                                      ? SemanticTone.success
                                      : SemanticTone.danger,
                                ),
                              ],
                            ),
                            Text(
                              'الرصيد المالي المتاح',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              AmountFormatter.format(
                                wallet.walletBalance.toString(),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleLarge.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
