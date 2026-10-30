import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// نافذة الحسابات المصرفية المعتمدة للمنشأة (BankAccountsSheet)
/// ============================================================================
/// تعرض الحسابات البنكية للمنشأة كبطاقات دفع فاخرة تتيح نسخ رقم الحساب والـ IBAN
/// فورياً، وتبديل حالة التفعيل بنقرة واحدة، دون أي حسابات على مستوى الفرونت إند.
class BankAccountsSheet extends StatelessWidget {
  const BankAccountsSheet({super.key});

  /// فتح النافذة السفلية المنبثقة
  static Future<void> show(BuildContext context) {
    final controller = Get.find<MoreController>();
    controller.loadBankAccounts();

    return CustomBottomSheet.show<void>(
      title: 'الحسابات المصرفية المعتمدة',
      subtitle: 'إدارة وتغذية الحسابات البنكية لاستقبال الحوالات والمدفوعات',
      leadingIcon: Icons.account_balance_rounded,
      scrollable: true,
      child: const BankAccountsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<MoreController>();

    return Obx(() {
      final isLoading = controller.isLoadingBankAccounts.value;
      final errorMessage = controller.bankAccountsErrorMessage.value;
      final accounts = controller.bankAccounts;

      if (isLoading && accounts.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const CustomSkeletonFeed(
            shrinkWrap: true,
            itemCount: 3,
            cardHeight: 140,
          ),
        );
      }

      if (errorMessage.isNotEmpty && accounts.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.r,
                color: colors.error,
              ),
              AppSpacing.vMd,
              Text(
                errorMessage,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              CustomButton.outline(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: () => controller.loadBankAccounts(isRefresh: true),
              ),
            ],
          ),
        );
      }

      if (accounts.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: Text(
              'لا توجد حسابات مصرفية معتمدة مسجلة حالياً.',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...accounts.map(
            (account) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _BankAccountCard(
                account: account,
                onToggleStatus: () =>
                    controller.toggleBankAccountStatus(account.accountId),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// بطاقة الحساب المصرفي الأنيقة
class _BankAccountCard extends StatelessWidget {
  final BankAccountEntity account;
  final VoidCallback onToggleStatus;

  const _BankAccountCard({required this.account, required this.onToggleStatus});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackbar.show(
      title: 'تم النسخ',
      message: 'تم نسخ $label إلى الحافظة بنجاح.',
      type: SnackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = account.isActive;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isActive
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الترويسة: اسم البنك وحالة الحساب
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: (isActive ? colors.primary : colors.outlineVariant)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: isActive ? colors.primary : colors.onSurfaceVariant,
                  size: 24.r,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.bankName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account.accountHolderName,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // شارة الحالة مع زر التبديل (محمي بصلاحية bank_accounts.manage)
              if (PermissionService.to.can(AppPermissions.bankAccountsManage))
                CustomInteractiveBounce(
                  onTap: onToggleStatus,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: (isActive ? colors.success : colors.outlineVariant)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isActive
                            ? colors.success
                            : colors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_rounded,
                          size: 14.r,
                          color: isActive
                              ? colors.success
                              : colors.onSurfaceVariant,
                        ),
                        AppSpacing.hXs,
                        Text(
                          isActive ? 'نشط' : 'معطل',
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive
                                ? colors.success
                                : colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          AppSpacing.vMd,
          const Divider(height: 1),
          AppSpacing.vMd,

          // رقم الحساب ونسخه
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الحساب المصرفي',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    account.accountNumber,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              CustomInteractiveBounce(
                onTap: () => _copyToClipboard(
                  context,
                  account.accountNumber,
                  'رقم الحساب',
                ),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18.r,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          // نوع الحساب والعملة والرصيد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النوع: ${account.accountTypeLabel} (${account.accountCurrency})',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${AmountFormatter.formatValue(account.accountBalance)} ${account.accountCurrency}',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
