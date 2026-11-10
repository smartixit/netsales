import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/idempotency_key_generator.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_pos_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_pos_wallet_use_case.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

enum ManualTransactionType {
  deposit,
  withdraw,
}

/// نافذة سفلية فاخرة لإدراج القيود والتسويات المالية المباشرة (إيداع / سحب)
/// في محفظة نقطة البيع أو محفظة الشبكة وفق أعلى معايير الـ FinTech و Clean Architecture.
class ManualWalletTransactionSheet extends StatelessWidget {
  ManualWalletTransactionSheet({
    super.key,
    required this.walletId,
    required this.accountName,
    required this.currentBalance,
    this.isPosWallet = true,
    this.onSuccess,
  }) {
    logDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  final int walletId;
  final String accountName;
  final double currentBalance;
  final bool isPosWallet;
  final VoidCallback? onSuccess;

  final formKey = GlobalKey<FormState>();
  final transactionType = ManualTransactionType.deposit.obs;
  final amountController = TextEditingController();
  final statementController = TextEditingController();
  final logDateController = TextEditingController();

  final enteredAmount = 0.0.obs;
  final isSubmitting = false.obs;

  static const List<String> posDepositSuggestions = [
    'تسوية مبيعات',
    'بونص مبيعات تشجيعي',
    'رصيد مرتجع',
    'رصيد افتتاحي',
    'تعويض فروقات كروت',
  ];

  static const List<String> posWithdrawSuggestions = [
    'تسوية عجز حساب',
    'خصم عمولة مبيعات',
    'تسوية نقدية يدوية',
    'فروقات جرد',
    'استرداد رصيد',
  ];

  static const List<String> networkDepositSuggestions = [
    'توريد سيولة نقدية',
    'إيداع بنكي مركزي',
    'تسوية رصيد شبكة',
    'رصيد افتتاحي للشبكة',
  ];

  static const List<String> networkWithdrawSuggestions = [
    'سحب أرباح تشغيلية',
    'تسوية رصيد حساب',
    'تغذية سيولة خارجية',
  ];

  List<String> get currentSuggestions => isPosWallet
      ? (transactionType.value == ManualTransactionType.deposit
          ? posDepositSuggestions
          : posWithdrawSuggestions)
      : (transactionType.value == ManualTransactionType.deposit
          ? networkDepositSuggestions
          : networkWithdrawSuggestions);

  Future<void> _submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount < 0.01) {
      CustomSnackbar.show(
        title: 'قيمة غير صالحة',
        message: 'أدخل مبلغاً صحيحاً لا يقل عن 0.01.',
        type: SnackType.warning,
      );
      return;
    }

    final statement = statementController.text.trim();
    if (statement.isEmpty) {
      CustomSnackbar.show(
        title: 'البيان مطلوب',
        message: 'يرجى إدخال سبب أو بيان رسمي للقيد المالي.',
        type: SnackType.warning,
      );
      return;
    }

    final isDeposit = transactionType.value == ManualTransactionType.deposit;
    final typeLabel = isDeposit ? 'إيداع مالي مباشر' : 'سحب مالي مباشر';

    final confirmed = await CustomDialog.show(
      type: isDeposit ? DialogType.confirmation : DialogType.warning,
      title: 'تأكيد $typeLabel',
      message:
          'هل أنت متأكد من تنفيذ عملية ($typeLabel) بمبلغ ${AmountFormatter.formatValue(amount)} في حساب ($accountName)؟\nسيتم تسجيل القيد فورياً بدفتر الأستاذ.',
      confirmLabel: 'تأكيد التنفيذ',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تسجيل القيد المالي بدفتر الأستاذ...',
    );

    try {
      final idempotencyKey = IdempotencyKeyGenerator.generate();
      final date = logDateController.text.trim().isEmpty
          ? null
          : logDateController.text.trim();

      if (isPosWallet) {
        if (isDeposit) {
          final useCase = Get.find<DepositPosWalletUseCase>();
          await useCase(
            posWalletId: walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        } else {
          final useCase = Get.find<WithdrawPosWalletUseCase>();
          await useCase(
            posWalletId: walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        }
      } else {
        if (isDeposit) {
          final useCase = Get.find<DepositNetworkWalletUseCase>();
          await useCase(
            networkWalletId: walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        } else {
          final useCase = Get.find<WithdrawNetworkWalletUseCase>();
          await useCase(
            networkWalletId: walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        }
      }

      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إدراج القيد المالي وتحديث الرصيد بنجاح',
      );
      Get.back<void>();
      onSuccess?.call();
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر تنفيذ القيد',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر إتمام العملية المالية في دفتر الأستاذ.',
        ),
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomBottomSheet(
      title: isPosWallet
          ? 'إدراج قيد تسوية بمحفظة نقطة البيع'
          : 'إدراج قيد مالي بمحفظة الشبكة',
      subtitle: accountName,
      leadingIcon: isPosWallet
          ? Icons.point_of_sale_rounded
          : Icons.account_balance_wallet_rounded,
      scrollable: true,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.vSm,

            // شريط اختيار نوع القيد المالي الموحد
            Obx(
              () => CustomSegmentedBar(
                selectedIndex:
                    transactionType.value == ManualTransactionType.deposit
                        ? 0
                        : 1,
                onSegmentChanged: (index) {
                  transactionType.value = index == 0
                      ? ManualTransactionType.deposit
                      : ManualTransactionType.withdraw;
                },
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

            // بطاقة فاخرة لمحاكاة الأثر المالي اللحظي (Live Ledger Impact Simulator)
            Obx(() {
              final isDeposit =
                  transactionType.value == ManualTransactionType.deposit;
              final amount = enteredAmount.value;
              final expectedBalance =
                  isDeposit ? currentBalance + amount : currentBalance - amount;
              final isNegative = expectedBalance < 0;

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
                          AmountFormatter.formatValue(currentBalance),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vXs,
                    Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    AppSpacing.vXs,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الرصيد المتوقع بعد القيد:',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNegative ? colors.error : colors.onSurface,
                          ),
                        ),
                        Text(
                          AmountFormatter.formatValue(expectedBalance),
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDeposit
                                ? colors.primary
                                : (isNegative ? colors.error : colors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            AppSpacing.vMd,

            // حقل إدخال المبلغ
            CustomTextField(
              controller: amountController,
              label: 'مبلغ العملية',
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icon(
                Icons.payments_rounded,
                color: colors.primary,
                size: 22.r,
              ),
              onChanged: (val) {
                enteredAmount.value = double.tryParse(val.trim()) ?? 0.0;
              },
              validator: (val) {
                final d = double.tryParse(val?.trim() ?? '');
                if (d == null || d < 0.01) {
                  return 'أدخل مبلغاً صحيحاً لا يقل عن 0.01';
                }
                return null;
              },
            ),

            AppSpacing.vSm,

            // شرائح مقترحات البيان السريعة (Quick Statement Chips)
            Obx(() {
              final suggestions = currentSuggestions;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اقتراحات سريعة لبيان القيد:',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXs,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: suggestions.map((chipText) {
                        return Padding(
                          padding: EdgeInsets.only(left: AppSpacing.xs),
                          child: CustomInteractiveBounce(
                            onTap: () {
                              statementController.text = chipText;
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Text(
                                chipText,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),

            AppSpacing.vMd,

            // حقل بيان العملية المالي (إلزامي للشفافية وتتبع القيود)
            CustomTextField(
              controller: statementController,
              label: 'بيان القيد المالي الرسمي',
              hint: 'اكتب وصفاً توضيحياً أو اختر من المقترحات أعلاه',
              prefixIcon: Icon(
                Icons.receipt_long_rounded,
                color: colors.primary,
                size: 22.r,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'بيان العملية مطلوب لتوثيق القيد في دفتر الأستاذ';
                }
                return null;
              },
            ),

            AppSpacing.vSm,

            // حقل تاريخ القيد المالي
            CustomTextField(
              controller: logDateController,
              label: 'تاريخ القيد المالي',
              hint: 'YYYY-MM-DD',
              readOnly: true,
              prefixIcon: const Icon(Icons.calendar_today_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_calendar_rounded),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now.subtract(const Duration(days: 365)),
                    lastDate: now.add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    logDateController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
            ),

            AppSpacing.vLg,

            // زر التنفيذ الأساسي
            Obx(
              () => CustomButton.primary(
                text: transactionType.value == ManualTransactionType.deposit
                    ? 'تأكيد إيداع القيد المالي'
                    : 'تأكيد سحب القيد المالي',
                prefix:
                    transactionType.value == ManualTransactionType.deposit
                        ? Icons.add_task_rounded
                        : Icons.assignment_returned_rounded,
                width: double.infinity,
                loading: isSubmitting.value,
                onPressed: isSubmitting.value ? null : () => _submit(context),
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
      ),
    );
  }
}
