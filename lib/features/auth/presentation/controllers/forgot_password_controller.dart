import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/auth/domain/usecases/request_password_reset_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة طلب استعادة كلمة المرور (ForgotPasswordController)
class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._requestPasswordResetUseCase);

  final RequestPasswordResetUseCase _requestPasswordResetUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();

  final RxBool isLoading = false.obs;

  /// إرسال طلب رمز التحقق
  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      final phone = phoneController.text.trim();
      await _requestPasswordResetUseCase.execute(phone);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إرسال رمز التحقق بنجاح!',
      );

      // الانتقال لشاشة التحقق من الرمز مع تمرير رقم الهاتف
      Get.toNamed(AppRoutes.verifyOtp, arguments: {'phone': phone});
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر إرسال الرمز',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
