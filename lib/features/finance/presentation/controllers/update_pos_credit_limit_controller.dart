import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/usecases/update_pos_credit_limit_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class UpdatePosCreditLimitController extends GetxController {
  UpdatePosCreditLimitController({
    required this.updatePosCreditLimitUseCase,
  });

  final UpdatePosCreditLimitUseCase updatePosCreditLimitUseCase;

  final creditLimitController = TextEditingController();
  final isSubmitting = false.obs;

  int _posWalletId = 0;
  String _posName = '';
  VoidCallback? _onSuccess;

  int get posWalletId => _posWalletId;
  String get posName => _posName;

  void initialize({
    required int posWalletId,
    required String posName,
    double? currentCreditLimit,
    VoidCallback? onSuccess,
  }) {
    _posWalletId = posWalletId;
    _posName = posName;
    _onSuccess = onSuccess;
    creditLimitController.text = currentCreditLimit != null
        ? currentCreditLimit.toStringAsFixed(2)
        : '';
    isSubmitting.value = false;
  }

  @override
  void onClose() {
    creditLimitController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
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
          ? 'هل أنت متأكد من إزالة السقف الائتماني لنقطة ($_posName)؟ لن يُسمح للنقطة بالشراء على الحساب مكشوفاً.'
          : 'هل أنت متأكد من تحديد السقف الائتماني لنقطة ($_posName) بمبلغ ${AmountFormatter.formatValue(newLimit)}؟',
      confirmLabel: 'تأكيد الحفظ',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تحديث السقف الائتماني...',
    );

    try {
      await updatePosCreditLimitUseCase(
        posWalletId: _posWalletId,
        creditLimit: newLimit,
      );

      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث السقف الائتماني بنجاح',
      );
      Get.back<void>();
      _onSuccess?.call();
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
}

