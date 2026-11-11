import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/network_wallet_log_item_row.dart';
import 'package:netsales/features/finance/presentation/widgets/network_wallet_selector_widget.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_log_entry_skeleton.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

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
              NetworkWalletSelectorWidget(controller: controller),
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

