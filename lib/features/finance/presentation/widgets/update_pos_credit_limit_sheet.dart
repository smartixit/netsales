import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/update_pos_credit_limit_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

class UpdatePosCreditLimitSheet
    extends GetView<UpdatePosCreditLimitController> {
  const UpdatePosCreditLimitSheet({super.key});

  static Future<void> show({
    required int posWalletId,
    required String posName,
    double? currentCreditLimit,
    VoidCallback? onSuccess,
  }) async {
    final controller = Get.find<UpdatePosCreditLimitController>();
    controller.initialize(
      posWalletId: posWalletId,
      posName: posName,
      currentCreditLimit: currentCreditLimit,
      onSuccess: onSuccess,
    );
    return CustomBottomSheet.show<void>(
      title: 'تعديل السقف الائتماني',
      subtitle: posName,
      leadingIcon: Icons.credit_score_rounded,
      scrollable: true,
      child: const UpdatePosCreditLimitSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: controller.creditLimitController,
          label: 'السقف الائتماني الممنوح',
          hint: '0.00 (أو اتركه فارغاً لإلغاء التسهيل)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.credit_card_rounded),
        ),
        AppSpacing.vSm,
        Text(
          'ملاحظة: السقف الائتماني يتيح لنقطة البيع سحب كروت حتى وإن كان رصيدها صفراً بحد أقصى هذا المبلغ.',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vLg,
        Obx(
          () => CustomButton.primary(
            text: 'حفظ السقف الائتماني',
            prefix: Icons.check_rounded,
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
    );
  }
}
