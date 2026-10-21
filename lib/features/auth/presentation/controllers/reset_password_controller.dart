import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة تعيين/تغيير كلمة المرور الإلزامية والاختيارية (ResetPasswordController)
class ResetPasswordController extends GetxController {
  ResetPasswordController(this._updatePasswordUseCase);

  final UpdatePasswordUseCase _updatePasswordUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  /// هل هذا التغيير إلزامي (مثل الدخول بكلمة مرور مؤقتة عبر SMS)؟
  late final bool isForced;
  late final String? userPhone;

  // مؤشرات معايير قوة كلمة المرور اللحظية (NIST Standards)
  final RxBool hasMinLength = false.obs;
  final RxBool hasUppercase = false.obs;
  final RxBool hasLowercase = false.obs;
  final RxBool hasDigit = false.obs;
  final RxBool hasSpecialChar = false.obs;
  final RxDouble passwordScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      isForced = args['is_forced'] == true;
      userPhone = args['phone']?.toString();
      final prefillCurrent = args['current_password']?.toString();
      if (prefillCurrent != null && prefillCurrent.isNotEmpty) {
        currentPasswordController.text = prefillCurrent;
      }
    } else {
      isForced = SessionService.to.mustChangePassword;
      userPhone = SessionService.to.currentUser?.userPhoneNumber;
    }

    newPasswordController.addListener(_evaluatePasswordStrength);
  }

  /// تحليل قوة كلمة المرور لحظياً
  void _evaluatePasswordStrength() {
    final text = newPasswordController.text;
    hasMinLength.value = text.length >= 8;
    hasUppercase.value = text.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = text.contains(RegExp(r'[a-z]'));
    hasDigit.value = text.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int points = 0;
    if (hasMinLength.value) points++;
    if (hasUppercase.value) points++;
    if (hasLowercase.value) points++;
    if (hasDigit.value) points++;
    if (hasSpecialChar.value) points++;

    passwordScore.value = points / 5.0;
  }

  void toggleCurrentPasswordVisibility() =>
      isCurrentPasswordVisible.toggle();

  void toggleNewPasswordVisibility() =>
      isNewPasswordVisible.toggle();

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.toggle();

  /// إرسال طلب تعيين كلمة المرور الجديدة
  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final currentPass = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (currentPass == newPass) {
      CustomSnackbar.show(
        title: 'كلمة المرور غير مقبولة',
        message: 'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمة المرور المؤقتة.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      isLoading.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تعيين كلمة المرور وتأمين حسابك...',
      );

      await _updatePasswordUseCase.execute(
        UpdatePasswordParams(
          currentPassword: currentPass,
          newPassword: newPass,
          confirmPassword: confirmPass,
        ),
      );

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تعيين كلمة المرور الجديدة بنجاح! مرحباً بك في النظام.',
      );

      // التوجيه الفوري للوحة التحكم بعد ترقية الجلسة وفك الحظر الإلزامي
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر تعيين كلمة المرور',
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

  /// إلغاء العملية أو تسجيل الخروج عند الرغبة بعدم المتابعة
  Future<void> abortOrLogout() async {
    if (isForced) {
      // إذا كان التغيير إجبارياً، الخروج يلغي الجلسة المؤقتة ويعيد المستخدم لشاشة الدخول
      await SessionService.to.terminateSession();
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    newPasswordController.removeListener(_evaluatePasswordStrength);
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
