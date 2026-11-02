import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/presentation/controllers/network_debts_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class ReverseRepaymentDialog extends StatefulWidget {
  final PosRepaymentEntity repayment;

  const ReverseRepaymentDialog({super.key, required this.repayment});

  static Future<void> show(BuildContext context, PosRepaymentEntity repayment) {
    return CustomDialog.show(
      type: DialogType.warning,
      title: 'عكس سند سداد مديونية',
      message: 'إعادة قيد المديونية المستحقة على نقطة البيع وخصم النقد من محفظة الشبكة',
      content: ReverseRepaymentDialog(repayment: repayment),
      canPop: true,
    );
  }

  @override
  State<ReverseRepaymentDialog> createState() => _ReverseRepaymentDialogState();
}

class _ReverseRepaymentDialogState extends State<ReverseRepaymentDialog> {
  final NetworkDebtsController controller = Get.find<NetworkDebtsController>();
  final TextEditingController reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم السند: ${widget.repayment.repaymentUuid}',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${AmountFormatter.formatValue(widget.repayment.amount, decimalPlaces: 0)} ر.ي',
                style: AppTypography.titleSmall.copyWith(color: colors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          AppSpacing.vSm,
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Text(
              'تحذير محاسبي: عكس هذا السند سيؤدي إلى خصم المبلغ (${AmountFormatter.formatValue(widget.repayment.amount, decimalPlaces: 0)} ر.ي) فوراً من رصيد محفظة الشبكة المتاح، وإعادة قيد المديونية المستحقة على نقطة البيع (${widget.repayment.allocations.length} فواتير).',
              style: AppTypography.labelSmall.copyWith(color: colors.error),
            ),
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: reasonController,
            label: 'سبب العكس (إلزامي)',
            hint: 'بيان سبب إلغاء وعكس السند...',
            prefixIcon: const Icon(Icons.edit_note_rounded),
            maxLines: 2,
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إلغاء',
                  height: 40.h,
                  onPressed: () => Get.back<void>(),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(() => CustomButton(
                      text: 'تأكيد العكس',
                      height: 40.h,
                      backgroundColor: colors.error,
                      loading: controller.isReversingRepayment.value,
                      onPressed: () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          CustomSnackbar.show(
                            title: 'تنبيه',
                            message: 'يجب إدخال سبب العكس لتوثيق القيد المحاسبي',
                            type: SnackType.warning,
                          );
                          return;
                        }

                        final success = await controller.reverseRepayment(
                          repaymentId: widget.repayment.repaymentId,
                          reversalReason: reason,
                        );

                        if (success) {
                          Get.back<void>();
                        }
                      },
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
