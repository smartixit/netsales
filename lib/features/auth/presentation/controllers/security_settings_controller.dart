import 'dart:async';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/features/auth/domain/usecases/request_two_factor_otp_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/toggle_two_factor_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إعدادات الأمان والمصادقة الثنائية (SecuritySettingsController)
class SecuritySettingsController extends GetxController {
  SecuritySettingsController({
    required this.requestTwoFactorOtpUseCase,
    required this.toggleTwoFactorUseCase,
  });

  final RequestTwoFactorOtpUseCase requestTwoFactorOtpUseCase;
  final ToggleTwoFactorUseCase toggleTwoFactorUseCase;

  final RxBool is2faEnabled = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxBool isRequestingOtp = false.obs;

  // مؤقت التهدئة لإعادة إرسال رمز التحقق
  final RxInt cooldownSeconds = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _cooldownTimer;

  @override
  void onInit() {
    super.onInit();
    final user = SessionService.to.currentUser;
    is2faEnabled.value = user?.user2faEnabled ?? false;
  }

  /// رقم الهاتف المقنّع للمستخدم لحماية الخصوصية
  String get maskedPhone {
    final phone = SessionService.to.currentUser?.userPhoneNumber ?? '';
    if (phone.length == 9) {
      return '${phone.substring(0, 3)}***${phone.substring(6)}';
    }
    return phone;
  }

  void _startCooldownTimer() {
    canResend.value = false;
    cooldownSeconds.value = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(AppMotion.cooldownTick, (timer) {
      if (cooldownSeconds.value > 0) {
        cooldownSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// طلب رمز تحقق OTP تمهيداً لتفعيل 2FA
  Future<bool> requestOtpForEnable() async {
    try {
      isRequestingOtp.value = true;
      await requestTwoFactorOtpUseCase.execute();
      _startCooldownTimer();
      CustomSnackbar.show(
        title: 'تم إرسال رمز التحقق',
        message:
            'تم إرسال كود التحقق بخطوتين إلى هاتفك ($maskedPhone) عبر رسالة SMS.',
        type: SnackType.success,
      );
      return true;
    } catch (error) {
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر إرسال رمز التحقق',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isRequestingOtp.value = false;
    }
  }

  /// إعادة إرسال رمز التحقق أثناء عملية التفعيل
  Future<void> resendEnableOtp() async {
    if (!canResend.value || isRequestingOtp.value) return;
    await requestOtpForEnable();
  }

  /// تأكيد تفعيل المصادقة الثنائية بالرمز المدخل
  Future<bool> confirmEnable2fa(String otp) async {
    if (otp.trim().length != 6) {
      CustomSnackbar.show(
        title: 'رمز غير صالح',
        message: 'يرجى إدخال رمز الأمان المكون من 6 أرقام.',
        type: SnackType.warning,
      );
      return false;
    }

    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      await toggleTwoFactorUseCase.execute(
        ToggleTwoFactorParams(enable: true, otp: otp.trim()),
      );

      final user = SessionService.to.currentUser;
      if (user != null) {
        await SessionService.to.updateCurrentUser(
          user.copyWith(user2faEnabled: true),
        );
      }
      is2faEnabled.value = true;

      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تم تفعيل المصادقة الثنائية بنجاح',
        message: 'حسابك الآن محمي برمز تحقق OTP إضافي عند تسجيل الدخول من أجهزة جديدة.',
        type: SnackType.success,
      );
      return true;
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'فشل تفعيل المصادقة الثنائية',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تأكيد تعطيل المصادقة الثنائية بكلمة المرور الحالية
  Future<bool> confirmDisable2fa(String currentPassword) async {
    if (currentPassword.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'كلمة المرور مطلوبة',
        message: 'يرجى إدخال كلمة المرور الحالية لتأكيد الهوية وتعطيل الحماية.',
        type: SnackType.warning,
      );
      return false;
    }

    try {
      isActionLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      await toggleTwoFactorUseCase.execute(
        ToggleTwoFactorParams(
          enable: false,
          currentPassword: currentPassword.trim(),
        ),
      );

      final user = SessionService.to.currentUser;
      if (user != null) {
        await SessionService.to.updateCurrentUser(
          user.copyWith(user2faEnabled: false),
        );
      }
      is2faEnabled.value = false;

      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تم تعطيل المصادقة الثنائية',
        message: 'تم إيقاف ميزة التحقق بخطوتين لحسابك بنجاح.',
        type: SnackType.info,
      );
      return true;
    } catch (error) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر تعطيل المصادقة الثنائية',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isActionLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }
}
