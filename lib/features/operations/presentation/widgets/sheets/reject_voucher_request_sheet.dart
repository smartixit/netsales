import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة تأكيد رفض طلب التوريد مع تدوين السبب (RejectVoucherRequestSheet)
/// ============================================================================
/// مكون قياسي موحد يُستدعى من كافة شاشات وسجلات النظام عند اتخاذ قرار رفض طلب التوريد،
/// يضمن عدم تكرار كود واجهة الرفض (DRY) والالتزام بمنظومة CustomBottomSheet الموحدة.
class RejectVoucherRequestSheet extends StatelessWidget {
  final int requestId;
  final String? requestUuid;
  final OperationsController controller;

  const RejectVoucherRequestSheet({
    super.key,
    required this.requestId,
    this.requestUuid,
    required this.controller,
  });

  /// استدعاء موحد لعرض نافذة الرفض السفلية
  static Future<void> show(
    BuildContext context, {
    required int requestId,
    String? requestUuid,
    required OperationsController controller,
  }) {
    controller.rejectReasonController.clear();

    final identifier = requestUuid != null && requestUuid.isNotEmpty
        ? requestUuid
        : '#$requestId';

    return CustomBottomSheet.show(
      title: 'رفض طلب التوريد',
      subtitle: 'يرجى كتابة سبب رفض الطلب $identifier لتوضيحه لنقطة البيع',
      leadingIcon: Icons.cancel_rounded,
      child: RejectVoucherRequestSheet(
        requestId: requestId,
        requestUuid: requestUuid,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: controller.rejectReasonController,
            label: 'سبب الرفض',
            hint: 'مثال: الرصيد غير كافٍ أو خطأ في تحديد كمية الباقات...',
            prefixIcon: const Icon(Icons.comment_outlined),
            maxLines: 2,
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
                  onPressed: () {
                    Get.back();
                    controller.rejectRequest(requestId);
                  },
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
