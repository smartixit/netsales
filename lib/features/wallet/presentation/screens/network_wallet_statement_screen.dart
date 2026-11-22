import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/wallet/presentation/controllers/network_wallet_statement_controller.dart';
import 'package:netsales/features/wallet/presentation/widgets/network_wallet_hero_card.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_filter_ribbon.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_ledger_tile.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// شاشة كشف حساب ودفتر أستاذ خزينة مزود الشبكة (Network Wallet Statement Screen)
///
/// شاشة تنفيذية للقراءة والمراقبة المالية فقط، خالية من أي دوال مساعدة خاصة.
class NetworkWalletStatementScreen
    extends GetView<NetworkWalletStatementController> {
  const NetworkWalletStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBarTitle: 'دفتر أستاذ الخزينة',
      showBackButton: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CustomStateView.loading(
            skeleton: CustomStateSkeleton(
              layout: CustomStateSkeletonLayout.list,
              itemCount: 4,
            ),
          );
        }

        if (controller.errorMessage.value != null &&
            controller.wallet.value == null) {
          return CustomStateView.error(
            title: 'تعذر تحميل بيانات الخزينة',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: () => controller.loadWalletAndLogs(),
          );
        }

        final wallet = controller.wallet.value;
        if (wallet == null) {
          return const CustomStateView.empty(
            title: 'لم يتم العثور على محفظة الخزينة',
            subtitle: 'المحفظة المالية للشبكة غير مهيأة أو تم تعطيلها مؤقتاً.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadWalletAndLogs(isRefresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200 &&
                  controller.hasMore.value &&
                  !controller.isLoadingMore.value) {
                controller.loadMoreLogs();
              }
              return false;
            },
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                // 1. بطاقة خزينة الشبكة التنفيذية
                NetworkWalletHeroCard(
                  wallet: wallet,
                  onRefresh: () =>
                      controller.loadWalletAndLogs(isRefresh: true),
                ),
                SizedBox(height: AppSpacing.md),

                // 2. شريط البحث والفلترة الموحد
                PosWalletFilterRibbon(controller: controller),
                SizedBox(height: AppSpacing.md),

                // 3. قائمة قيود دفتر أستاذ الخزينة
                if (controller.logs.isEmpty)
                  const CustomStateView.empty(
                    title: 'لا توجد قيود مالية مسجلة',
                    subtitle: 'لم يتم العثور على أي حركات تطابق معايير التصفية الحالية.',
                  )
                else ...[
                  ...controller.logs.map(
                    (log) =>
                        PosWalletLedgerTile(key: ValueKey(log.logId), log: log),
                  ),
                  CustomCursorLoadMore(
                    hasMore: controller.hasMore.value,
                    isLoading: controller.isLoadingMore.value,
                    error: null,
                    onPressed: controller.loadMoreLogs,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
