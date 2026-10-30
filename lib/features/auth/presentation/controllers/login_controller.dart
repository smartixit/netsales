import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/credential_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/features/auth/domain/usecases/login_use_case.dart';
import 'package:netsales/features/auth/presentation/widgets/register/pending_support_dialog_content.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم واجهة تسجيل الدخول (LoginController)
class LoginController extends GetxController {
  LoginController({required this.loginUseCase});

  final LoginUseCase loginUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool canCheckBiometrics = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initBiometricsAndSavedCredentials();
  }

  /// فحص دعم المقاييس الحيوية واستعادة الاعتمادات المحفوظة بأمان
  Future<void> _initBiometricsAndSavedCredentials() async {
    try {
      final canAuthenticate =
          await CredentialService.instance.canAuthenticateWithBiometrics();
      if (isClosed) return;
      canCheckBiometrics.value = canAuthenticate;

      // استعادة الاعتمادات المحفوظة بشكل مشفر وتعبئة رقم الهاتف إن وُجد
      final savedPhone = await CredentialService.instance.getSavedPhone();
      if (isClosed) return;
      if (savedPhone != null &&
          savedPhone.isNotEmpty &&
          phoneController.text.isEmpty) {
        phoneController.text = savedPhone;
      }
    } catch (_) {
      if (isClosed) return;
      canCheckBiometrics.value = false;
    }
  }

  /// تسجيل الدخول السريع عبر المقاييس الحيوية (بصمة الإصبع / الوجه)
  Future<void> authenticateWithBiometrics() async {
    final result = await CredentialService.instance.authenticate(
      reason: 'يرجى تأكيد هويتك للمتابعة إلى حسابك',
    );
    // قد تُزال الشاشة أثناء نافذة التحقق الحيوي، فتُحرَّر متحكمات النص في onClose.
    if (isClosed) return;

    if (result.isSuccess) {
      final savedCreds =
          await CredentialService.instance.getSavedCredentials();
      // نفس الحارس بعد كل عملية غير متزامنة قبل أي كتابة في متحكمات النص.
      if (isClosed) return;

      if (savedCreds != null) {
        phoneController.text = savedCreds.phone;
        passwordController.text = savedCreds.password;
        await submitLogin();
      } else if (phoneController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty) {
        await submitLogin();
      } else {
        CustomSnackbar.show(
          title: 'المقاييس الحيوية مؤكدة',
          message:
              'يرجى إدخال كلمة المرور لتسجيل الدخول أول مرة وحفظ الاعتمادات بأمان.',
          type: SnackType.info,
        );
      }
    } else if (result.status != BiometricAuthStatus.canceled) {
      CustomSnackbar.show(
        title: 'تعذر التحقق الحيوي',
        message: result.errorMessage ?? 'يرجى استخدام كلمة المرور لتسجيل الدخول.',
        type: SnackType.warning,
      );
    }
  }

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
      await CustomAnimationOverlay.showLoading();

      final device = DeviceService.to;
      final fcmToken = await PushNotificationService.instance
          .getOrFetchFcmToken();
      // لا تُكمل عملية الدخول إذا غادر المستخدم الشاشة أثناء جلب رمز الإشعارات.
      if (isClosed) return;

      // 2. تنفيذ حالة الاستخدام الدومينية ببيانات عتادية دقيقة ورمز FCM الفوري
      final result = await loginUseCase.execute(
        LoginParams(
          phoneNumber: phoneController.text,
          password: passwordController.text,
          deviceUuid: device.deviceUuid,
          fcmToken: fcmToken,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
        ),
      );

      // الحارس يمنع التنقّل والحفظ وعرض النجاح بعد إغلاق الشاشة أثناء الطلب.
      if (isClosed) return;

      // 3. فحص حالة التحقق الثنائي (2FA)
      if (result.require2fa) {
        await CustomAnimationOverlay.hide();
        Get.toNamed(
          AppRoutes.twoFactorAuth,
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
          message:
              'تم الدخول بكلمة مرور مؤقتة، يرجى تعيين كلمة مرور جديدة لحسابك للمتابعة.',
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

      // 5. حالة النجاح المباشر: حفظ الاعتمادات بشكل مشفر وعرض أنيميشن النجاح
      await CredentialService.instance.saveCredentials(
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الدخول بنجاح. مرحباً بك!',
      );

      // 6. التوجيه الفوري للوحة التحكم
      if (isClosed) return;
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      // 6. إغلاق الـ Overlay فوراً وعرض رسالة الخطأ عبر CustomSnackbar أو حوار المراجعة المخصص
      await CustomAnimationOverlay.hide();

      // الحارس يمنع التنبيه والحوار بعد إغلاق الشاشة أثناء الطلب.
      if (isClosed) return;

      final cleanMessage = AppException.sanitizeMessage(error);

      // في حال كان الحساب أو الجهاز أو نقطة البيع لا يزال قيد المراجعة والاعتماد
      if (cleanMessage.contains('قيد المراجعة')) {
        await _showPendingSupportDialog(cleanMessage);
        return;
      }

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

  /// عرض حوار المراجعة والاعتماد المخصص مع قنوات الدعم الفني المباشرة
  Future<void> _showPendingSupportDialog(String message) async {
    await CustomDialog.show(
      type: DialogType.pending,
      title: 'طلبكم قيد المراجعة والاعتماد',
      content: PendingSupportDialogContent(
        message: message,
        phone: phoneController.text.trim(),
      ),
      cancelLabel: 'إغلاق',
    );
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
