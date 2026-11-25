import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/wallet/presentation/controllers/pos_wallet_statement_controller.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_filter_ribbon.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_hero_card.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_ledger_tile.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_purchasing_power_gauge.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// شاشة حساب نقطة البيع وسجل حركاته.
class PosWalletStatementScreen extends GetView<PosWalletStatementController> {
  const PosWalletStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBarTitle: 'محفظة نقطة البيع',
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
            title: 'تعذر تحميل بيانات المحفظة',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: () => controller.loadWalletAndLogs(),
          );
        }

        final wallet = controller.wallet.value;
        if (wallet == null) {
          return const CustomStateView.empty(
            title: 'لم يتم العثور على المحفظة',
            subtitle: 'لا تتوفر بيانات حساب نقطة البيع المطلوب.',
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
                PosWalletHeroCard(wallet: wallet),
                SizedBox(height: AppSpacing.md),
                PosWalletPurchasingPowerGauge(wallet: wallet),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'سجل الحركات',
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'الحركات المالية المسجلة على هذا الحساب',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                PosWalletFilterRibbon(controller: controller),
                SizedBox(height: AppSpacing.md),
                if (controller.logs.isEmpty)
                  const CustomStateView.empty(
                    title: 'لا توجد حركات مسجلة',
                    subtitle:
                        'لا توجد حركات تطابق معايير البحث والتصفية الحالية.',
                  )
                else ...[
                  ...controller.logs.map(
                    (log) => PosWalletLedgerTile(
                      key: ValueKey(log.logId),
                      log: log,
                    ),
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
