import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/sound_service.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/register_network_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة تقديم طلب تسجيل مزود شبكة جديد (RegisterNetworkController)
class RegisterNetworkController extends GetxController {
  RegisterNetworkController(
    this._getGovernoratesUseCase,
    this._getDirectoratesUseCase,
    this._registerNetworkUseCase,
  );

  final GetGovernoratesUseCase _getGovernoratesUseCase;
  final GetDirectoratesUseCase _getDirectoratesUseCase;
  final RegisterNetworkUseCase _registerNetworkUseCase;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // متحكمات حقول بيانات الشبكة
  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController networkEmailController = TextEditingController();
  final TextEditingController networkAddressController =
      TextEditingController();

  // متحكمات حقول بيانات مالك الشبكة
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();

  // قنوات القيمة التفاعلية للصور والشعارات (CustomImagePicker)
  final ValueNotifier<File?> networkLogo = ValueNotifier<File?>(null);
  final ValueNotifier<File?> ownerAvatar = ValueNotifier<File?>(null);

  // قنوات القيمة التفاعلية للقوائم المنسدلة (CustomDropdown)
  final ValueNotifier<GovernorateEntity?> selectedGovernorate =
      ValueNotifier<GovernorateEntity?>(null);
  final ValueNotifier<DirectorateEntity?> selectedDirectorate =
      ValueNotifier<DirectorateEntity?>(null);

  // الحالات التفاعلية
  final RxList<GovernorateEntity> governorates = <GovernorateEntity>[].obs;
  final RxList<DirectorateEntity> directorates = <DirectorateEntity>[].obs;
  final RxBool isLoadingGovernorates = false.obs;
  final RxBool isLoadingDirectorates = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGovernorates();
  }

  /// جلب قائمة المحافظات المرجعية
  Future<void> fetchGovernorates() async {
    try {
      isLoadingGovernorates.value = true;
      final result = await _getGovernoratesUseCase.execute();
      governorates.assignAll(result);
    } catch (e) {
      final message = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر جلب المحافظات',
        message: message,
      );
    } finally {
      isLoadingGovernorates.value = false;
    }
  }

  /// معالج تغيير المحافظة المحددة لتحديث المديريات التابعة لها متتالياً
  Future<void> onGovernorateChanged(GovernorateEntity? gov) async {
    selectedGovernorate.value = gov;
    selectedDirectorate.value = null;
    directorates.clear();

    if (gov == null) return;

    try {
      isLoadingDirectorates.value = true;
      final result = await _getDirectoratesUseCase.execute(gov.governorateId);
      directorates.assignAll(result);
    } catch (e) {
      final message = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر جلب المديريات',
        message: message,
      );
    } finally {
      isLoadingDirectorates.value = false;
    }
  }

  /// معالج اختيار المديرية
  void onDirectorateChanged(DirectorateEntity? dir) {
    selectedDirectorate.value = dir;
  }

  /// إرسال طلب تسجيل الشبكة
  Future<void> submitRegistration() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await CustomAnimationOverlay.showLoading();

      final device = DeviceService.to;
      final fcmToken = await PushNotificationService.instance
          .getOrFetchFcmToken();

      final params = RegisterNetworkParams(
        networkName: networkNameController.text.trim(),
        governorateId: selectedGovernorate.value!.governorateId,
        directorateId: selectedDirectorate.value!.directorateId,
        networkEmail: networkEmailController.text.trim().isEmpty
            ? null
            : networkEmailController.text.trim(),
        networkAddress: networkAddressController.text.trim().isEmpty
            ? null
            : networkAddressController.text.trim(),
        networkProfileLogoPath: networkLogo.value?.path,
        userFullName: ownerNameController.text.trim(),
        userPhoneNumber: phoneController.text.trim(),
        userPassword: passwordController.text,
        userEmail: ownerEmailController.text.trim().isEmpty
            ? null
            : ownerEmailController.text.trim(),
        userProfileLogoPath: ownerAvatar.value?.path,
        deviceUuid: device.deviceUuid,
        fcmToken: fcmToken,
        deviceName: device.deviceName,
        deviceType: device.deviceType,
      );

      final result = await _registerNetworkUseCase.execute(params);

      await CustomAnimationOverlay.hide();

      SoundService.instance.playSound(soundPath: 'sounds/netsales_success.wav');
      // إظهار حوار التأكيد والاعتماد بحالة PENDING مع خيار الدعم الهادئ والانتقال بعده لصفحة تسجيل الدخول
      await CustomDialog.showPending(
        title: 'تم استلام طلبكم بنجاح',
        message:
            '${result.message}\nيتم تدقيق ومراجعة الطلب والاعتماد عادة خلال ساعتين إلى 24 ساعة عمل.',
        confirmLabel: 'الانتقال لتسجيل الدخول',
        secondaryActionLabel: 'هل لديك استفسار؟ تواصل مع الدعم',
        secondaryActionIcon: Icons.support_agent_rounded,
        onSecondaryAction: () => UrlLauncherService.openWhatsApp(
          phoneNumber: PublicSettingsService.instance.supportWhatsApp,
          message:
              'مرحباً فريق الدعم، لقد قمت بتقديم طلب تسجيل مزود شبكة جديد في نظام NetSales وأود الاستفسار عن حالة الطلب.',
        ),
        onConfirm: () => Get.offAllNamed(AppRoutes.login),
      );


      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر إتمام طلب التسجيل',
        message: cleanMessage,
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
    networkNameController.dispose();
    networkEmailController.dispose();
    networkAddressController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ownerEmailController.dispose();
    networkLogo.dispose();
    ownerAvatar.dispose();
    selectedGovernorate.dispose();
    selectedDirectorate.dispose();
    super.onClose();
  }
}
