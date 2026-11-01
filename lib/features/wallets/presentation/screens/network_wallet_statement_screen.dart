import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/wallets/presentation/controllers/network_wallet_controller.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_balance_hero_card.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_filter_bar.dart';
import 'package:netsales/features/wallets/presentation/widgets/wallet_movement_tile.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// شاشة كشف حركات محفظة الشبكة والحسابات (NetworkWalletStatementScreen) — NET-04
/// ============================================================================
/// تتيح لمزود الشبكة ومحاسبيه استعراض الرصيد الرسمي المعتمد ودفتر أستاذ الحركات
/// المالية والتحصيلات والمصروفات، مع قفل الطفرات المالية للقراءة والتدقيق فقط.
class NetworkWalletStatementScreen extends GetView<NetworkWalletController> {
  const NetworkWalletStatementScreen({super.key});

  static const List<Map<String, String>> _operationOptions = [
    {'key': 'ALL', 'label': 'كافة القيود'},
    {'key': 'DEPOSIT', 'label': 'إيداعات نقدية'},
    {'key': 'WITHDRAW', 'label': 'سحوبات'},
    {'key': 'INVOICE_PAYMENT', 'label': 'تحصيل مبيعات'},
    {'key': 'EXPENSE', 'label': 'مصروفات تشغيلية'},
    {'key': 'TRANSFER_TO_POS', 'label': 'تحويلات للوكلاء'},
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
              'كشف حركات محفظة الشبكة',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'NET-04 • دفتر الأستاذ والسيولة النقدية',
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
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Obx(() {
        final isLoadingWallet = controller.isLoadingWallet.value;
        final error = controller.errorMessage.value;
        final wallet = controller.wallet.value;
        final logs = controller.logs;
        final isLoadingLogs = controller.isLoadingLogs.value;
        final isLoadingMore = controller.isLoadingMore.value;
        final isPrivacyHidden = controller.isBalanceHidden.value;

        if (isLoadingWallet && wallet == null) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: const CustomSkeletonFeed(
              itemCount: 4,
              cardHeight: 90,
            ),
          );
        }

        if (error.isNotEmpty && wallet == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 56.r, color: colors.error),
                  AppSpacing.vMd,
                  Text(
                    'تعذر جلب بيانات كشف الحساب',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vSm,
                  Text(
                    error,
                    style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vLg,
                  CustomButton.primary(
                    text: 'إعادة المحاولة',
                    icon: Icons.refresh_rounded,
                    onPressed: () => controller.loadData(),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ListView(
            controller: controller.scrollController,
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // 1. بطاقة الرصيد المركزي المعتمد
              WalletBalanceHeroCard(
                title: wallet?.networkName ?? 'محفظة الشبكة',
                subtitle: 'رصيد محفظة الشبكة المعتمد',
                balance: wallet?.walletBalance ?? 0.0,
                isBalanceHidden: isPrivacyHidden,
                onTogglePrivacy: controller.togglePrivacy,
                statusLabel: wallet?.isActive == true ? 'محفظة نشطة' : 'محفظة متوقفة',
                accountUuid: wallet?.walletUuid,
                onRefresh: () => controller.loadData(),
              ),

              AppSpacing.vMd,

              // 2. إشعارات الطفرات المالية المعطلة برمجياً
              Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: 'إيداع نقدي',
                      icon: Icons.add_circle_outline_rounded,
                      height: 40.h,
                      onPressed: () => controller.showDisabledMutationNotice(context, 'إيداع نقدي'),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: CustomButton.outline(
                      text: 'سحب نقدي',
                      icon: Icons.remove_circle_outline_rounded,
                      height: 40.h,
                      onPressed: () => controller.showDisabledMutationNotice(context, 'سحب نقدي'),
                    ),
                  ),
                ],
              ),

              AppSpacing.vLg,

              // 3. شريط التصفية والبحث في القيود المحاسبية
              WalletFilterBar(
                searchController: controller.searchController,
                onSearchChanged: controller.onSearchChanged,
                onClearSearch: controller.clearSearch,
                selectedOperation: controller.selectedOperation.value,
                onSelectOperation: controller.setOperationFilter,
                operationOptions: _operationOptions,
              ),

              AppSpacing.vLg,

              // 4. ترويسة سجل القيود المحاسبية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'دفتر الأستاذ والقيود المالية',
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

              // 5. قائمة القيود المحاسبية
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
                    title: 'لا توجد حركات مالية مسجلة',
                    subtitle: 'لم يتم العثور على أي قيود محاسبية مطابقة لمعايير البحث الحالية.',
                  ),
                )
              else
                ...logs.map((log) => WalletMovementTile(
                      logId: log.logId,
                      operationLabel: log.logOperationLabel,
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
