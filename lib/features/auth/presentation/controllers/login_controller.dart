import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/features/auth/domain/usecases/login_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم واجهة تسجيل الدخول (LoginController)
class LoginController extends GetxController {
  LoginController(this._loginUseCase);

  final LoginUseCase _loginUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  /// تبديل إظهار وإخفاء كلمة المرور
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  /// إرسال طلب تسجيل الدخول المتكامل
  Future<void> submitLogin() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // 1. إطلاق شاشة التحميل المتدفقة مع Lottie Overlay
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تسجيل الدخول والتحقق من الحساب...',
      );

      final device = DeviceService.to;
      final fcmToken = await PushNotificationService.instance.getOrFetchFcmToken();

      // 2. تنفيذ حالة الاستخدام الدومينية ببيانات عتادية دقيقة ورمز FCM الفوري
      final result = await _loginUseCase.execute(
        LoginParams(
          phoneNumber: phoneController.text,
          password: passwordController.text,
          deviceUuid: device.deviceUuid,
          fcmToken: fcmToken,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
        ),
      );

      // 3. فحص حالة التحقق الثنائي (2FA)
      if (result.require2fa) {
        await CustomAnimationOverlay.hide();
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: {
            'phone': phoneController.text,
            'device_uuid': device.deviceUuid,
            'device_name': device.deviceName,
            'device_type': device.deviceType,
            'fcm_token': fcmToken,
            if (result.message != null && result.message!.isNotEmpty)
              'message': result.message,
          },
        );
        return;
      }

      // 4. فحص بوابة التغيير الإلزامي لكلمة المرور (Mandatory Password Change Gate)
      if (result.requirePasswordChange) {
        await CustomAnimationOverlay.hide();
        CustomSnackbar.show(
          title: 'تغيير كلمة المرور إلزامي',
          message: 'تم الدخول بكلمة مرور مؤقتة، يرجى تعيين كلمة مرور جديدة لحسابك للمتابعة.',
          type: SnackType.warning,
        );
        Get.offAllNamed(
          AppRoutes.resetPassword,
          arguments: {
            'is_forced': true,
            'phone': phoneController.text,
            'current_password': passwordController.text,
          },
        );
        return;
      }

      // 5. حالة النجاح المباشر: عرض أنيميشن النجاح بالمدة الافتراضية المحددة في المكون الموحد
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الدخول بنجاح. مرحباً بك!',
      );

      // 6. التوجيه الفوري للوحة التحكم
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      // 6. إغلاق الـ Overlay فوراً وعرض رسالة الخطأ عبر CustomSnackbar
      await CustomAnimationOverlay.hide();

      final cleanMessage = AppException.sanitizeMessage(error);
      CustomSnackbar.show(
        title: 'تعذر تسجيل الدخول',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      // 7. الحزام الأمني النهائي: مضمون التنفيذ في كافة السيناريوهات
      isLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// التوجيه لصفحة استعادة كلمة المرور
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  /// التوجيه لصفحة اختيار نوع الحساب الجديد
  void goToRegister() {
    Get.offNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
