import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/wallets/presentation/controllers/pos_wallet_controller.dart';
import 'package:netsales/features/wallets/presentation/widgets/pos_network_selector_card.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_balance_hero_card.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_filter_bar.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_movement_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// شاشة كشف الحساب الجاري والمديونية لنقطة البيع (PosWalletStatementScreen) — POS-04
/// ============================================================================
/// تعرض الحساب الجاري المنفصل والمديونية لكل شبكة مزودة على حدة، مع الامتناع
/// التام عن جمع الأرصدة أو المديونيات بين الشبكات أو الحساب المحلي عبر الفواتير.
class PosWalletStatementScreen extends GetView<PosWalletController> {
  const PosWalletStatementScreen({super.key});

  static const List<Map<String, String>> _operationOptions = [
    {'key': 'ALL', 'label': 'كافة الحركات'},
    {'key': 'DEPOSIT', 'label': 'تغذية / سداد'},
    {'key': 'INVOICE_PAYMENT', 'label': 'شراء كروت'},
    {'key': 'WITHDRAW', 'label': 'سحوبات'},
    {'key': 'EXPENSE', 'label': 'مصروفات'},
    {'key': 'TRANSFER_TO_NETWORK', 'label': 'تحويل للشبكة'},
    {'key': 'TRANSFER_FROM_NETWORK', 'label': 'تحويل من الشبكة'},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كشف الحساب الجاري والمديونية',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'POS-04 • الذمم المالية والعلاقات الثنائية',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث البيانات',
            onPressed: () => controller.loadWalletAndLogsForSelectedNetwork(),
          ),
        ],
      ),
      body: Obx(() {
        final isLoadingNetworks = controller.isLoadingNetworks.value;
        final networks = controller.linkedNetworks;
        final selectedNet = controller.selectedNetwork.value;
        final wallet = controller.wallet.value;
        final logs = controller.logs;
        final isLoadingWallet = controller.isLoadingWallet.value;
        final isLoadingLogs = controller.isLoadingLogs.value;
        final isLoadingMore = controller.isLoadingMore.value;
        final isPrivacyHidden = controller.isBalanceHidden.value;

        if (isLoadingNetworks && networks.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: const CustomSkeletonFeed(
              itemCount: 4,
              cardHeight: 90,
            ),
          );
        }

        if (networks.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_off_rounded, size: 56.r, color: colors.warning),
                  AppSpacing.vMd,
                  Text(
                    'لا توجد شبكات مزودة مرتبطة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vSm,
                  Text(
                    'نقطة البيع غير مرتبطة بأي مزود شبكة حالياً، لذلك لا يوجد حساب جاري مفتوح.',
                    style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vLg,
                  CustomButton.primary(
                    text: 'تحديث القائمة',
                    icon: Icons.refresh_rounded,
                    onPressed: () => controller.loadLinkedNetworks(),
                  ),
                ],
              ),
            ),
          );
        }

        final isOverdrawn = wallet != null && wallet.walletBalance < 0;

        return RefreshIndicator(
          onRefresh: () => controller.loadWalletAndLogsForSelectedNetwork(),
          child: ListView(
            controller: controller.scrollController,
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // 1. شريط اختيار الشبكة المزودة المستقلة
              PosNetworkSelectorCard(
                networks: networks,
                selectedNetwork: selectedNet,
                onSelectNetwork: controller.selectNetwork,
              ),

              AppSpacing.vMd,

              // 2. بطاقة تنبيه العزل المالي التام
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: AppRadius.smRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16.r, color: colors.primary),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'عزل مالي معتمد: الحساب الجاري مستقل تماماً ولا يتم جمع مديونيات الشبكات المختلفة.',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vMd,

              // 3. بطاقة الرصيد والمديونية الرسمية للشبكة المحددة
              if (isLoadingWallet && wallet == null)
                const CustomSkeletonFeed(itemCount: 1, cardHeight: 140)
              else if (wallet != null)
                WalletBalanceHeroCard(
                  title: selectedNet?.networkName ?? 'الشبكة المزودة',
                  subtitle: wallet.isOverdrawn
                      ? 'مديونية مستحقة للشبكة المحددة فقط'
                      : 'رصيد دائن متاح للتعامل',
                  balance: wallet.isOverdrawn ? wallet.debitAmount : wallet.creditAmount,
                  isBalanceHidden: isPrivacyHidden,
                  onTogglePrivacy: controller.togglePrivacy,
                  isPosDebt: wallet.isOverdrawn,
                  statusLabel: wallet.accountingStatusLabel,
                  accountUuid: wallet.walletUuid,
                  onRefresh: () => controller.loadWalletAndLogsForSelectedNetwork(),
                ),

              AppSpacing.vMd,

              // 4. أزرار العمليات
              Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: 'سند توريد / سداد',
                      icon: Icons.payments_outlined,
                      height: 40.h,
                      onPressed: () => controller.showDisabledMutationNotice(context, 'سند توريد / سداد'),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: CustomButton.outline(
                      text: 'طلب كروت جديدة (POS-02)',
                      icon: Icons.add_shopping_cart_rounded,
                      height: 40.h,
                      onPressed: () => Get.toNamed(AppRoutes.newProcurementOrder),
                    ),
                  ),
                ],
              ),

              AppSpacing.vLg,

              // 5. شريط التصفية والبحث في سجل قيود الحساب
              WalletFilterBar(
                searchController: controller.searchController,
                onSearchChanged: controller.onSearchChanged,
                onClearSearch: controller.clearSearch,
                selectedOperation: controller.selectedOperation.value,
                onSelectOperation: controller.setOperationFilter,
                operationOptions: _operationOptions,
              ),

              AppSpacing.vLg,

              // 6. ترويسة سجل القيود
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'كشف قيود الحساب الجاري',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${logs.length} قيد مسجل',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              AppSpacing.vSm,

              // 7. قائمة القيود المحاسبية
              if (isLoadingLogs && logs.isEmpty)
                const CustomSkeletonFeed(
                  itemCount: 4,
                  cardHeight: 70,
                  shrinkWrap: true,
                )
              else if (logs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 36.h),
                  child: const CustomEmptyState(
                    title: 'لا توجد حركات مقيدة',
                    subtitle: 'لم يتم تسجيل أي عمليات أو قيود في الحساب الجاري مع هذه الشبكة.',
                  ),
                )
              else
                ...logs.map((log) => WalletMovementTile(
                      logId: log.logId,
                      operationLabel: log.logOperationTypeLabel,
                      amount: log.logAmount,
                      isCredit: log.isCredit,
                      statement: log.logStatement,
                      date: log.createdAt ?? log.logDate,
                    )),

              if (isLoadingMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),

              AppSpacing.vXl,
            ],
          ),
        );
      }),
    );
  }
}
