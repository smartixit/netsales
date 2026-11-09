import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class RepaymentReversalAction extends StatelessWidget {
  const RepaymentReversalAction({
    super.key,
    required this.repayment,
  });

  final PosRepaymentEntity repayment;

  Future<void> _requestReversal() async {
    final reasonController = TextEditingController();
    try {
      final confirmed = await CustomDialog.show(
        type: DialogType.warning,
        title: 'تأكيد عكس سند السداد',
        message:
            'سيُرسل طلب العكس إلى الخادم ليعيد تقييم التسويات والقيود المرتبطة بالسند. لا يمكن تنفيذ هذا الإجراء دون سبب موثق.',
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: CustomTextField(
            controller: reasonController,
            label: 'سبب عكس السند',
            hint: 'اكتب سبباً واضحاً للعكس',
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            isRequired: true,
          ),
        ),
        confirmLabel: 'تأكيد العكس',
        cancelLabel: 'الاحتفاظ بالسند',
      );

      if (confirmed != true) return;

      final reason = reasonController.text.trim();
      if (reason.length < 3 || reason.length > 500) {
        CustomSnackbar.show(
          title: 'سبب العكس مطلوب',
          message: 'اكتب سبباً من 3 إلى 500 حرف قبل تأكيد العملية.',
          type: SnackType.warning,
        );
        return;
      }

      final controller = Get.find<RepaymentHistoryController>();
      final reversed = await controller.reverseRepayment(
        repayment.repaymentId,
        reason,
      );
      if (reversed) Get.back<void>();
    } finally {
      reasonController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton.danger(
      text: 'عكس سند السداد',
      prefix: Icons.undo_rounded,
      width: double.infinity,
      onPressed: _requestReversal,
    );
  }
}
