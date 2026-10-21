import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/auth/domain/usecases/request_password_reset_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/verify_reset_otp_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة التحقق من كود الاستعادة OTP (VerifyOtpController)
class VerifyOtpController extends GetxController {
  VerifyOtpController(
    this._verifyResetOtpUseCase,
    this._requestPasswordResetUseCase,
  );

  final VerifyResetOtpUseCase _verifyResetOtpUseCase;
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  late final String phone;
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;

  // مؤقت التهدئة لإعادة إرسال الرمز
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
    phone = (args is Map ? args['phone']?.toString() : null) ?? '';
    _startCooldownTimer();
  }

  /// رقم الهاتف مقنعاً لحماية الخصوصية (مثال: 772***781)
  String get maskedPhone {
    if (phone.length == 9) {
      return '${phone.substring(0, 3)}***${phone.substring(6)}';
    }
    return phone;
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

  /// إعادة إرسال رمز التحقق
  Future<void> resendOtp() async {
    if (!canResend.value || isResending.value) return;

    try {
      isResending.value = true;
      await _requestPasswordResetUseCase.execute(phone);
      _startCooldownTimer();

      CustomSnackbar.show(
        title: 'تم إرسال الرمز',
        message: 'تم إرسال رمز تحقق جديد إلى هاتفك عبر رسالة SMS.',
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

  /// التوجيه لتعيين كلمة مرور جديدة مباشرة باستخدام رمز التحقق OTP
  void goToDirectReset([String? pin]) {
    if (pin != null && pin.isNotEmpty) {
      otpController.text = pin;
    }

    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    Get.toNamed(
      AppRoutes.resetPassword,
      arguments: {
        'phone': phone,
        'otp': otpController.text.trim(),
      },
    );
  }

  /// إرسال رمز التحقق واستلام كلمة مرور مؤقتة عبر SMS (المسار البديل)
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
      await CustomAnimationOverlay.showLoading(
        message: 'جاري التحقق من الرمز وتوليد كلمة المرور المؤقتة...',
      );

      await _verifyResetOtpUseCase.execute(
        VerifyResetOtpParams(
          phoneNumber: phone,
          otp: otpController.text.trim(),
        ),
      );

      await CustomAnimationOverlay.showSuccess(
        message:
            'تم التحقق بنجاح! تم إرسال كلمة المرور المؤقتة الجديدة إلى هاتفك عبر SMS.',
      );

      // التوجيه لشاشة تسجيل الدخول مع تمرير رقم الهاتف للدخول بكلمة المرور المؤقتة
      Get.offAllNamed(
        AppRoutes.login,
        arguments: {
          'phone': phone,
        },
      );
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

  void goToChangePhone() {
    Get.back();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
