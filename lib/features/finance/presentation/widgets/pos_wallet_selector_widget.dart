import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/pos_dual_wallet_card.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_selector_skeleton.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';

/// مكون تحديد محفظة نقطة البيع في لوحة المالية (POS Wallet Selector)
class PosWalletSelectorWidget extends StatelessWidget {
  const PosWalletSelectorWidget({super.key, required this.controller});

  final PosWalletDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.wallets.isEmpty) {
        return SizedBox(
          height: 194.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                WalletSelectorSkeleton(width: 310.w, height: 180.h),
                AppSpacing.hSm,
                WalletSelectorSkeleton(width: 310.w, height: 180.h),
              ],
            ),
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
                itemCount:
                    controller.wallets.length +
                    (controller.hasMoreWallets &&
                            controller.walletsLoadMoreErrorMessage.value == null
                        ? 1
                        : 0),
                separatorBuilder: (context, index) => AppSpacing.hSm,
                itemBuilder: (context, index) {
                  if (index == controller.wallets.length) {
                    return WalletSelectorSkeleton(width: 310.w, height: 180.h);
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

