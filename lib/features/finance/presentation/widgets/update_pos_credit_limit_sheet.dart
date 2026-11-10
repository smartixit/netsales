import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/usecases/update_pos_credit_limit_use_case.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class UpdatePosCreditLimitSheet extends StatelessWidget {
  UpdatePosCreditLimitSheet({
    super.key,
    required this.posWalletId,
    required this.posName,
    this.currentCreditLimit,
    this.onSuccess,
  }) : creditLimitController = TextEditingController(
          text: currentCreditLimit != null
              ? currentCreditLimit.toStringAsFixed(2)
              : '',
        );

  final int posWalletId;
  final String posName;
  final double? currentCreditLimit;
  final VoidCallback? onSuccess;

  final TextEditingController creditLimitController;
  final RxBool isSubmitting = false.obs;

  Future<void> _submit(BuildContext context) async {
    final text = creditLimitController.text.trim();
    final double? newLimit = text.isEmpty ? null : double.tryParse(text);

    if (text.isNotEmpty && (newLimit == null || newLimit < 0)) {
      CustomSnackbar.show(
        title: 'قيمة غير صالحة',
        message:
            'أدخل حداً ائتمانياً صحيحاً أكبر من أو يساوي صفر، أو اتركه فارغاً لإلغاء التسهيل.',
        type: SnackType.warning,
      );
      return;
    }

    final confirmed = await CustomDialog.show(
      type: DialogType.warning,
      title: 'تأكيد السقف الائتماني',
      message: newLimit == null
          ? 'هل أنت متأكد من إزالة السقف الائتماني لنقطة ($posName)؟ لن يُسمح للنقطة بالشراء على الحساب مكشوفاً.'
          : 'هل أنت متأكد من تحديد السقف الائتماني لنقطة ($posName) بمبلغ ${AmountFormatter.formatValue(newLimit)}؟',
      confirmLabel: 'تأكيد الحفظ',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تحديث السقف الائتماني...',
    );

    try {
      final useCase = Get.find<UpdatePosCreditLimitUseCase>();
      await useCase(
        posWalletId: posWalletId,
        creditLimit: newLimit,
      );

      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث السقف الائتماني بنجاح',
      );
      Get.back<void>();
      onSuccess?.call();
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر التحديث',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحديث السقف الائتماني لنقطة البيع.',
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
      title: 'تعديل السقف الائتماني',
      subtitle: posName,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: creditLimitController,
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
    );
  }
}
