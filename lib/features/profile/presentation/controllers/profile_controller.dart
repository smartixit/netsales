import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/entities/update_profile_params.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:netsales/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_2fa_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/change_password_sheet.dart';
import 'package:netsales/features/profile/presentation/widgets/disable_2fa_sheet.dart';
import 'package:netsales/features/profile/presentation/widgets/enable_2fa_sheet.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// مُنسِّق وحدة مركز الحساب — يدير الحالة، الجلسة، المظهر، والتنقل.
class ProfileController extends GetxController {
  ProfileController({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarUseCase,
  });

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isTwoFactorEnabled = false.obs;
  final ValueNotifier<File?> avatarFile = ValueNotifier<File?>(null);

  int _loadRevision = 0;

  // -------------------------------------------------------------------------
  // Computed
  // -------------------------------------------------------------------------

  String get displayName {
    final name =
        profile.value?.fullName.trim() ??
        SessionService.to.currentUser?.userFullName.trim() ??
        '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  bool get isDarkMode =>
      Get.isRegistered<ThemeService>() && ThemeService.to.isDarkMode;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _syncTwoFactorState();
    unawaited(loadProfile());
  }

  @override
  void onClose() {
    avatarFile.dispose();
    super.onClose();
  }

  void _syncTwoFactorState() {
    final enabled =
        profile.value?.twoFactorEnabled ??
        SessionService.to.currentUser?.user2faEnabled ??
        false;
    isTwoFactorEnabled.value = enabled;
  }

  // -------------------------------------------------------------------------
  // Load Profile
  // -------------------------------------------------------------------------

  Future<void> loadProfile() async {
    final revision = ++_loadRevision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getProfileUseCase();
      if (revision != _loadRevision || isClosed) return;
      profile.value = result;
      isTwoFactorEnabled.value = result.twoFactorEnabled;
    } catch (error) {
      if (revision != _loadRevision || isClosed) return;
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل بيانات الحساب. حاول مرة أخرى.',
      );
    } finally {
      if (revision == _loadRevision && !isClosed) {
        isLoading.value = false;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Update Avatar
  // -------------------------------------------------------------------------

  void onAvatarPicked(File? file) {
    if (file == null) return;
    unawaited(uploadAvatar(file));
  }

  /// يُرفع مباشرةً عند اختيار الصورة.
  Future<void> uploadAvatar(File file) async {
    final userId = profile.value?.userId;
    if (userId == null) return;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ رفع الصورة...',
      );

      final newUrl = await updateAvatarUseCase(
        UpdateAvatarParams(userId: userId, avatar: file),
      );

      final current = profile.value;
      if (current != null && newUrl.isNotEmpty) {
        profile.value = current.copyWith(avatarUrl: newUrl);
      }

      final currentUserModel = SessionService.to.currentUser;
      if (currentUserModel != null && newUrl.isNotEmpty) {
        await SessionService.to.updateCurrentUser(
          currentUserModel.copyWith(userProfileLogo: newUrl),
        );
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحديث الصورة الشخصية بنجاح',
      );
    } catch (error) {
      avatarFile.value = null;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذّر رفع الصورة',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'حدث خطأ أثناء رفع الصورة.',
        ),
        type: SnackType.error,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Update Profile
  // -------------------------------------------------------------------------

  Future<void> submitProfileUpdate(UpdateProfileParams params) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ حفظ التعديلات...',
      );

      final updated = await updateProfileUseCase(params);

      profile.value = updated;
      isTwoFactorEnabled.value = updated.twoFactorEnabled;

      final currentUserModel = SessionService.to.currentUser;
      if (currentUserModel != null) {
        await SessionService.to.updateCurrentUser(
          currentUserModel.copyWith(
            userFullName: updated.fullName,
            userPhoneNumber: updated.phoneNumber,
            userEmail: updated.email,
            userProfileLogo: updated.avatarUrl,
          ),
        );
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم حفظ التعديلات بنجاح',
      );
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذّر حفظ التعديلات',
        message: AppException.sanitizeMessage(
          error,
          fallback: 'حدث خطأ أثناء تحديث بياناتك.',
        ),
        type: SnackType.error,
      );
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Security Actions (Sheets coordinated cleanly from Controller)
  // -------------------------------------------------------------------------

  Future<void> openChangePasswordSheet() async {
    if (Get.isRegistered<ChangePasswordController>()) {
      Get.find<ChangePasswordController>().reset();
    }
    await CustomBottomSheet.show<void>(
      title: 'تغيير كلمة المرور',
      subtitle: 'أدخل كلمة المرور الحالية ثم كلمة المرور الجديدة.',
      child: const ChangePasswordSheet(),
    );
  }

  Future<void> onTwoFactorSwitchRequested(bool enable) async {
    final twoFaController = Get.isRegistered<Profile2faController>()
        ? Get.find<Profile2faController>()
        : null;

    if (enable) {
      twoFaController?.resetEnableFlow();
      await CustomBottomSheet.show<void>(
        title: 'تفعيل التحقق بخطوتين',
        subtitle: 'سنرسل رمز تحقق إلى هاتفك المسجّل لتأكيد التفعيل.',
        child: const Enable2faSheet(),
      );
    } else {
      twoFaController?.resetDisableFlow();
      await CustomBottomSheet.show<void>(
        title: 'تعطيل التحقق بخطوتين',
        subtitle: 'أدخل كلمة المرور الحالية لتأكيد تعطيل الحماية الإضافية.',
        child: const Disable2faSheet(),
      );
    }
  }

  void onTwoFactorToggled(bool enabled) {
    isTwoFactorEnabled.value = enabled;
    final current = profile.value;
    if (current != null) {
      profile.value = current.copyWith(twoFactorEnabled: enabled);
    }
  }

  // -------------------------------------------------------------------------
  // Navigation helpers
  // -------------------------------------------------------------------------

  Future<void> openEditProfile() async {
    await Get.toNamed<void>(AppRoutes.editProfile);
  }

  Future<void> openActiveSessions() async {
    await Get.toNamed<void>(AppRoutes.activeSessions);
  }

  Future<void> openMembership(ProfileMembershipEntity membership) async {
    if (membership.tenantId <= 0) return;

    final workspace = membership.scope == RoleScope.network
        ? AppWorkspace.network
        : membership.scope == RoleScope.pos
            ? AppWorkspace.pos
            : null;
    if (workspace == null) return;

    await WorkspaceService.to.setActiveWorkspace(workspace);
    if (workspace == AppWorkspace.network) {
      await WorkspaceService.to.saveActiveNetworkId(membership.tenantId);
    } else {
      await WorkspaceService.to.saveActivePosId(membership.tenantId);
    }
    await Get.offAllNamed<void>(
      workspace == AppWorkspace.network
          ? AppRoutes.networkWorkspace
          : AppRoutes.posWorkspace,
    );
  }

  // -------------------------------------------------------------------------
  // Clipboard
  // -------------------------------------------------------------------------

  Future<void> copyToClipboard(String text, String successMessage) async {
    await UrlLauncherService.copyToClipboard(text);
    CustomSnackbar.show(
      title: successMessage,
      message: text,
      type: SnackType.success,
    );
  }

  // -------------------------------------------------------------------------
  // Theme
  // -------------------------------------------------------------------------

  void toggleTheme() {
    if (Get.isRegistered<ThemeService>()) ThemeService.to.toggleTheme();
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  Future<void> confirmAndLogout() async {
    await CustomBottomSheet.showConfirmation<void>(
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
      confirmLabel: 'خروج',
      cancelLabel: 'إلغاء',
      isDestructive: true,
      onConfirm: logout,
    );
  }

  Future<void> logout() async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تسجيل الخروج...',
      );
      if (Get.isRegistered<SessionService>()) {
        await SessionService.to.terminateSession();
      }
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    } catch (_) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    } finally {
      await Get.offAllNamed<void>(AppRoutes.login);
    }
  }
}
