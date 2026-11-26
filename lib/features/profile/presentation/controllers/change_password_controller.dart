import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/profile/domain/entities/profile_security_params.dart';
import 'package:netsales/features/profile/domain/usecases/profile_security_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// مُنسِّق نموذج تغيير كلمة المرور عبر [ChangePasswordUseCase].
class ChangePasswordController extends GetxController {
  ChangePasswordController({required this.changePasswordUseCase});

  final ChangePasswordUseCase changePasswordUseCase;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Validators (مُوحدة من FormValidators)
  // ---------------------------------------------------------------------------

  FormFieldValidator<String> get currentPasswordValidator =>
      FormValidators.required(fieldName: 'كلمة المرور الحالية');

  FormFieldValidator<String> get newPasswordValidator =>
      FormValidators.passwordValidator(
        fieldName: 'كلمة المرور الجديدة',
        minLength: 6,
      );

  FormFieldValidator<String> get confirmPasswordValidator =>
      FormValidators.confirmPasswordValidator(
        fieldName: 'تأكيد كلمة المرور',
        passwordController: newPasswordController,
      );

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void reset() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تغيير كلمة المرور...',
      );
      await changePasswordUseCase(
        ChangePasswordParams(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
        ),
      );
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تغيير كلمة المرور بنجاح',
      );
      Get.back<void>();
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذّر تغيير كلمة المرور',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تأكد من صحة كلمة المرور الحالية وحاول مجدّدًا.',
        ),
        type: SnackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
