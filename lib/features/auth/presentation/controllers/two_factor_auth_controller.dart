import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/auth/domain/usecases/resend_otp_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/verify_two_factor_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة التحقق بخطوتين وتأكيد ربط الجهاز (TwoFactorAuthController)
class TwoFactorAuthController extends GetxController {
  TwoFactorAuthController(this._verifyTwoFactorUseCase, this._resendOtpUseCase);

  final VerifyTwoFactorUseCase _verifyTwoFactorUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  late final String phone;
  late final String deviceUuid;
  late final String fcmToken;
  String? deviceName;
  String? deviceType;
  String? initialMessage;

  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;

  // مؤقت التهدئة لإعادة إرسال رمز التحقق بخطوتين
  final RxInt cooldownSeconds = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _cooldownTimer;

  /// تفعيل لوحة المفاتيح الرقمية المدمجة (افتراضياً مفعلة كالتطبيقات العالمية)
  final RxBool isCustomKeyboard = true.obs;

  /// تبديل نمط لوحة المفاتيح بين المدمجة وكيبورد النظام
  void toggleKeyboard() => isCustomKeyboard.toggle();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      phone = args['phone']?.toString() ?? '';
      deviceUuid = args['device_uuid']?.toString() ?? '';
      fcmToken = args['fcm_token']?.toString() ?? '';
      deviceName = args['device_name']?.toString();
      deviceType = args['device_type']?.toString();
      initialMessage = args['message']?.toString();
    } else {
      phone = '';
      deviceUuid = '';
      fcmToken = '';
    }
    _startCooldownTimer();
  }

  /// إخفاء أرقام الهاتف لحماية الخصوصية والأمان السيادي
  String get maskedPhone {
    if (phone.length == 9) {
      return '${phone.substring(0, 3)}***${phone.substring(6)}';
    }
    return phone;
  }

  /// اسم الجهاز للعرض التوجيهي
  String get displayDeviceName {
    if (deviceName != null && deviceName!.trim().isNotEmpty) {
      return deviceName!.trim();
    }
    return 'جهاز غير معروف';
  }

  void _startCooldownTimer() {
    canResend.value = false;
    cooldownSeconds.value = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds.value > 0) {
        cooldownSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// إعادة إرسال رمز التحقق الثنائي عبر OTP_2FA
  Future<void> resendOtp() async {
    if (!canResend.value || isResending.value) return;

    try {
      isResending.value = true;
      await _resendOtpUseCase.execute(
        ResendOtpParams(
          phoneNumber: phone,
          otpType: 'OTP_2FA',
          deviceUuid: deviceUuid,
        ),
      );
      _startCooldownTimer();

      CustomSnackbar.show(
        title: 'تم إرسال رمز التحقق',
        message: 'تم إرسال رمز تحقق ثنائي جديد إلى هاتفك عبر رسالة SMS.',
        type: SnackType.success,
      );
    } catch (error) {
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر إعادة الإرسال',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isResending.value = false;
    }
  }

  /// التحقق من رمز OTP وإتمام المصادقة
  Future<void> submitOtp([String? pin]) async {
    if (pin != null && pin.isNotEmpty) {
      otpController.text = pin;
    }

    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      final result = await _verifyTwoFactorUseCase.execute(
        VerifyTwoFactorParams(
          phoneNumber: phone,
          otp: otpController.text.trim(),
          deviceUuid: deviceUuid,
          fcmToken: fcmToken,
          deviceName: deviceName,
          deviceType: deviceType,
        ),
      );

      // فحص بوابة تغيير كلمة المرور الإلزامي
      if (result.requirePasswordChange) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'تغيير كلمة المرور إلزامي',
          message:
              'تم الدخول بكلمة مرور مؤقتة، يرجى تعيين كلمة مرور جديدة لحسابك للمتابعة.',
          type: SnackType.warning,
        );
        Get.offAllNamed(AppRoutes.resetPassword);
        return;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تأكيد الجهاز والمصادقة بنجاح!',
      );

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'رمز التحقق غير صحيح',
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

  void cancelAndGoBack() {
    Get.back();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
