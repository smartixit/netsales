import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/pos_dual_wallet_card.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_selector_skeleton.dart';
import 'package:netsales/features/finance/presentation/widgets/pos_wallet_log_item_row.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_log_entry_skeleton.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class PosWalletDashboardScreen extends GetView<PosWalletDashboardController> {
  const PosWalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('محافظ نقطة البيع والائتمان')),
      body: RefreshIndicator(
        onRefresh: controller.loadWallets,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحافظ التشغيلية المعتمدة (نقدي / ائتماني)',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              _buildWalletSelector(context),
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
                      subtitle: 'لم تسجل أي قيود أو حركات إيداع/سحب لهذه المحفظة بعد.',
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
                        return PosWalletLogItemRow(
                          log: controller.logs[index],
                          index: index,
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

  Widget _buildWalletSelector(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.wallets.isEmpty) {
        return SizedBox(
          height: 188.h,
          child: const CustomSkeletonFeed(
            itemCount: 1,
            cardHeight: 170,
            shrinkWrap: true,
          ),
        );
      }

      if (controller.wallets.isEmpty &&
          controller.walletsErrorMessage.value != null) {
        return SizedBox(
          height: 160.h,
          child: CustomErrorState.compact(
            title: 'تعذر تحميل المحافظ',
            subtitle: controller.walletsErrorMessage.value,
            onRetry: controller.loadWallets,
          ),
        );
      }

      if (controller.wallets.isEmpty) {
        return SizedBox(
          height: 160.h,
          child: CustomEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد محافظ',
            subtitle: 'لم يتم العثور على أي محفظة مرتبطة بنقطة البيع.',
            actionLabel: 'إعادة المحاولة',
            onAction: controller.loadWallets,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.walletsLoadMoreErrorMessage.value != null) ...[
            CustomErrorState.compact(
              title: 'تعذر تحميل بقية المحافظ',
              subtitle: controller.walletsLoadMoreErrorMessage.value,
              onRetry: controller.loadMoreWallets,
            ),
            AppSpacing.vXs,
          ],
          SizedBox(
            height: 194.h,
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
                itemCount: controller.wallets.length +
                    (controller.hasMoreWallets &&
                            controller.walletsLoadMoreErrorMessage.value == null
                        ? 1
                        : 0),
                separatorBuilder: (context, index) => AppSpacing.hSm,
                itemBuilder: (context, index) {
                  if (index == controller.wallets.length) {
                    return WalletSelectorSkeleton(
                      width: 310.w,
                      height: 180.h,
                    );
                  }

                  final wallet = controller.wallets[index];
                  return SizedBox(
                    width: 310.w,
                    child: PosDualWalletCard(
                      wallet: wallet,
                      isSelected:
                          controller.selectedWallet.value?.walletId ==
                          wallet.walletId,
                      onTap: () => controller.selectWallet(wallet),
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
