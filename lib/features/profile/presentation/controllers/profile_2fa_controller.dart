import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/profile/domain/entities/profile_security_params.dart';
import 'package:netsales/features/profile/domain/usecases/profile_security_use_cases.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// مُنسِّق دورة حياة التحقق بخطوتين (تفعيل / تعطيل) عبر طبقة Domain UseCases.
class Profile2faController extends GetxController {
  Profile2faController({
    required this.requestTwoFactorOtpUseCase,
    required this.toggleTwoFactorUseCase,
  });

  final RequestTwoFactorOtpUseCase requestTwoFactorOtpUseCase;
  final ToggleTwoFactorUseCase toggleTwoFactorUseCase;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  final RxBool isRequestingOtp = false.obs;
  final RxBool isEnabling = false.obs;
  final RxBool isDisabling = false.obs;
  final RxBool otpSent = false.obs;
  final RxInt cooldownSeconds = 0.obs;
  final RxBool canResend = true.obs;

  final otpController = TextEditingController();
  final disablePasswordController = TextEditingController();
  final enableFormKey = GlobalKey<FormState>();
  final disableFormKey = GlobalKey<FormState>();

  Timer? _cooldownTimer;

  // ---------------------------------------------------------------------------
  // Validators (مُوحدة من FormValidators)
  // ---------------------------------------------------------------------------

  FormFieldValidator<String> get otpValidator =>
      FormValidators.otpValidator(length: 6);

  FormFieldValidator<String> get passwordValidator =>
      FormValidators.required(fieldName: 'كلمة المرور الحالية');

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    otpController.dispose();
    disablePasswordController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Request OTP (Enable Flow — Step 1)
  // ---------------------------------------------------------------------------

  Future<void> requestOtpForEnable() async {
    if (!canResend.value || isRequestingOtp.value) return;
    isRequestingOtp.value = true;
    try {
      await requestTwoFactorOtpUseCase();
      otpSent.value = true;
      _startCooldown();
      CustomSnackbar.show(
        title: 'تم إرسال الرمز',
        message: 'تحقق من رسائل هاتفك للحصول على رمز التحقق.',
        type: SnackType.success,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'تعذّر إرسال الرمز',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'حدث خطأ أثناء إرسال رمز التحقق.',
        ),
        type: SnackType.error,
      );
    } finally {
      isRequestingOtp.value = false;
    }
  }

  void _startCooldown() {
    cooldownSeconds.value = 60;
    canResend.value = false;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      cooldownSeconds.value--;
      if (cooldownSeconds.value <= 0) {
        timer.cancel();
        canResend.value = true;
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Enable 2FA (Step 2 — submit OTP)
  // ---------------------------------------------------------------------------

  Future<void> enableTwoFactor() async {
    if (!(enableFormKey.currentState?.validate() ?? false)) return;
    isEnabling.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تفعيل التحقق بخطوتين...',
      );
      await toggleTwoFactorUseCase(
        ToggleTwoFactorParams(
          enable: true,
          otp: otpController.text.trim(),
        ),
      );
      _notifyProfileController(enabled: true);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تفعيل التحقق بخطوتين',
      );
      Get.back<void>();
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذّر التفعيل',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تأكد من صحة الرمز وحاول مجدّدًا.',
        ),
        type: SnackType.error,
      );
    } finally {
      isEnabling.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Disable 2FA
  // ---------------------------------------------------------------------------

  Future<void> disableTwoFactor() async {
    if (!(disableFormKey.currentState?.validate() ?? false)) return;
    isDisabling.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تعطيل التحقق بخطوتين...',
      );
      await toggleTwoFactorUseCase(
        ToggleTwoFactorParams(
          enable: false,
          currentPassword: disablePasswordController.text,
        ),
      );
      _notifyProfileController(enabled: false);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تعطيل التحقق بخطوتين',
      );
      Get.back<void>();
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذّر التعطيل',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'تأكد من كلمة المرور وحاول مجدّدًا.',
        ),
        type: SnackType.error,
      );
    } finally {
      isDisabling.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void resetEnableFlow() {
    otpController.clear();
    otpSent.value = false;
    cooldownSeconds.value = 0;
    canResend.value = true;
    _cooldownTimer?.cancel();
  }

  void resetDisableFlow() {
    disablePasswordController.clear();
  }

  void _notifyProfileController({required bool enabled}) {
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().onTwoFactorToggled(enabled);
    }
  }
}
