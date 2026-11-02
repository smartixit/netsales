import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/presentation/controllers/network_debts_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class UpdateCreditLimitSheet extends StatefulWidget {
  final PosDebtBreakdownEntity pos;

  const UpdateCreditLimitSheet({super.key, required this.pos});

  static Future<void> show(BuildContext context, PosDebtBreakdownEntity pos) {
    return CustomBottomSheet.show<void>(
      title: 'إدارة السقف الائتماني',
      subtitle: '${pos.posName} • السقف المعتمد وضوابط السحب على المكشوف',
      leadingIcon: Icons.tune_rounded,
      scrollable: true,
      child: UpdateCreditLimitSheet(pos: pos),
    );
  }

  @override
  State<UpdateCreditLimitSheet> createState() => _UpdateCreditLimitSheetState();
}

class _UpdateCreditLimitSheetState extends State<UpdateCreditLimitSheet> {
  final NetworkDebtsController controller = Get.find<NetworkDebtsController>();
  late final TextEditingController limitController;
  bool isNullFacility = false;

  @override
  void initState() {
    super.initState();
    isNullFacility = widget.pos.creditLimit == null;
    limitController = TextEditingController(
      text: widget.pos.creditLimit != null ? widget.pos.creditLimit!.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentDebt = widget.pos.outstandingDebt;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المديونية الحالية القائمة', style: AppTypography.labelSmall),
                    Text(
                      '${AmountFormatter.formatValue(currentDebt, decimalPlaces: 0)} ر.ي',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: currentDebt > 0 ? colors.error : colors.onSurface,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('السقف الائتماني الحالي', style: AppTypography.labelSmall),
                    Text(
                      widget.pos.creditLimit != null
                          ? '${AmountFormatter.formatValue(widget.pos.creditLimit!, decimalPlaces: 0)} ر.ي'
                          : 'غير ممنوح (NULL)',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          // خيار إلغاء التسهيل الائتماني (NULL)
          CheckboxListTile(
            title: const Text('إلغاء التسهيل الائتماني تماماً (NULL)'),
            subtitle: const Text('حظر أي بيع آجل ومنع السحب على المكشوف'),
            value: isNullFacility,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                isNullFacility = val ?? false;
                if (isNullFacility) {
                  limitController.clear();
                }
              });
            },
          ),
          if (!isNullFacility) ...[
            AppSpacing.vSm,
            CustomTextField(
              controller: limitController,
              label: 'مبلغ السقف الائتماني الجديد (ر.ي)',
              hint: 'أدخل الحد الأقصى المسموح به...',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
            ),
            AppSpacing.vXs,
            Text(
              currentDebt > 0
                  ? 'يجب ألا يقل السقف عن المديونية الحالية (${AmountFormatter.formatValue(currentDebt, decimalPlaces: 0)} ر.ي)'
                  : 'أدخل 0.00 لمنع السحب على المكشوف أو قيمة موجبة للسقف المعتمد',
              style: AppTypography.labelSmall.copyWith(
                color: currentDebt > 0 ? colors.warning : colors.onSurfaceVariant,
              ),
            ),
          ],
          AppSpacing.vLg,
          Obx(() => CustomButton(
                text: 'حفظ وتطبيق السقف الائتماني',
                icon: Icons.save_rounded,
                loading: controller.isUpdatingCreditLimit.value,
                onPressed: () async {
                  double? newLimit;

                  if (isNullFacility) {
                    if (currentDebt > 0.001) {
                      CustomSnackbar.show(
                        title: 'خطأ أمان مالي',
                        message: 'لا يمكن إلغاء السقف الائتماني لوجود مديونية قائمة (${AmountFormatter.formatValue(currentDebt, decimalPlaces: 0)} ر.ي). يجب سدادها أولاً.',
                        type: SnackType.error,
                      );
                      return;
                    }
                    newLimit = null;
                  } else {
                    final parsed = double.tryParse(limitController.text.trim());
                    if (parsed == null || parsed < 0) {
                      CustomSnackbar.show(
                        title: 'تنبيه',
                        message: 'يجب إدخال قيمة صالحة للسقف الائتماني (صفر أو أكثر)',
                        type: SnackType.warning,
                      );
                      return;
                    }
                    if (parsed < currentDebt - 0.001) {
                      CustomSnackbar.show(
                        title: 'خطأ أمان مالي',
                        message: 'لا يمكن تخفيض السقف الائتماني (${AmountFormatter.formatValue(parsed, decimalPlaces: 0)} ر.ي) دون المديونية القائمة (${AmountFormatter.formatValue(currentDebt, decimalPlaces: 0)} ر.ي)',
                        type: SnackType.error,
                      );
                      return;
                    }
                    newLimit = parsed;
                  }

                  final success = await controller.updateCreditLimit(
                    walletId: widget.pos.posId,
                    creditLimit: newLimit,
                  );

                  if (success) {
                    Get.back<void>();
                  }
                },
              )),
          AppSpacing.vMd,
        ],
      ),
    );
  }
}
