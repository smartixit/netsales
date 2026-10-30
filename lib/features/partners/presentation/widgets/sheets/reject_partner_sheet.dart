import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة تأكيد رفض الشريك مع تدوين السبب (RejectPartnerSheet)
/// ============================================================================
/// مكون قياسي موحد يُستدعى لرفض طلب انضمام مزود شبكة أو نقطة بيع،
/// يضمن عدم تكرار كود الواجهة (DRY) والالتزام بمنظومة CustomBottomSheet الموحدة.
class RejectPartnerSheet extends StatelessWidget {
  final bool isNetwork;
  final int id;
  final String name;
  final PartnersController controller;

  const RejectPartnerSheet({
    super.key,
    required this.isNetwork,
    required this.id,
    required this.name,
    required this.controller,
  });

  /// استدعاء موحد لعرض نافذة الرفض السفلية
  static Future<void> show(
    BuildContext context, {
    required bool isNetwork,
    required int id,
    required String name,
    required PartnersController controller,
  }) {
    controller.rejectReasonController.clear();
    final partnerType = isNetwork ? 'مزود الشبكة' : 'نقطة البيع';

    return CustomBottomSheet.show<void>(
      title: 'رفض طلب $partnerType',
      subtitle:
          'يرجى توضيح سبب رفض طلب "$name"، حيث سيتم إرساله في إشعار رسمي لصاحب الطلب.',
      leadingIcon: Icons.cancel_rounded,
      child: RejectPartnerSheet(
        isNetwork: isNetwork,
        id: id,
        name: name,
        controller: controller,
      ),
    );
  }

  void _onConfirm() {
    if (controller.rejectFormKey.currentState?.validate() ?? false) {
      final reason = controller.rejectReasonController.text.trim();
      Get.back();
      controller.executeReject(
        isNetwork: isNetwork,
        id: id,
        name: name,
        reason: reason,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.rejectFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: controller.rejectReasonController,
            label: 'سبب الرفض الإلزامي',
            hint:
                'اكتب سبب الرفض بالتفصيل (مثل: البيانات غير مطابقة للسجل التجاري)...',
            prefixIcon: const Icon(Icons.comment_outlined),
            maxLines: 3,
            validator: FormValidators.customTextValidator(
              fieldName: 'سبب الرفض',
            ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'تراجع',
                  onPressed: () => Get.back(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.danger(
                  text: 'تأكيد الرفض',
                  icon: Icons.cancel_rounded,
                  onPressed: _onConfirm,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
        ],
      ),
    );
  }
}

