import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/update_profile_params.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';

/// مُنسِّق نموذج تعديل الملف الشخصي — مُستقل عن ProfileController.
class ProfileEditFormController extends GetxController {
  ProfileEditFormController({required this.profileController});

  final ProfileController profileController;

  // -------------------------------------------------------------------------
  // Form State
  // -------------------------------------------------------------------------

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isDirty = false.obs;

  // -------------------------------------------------------------------------
  // Validators (مُوحدة من FormValidators)
  // -------------------------------------------------------------------------

  FormFieldValidator<String> get fullNameValidator =>
      FormValidators.customTextValidator(
        fieldName: 'الاسم الكامل',
        minLength: 2,
        maxLength: 100,
        minWordsCount: 1,
      );

  FormFieldValidator<String> get phoneValidator =>
      FormValidators.phoneValidator(fieldName: 'رقم الهاتف');

  FormFieldValidator<String> get emailValidator =>
      FormValidators.emailValidator(
        fieldName: 'البريد الإلكتروني',
        isRequired: false,
      );

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _populate(profileController.profile.value);
    _attachListeners();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _populate(ProfileEntity? profile) {
    if (profile == null) return;
    fullNameController.text = profile.fullName;
    phoneController.text = profile.phoneNumber;
    emailController.text = profile.email ?? '';
  }

  void _attachListeners() {
    void markDirty() => isDirty.value = true;
    fullNameController.addListener(markDirty);
    phoneController.addListener(markDirty);
    emailController.addListener(markDirty);
  }

  // -------------------------------------------------------------------------
  // Submit
  // -------------------------------------------------------------------------

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final profile = profileController.profile.value;
    if (profile == null) return;

    isLoading.value = true;
    try {
      await profileController.submitProfileUpdate(
        UpdateProfileParams(
          userId: profile.userId,
          fullName: fullNameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          email: emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
        ),
      );
      isDirty.value = false;
      Get.back<void>();
    } on AppException {
      // الخطأ يُعرض من ProfileController عبر CustomSnackbar
    } catch (_) {
      // الخطأ يُعرض من ProfileController
    } finally {
      isLoading.value = false;
    }
  }
}
