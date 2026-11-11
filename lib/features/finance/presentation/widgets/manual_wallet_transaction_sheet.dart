import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/presentation/controllers/manual_wallet_transaction_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

class ManualWalletTransactionSheet
    extends GetView<ManualWalletTransactionController> {
  const ManualWalletTransactionSheet({super.key});

  static Future<void> show({
    required int walletId,
    required String accountName,
    required double currentBalance,
    bool isPosWallet = true,
    VoidCallback? onSuccess,
  }) async {
    final controller = Get.find<ManualWalletTransactionController>();
    controller.initialize(
      walletId: walletId,
      accountName: accountName,
      currentBalance: currentBalance,
      isPosWallet: isPosWallet,
      onSuccess: onSuccess,
    );
    return CustomBottomSheet.show<void>(
      title: isPosWallet
          ? 'إدراج قيد تسوية بمحفظة نقطة البيع'
          : 'إدراج قيد مالي بمحفظة الشبكة',
      subtitle: accountName,
      leadingIcon: isPosWallet
          ? Icons.point_of_sale_rounded
          : Icons.account_balance_wallet_rounded,
      scrollable: true,
      child: const ManualWalletTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.vSm,

          // شريط اختيار نوع القيد المالي الموحد
          Obx(
            () => CustomSegmentedBar(
              selectedIndex: controller.isDeposit ? 0 : 1,
              onSegmentChanged: controller.setTransactionTypeIndex,
              items: const [
                CustomSegmentItem(
                  label: 'إيداع مالي (قيد دائن +)',
                  icon: Icons.add_circle_outline_rounded,
                ),
                CustomSegmentItem(
                  label: 'سحب مالي (قيد مدين -)',
                  icon: Icons.remove_circle_outline_rounded,
                ),
              ],
            ),
          ),

          AppSpacing.vMd,

          // بطاقة لمحاكاة الأثر المالي اللحظي
          Obx(() {
            final isDeposit = controller.isDeposit;
            final isNegative = controller.isNegativeBalance;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDeposit
                    ? colors.primaryContainer.withValues(alpha: 0.25)
                    : colors.errorContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDeposit
                      ? colors.primary.withValues(alpha: 0.35)
                      : colors.error.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرصيد الدفتري الحالي:',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatValue(controller.currentBalance),
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مبلغ القيد المطلوب:',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${isDeposit ? '+' : '-'} ${AmountFormatter.formatValue(controller.enteredAmount.value)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDeposit ? colors.primary : colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isNegative) ...[
                    AppSpacing.vXs,
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14.r,
                          color: colors.primary,
                        ),
                        AppSpacing.hXs,
                        Expanded(
                          child: Text(
                            'ملاحظة: سيتم احتساب وتأكيد الرصيد النهائي المعتمد بدفتر الأستاذ من الخادم فورياً.',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),

          AppSpacing.vMd,

          // حقل إدخال المبلغ
          CustomTextField(
            controller: controller.amountController,
            label: 'مبلغ القيد المالي',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.attach_money_rounded),
            isRequired: true,
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'أدخل مبلغاً أكبر من الصفر';
              }
              return null;
            },
          ),

          AppSpacing.vMd,

          // حقل بيان القيد المالي
          CustomTextField(
            controller: controller.statementController,
            label: 'بيان وسند القيد',
            hint: 'مثال: تسوية مبيعات نقدية، بونص...',
            prefixIcon: const Icon(Icons.description_outlined),
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'البيان مطلوب لتوثيق القيد';
              }
              return null;
            },
          ),

          AppSpacing.vXs,

          // مقترحات ونماذج سريعة للبيان
          Obx(() {
            final suggestions = controller.currentSuggestions;

            return Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: suggestions.map((sug) {
                return CustomInteractiveBounce(
                  onTap: () => controller.selectSuggestion(sug),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      sug,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          AppSpacing.vMd,

          // حقل تاريخ القيد
          CustomTextField(
            controller: controller.logDateController,
            label: 'تاريخ القيد المالي (اختياري)',
            hint: 'YYYY-MM-DD (يُترك فارغاً لاعتماد اليوم)',
            prefixIcon: const Icon(Icons.calendar_today_rounded),
          ),

          AppSpacing.vLg,

          // زر حفظ القيد
          Obx(
            () => CustomButton.primary(
              text: controller.isDeposit ? 'تأكيد قيد الإيداع' : 'تأكيد قيد السحب',
              prefix: controller.isDeposit
                  ? Icons.add_task_rounded
                  : Icons.assignment_returned_rounded,
              width: double.infinity,
              loading: controller.isSubmitting.value,
              onPressed:
                  controller.isSubmitting.value ? null : controller.submit,
            ),
          ),

          AppSpacing.vXs,

          CustomButton.text(
            text: 'إلغاء',
            width: double.infinity,
            onPressed: () => Get.back<void>(),
          ),
        ],
      ),
    );
  }
}
