import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// Coordinates profile presentation and account-centre navigation.
class ProfileController extends GetxController {
  ProfileController({required this.getProfileUseCase});

  final GetProfileUseCase getProfileUseCase;

  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isUpdatingAvatar = false.obs;
  final RxBool isTwoFactorEnabled = false.obs;
  final ValueNotifier<File?> avatar = ValueNotifier<File?>(null);

  int _loadRevision = 0;

  String get displayName {
    final name =
        profile.value?.fullName.trim() ??
        SessionService.to.currentUser?.userFullName.trim() ??
        '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  Future<void> updateTwoFactor() async {
    try {
      await CustomAnimationOverlay.showLoading();
      return;
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'حدث خطأ ما!',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تسجيل رفض الطلب: $e',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// التسمية الرسمية لبيئة ومساحة العمل النشطة حالياً
  String get activeWorkspaceLabel {
    if (!Get.isRegistered<WorkspaceService>()) {
      return 'المساحة التشغيلية المعتمدة';
    }
    final ws = WorkspaceService.to.activeWorkspace;
    if (ws == AppWorkspace.network) {
      final id = WorkspaceService.to.savedActiveNetworkId;
      return id != null && id > 0 ? 'شبكة العمل المعتمدة' : 'لوحة تحكم الشبكة';
    } else {
      final id = WorkspaceService.to.savedActivePosId;
      return id != null && id > 0
          ? 'نقطة البيع المعتمدة'
          : 'لوحة تحكم نقطة البيع';
    }
  }

  /// هل التطبيق في الوضع الداكن
  bool get isDarkMode =>
      Get.isRegistered<ThemeService>() && ThemeService.to.isDarkMode;

  @override
  void onInit() {
    super.onInit();
    unawaited(loadProfile());
  }

  Future<void> loadProfile() async {
    final revision = ++_loadRevision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getProfileUseCase();
      if (revision != _loadRevision || isClosed) return;
      profile.value = result;
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

  /// نسخ نص إلى الحافظة مع تغذية حسية وإشعار عائم
  Future<void> copyToClipboard(String text, String successMessage) async {
    await UrlLauncherService.copyToClipboard(text);
  }

  /// معالجة تغيير الصورة الشخصية عبر منتقي الصور الموحد
  Future<void> onAvatarChanged(File? file) async {
    if (file == null) return;
    CustomToast.show(message: 'تم اختيار صورة شخصية جديدة بنجاح.');
  }

  /// التبديل السلس للمظهر الليلي / النهاري
  void toggleTheme() {
    if (Get.isRegistered<ThemeService>()) {
      ThemeService.to.toggleTheme();
    }
  }

  /// تسجيل الخروج الرسمي وإنهاء الجلسة
  Future<void> logout() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<SessionService>()) {
        await SessionService.to.terminateSession();
      }
    } catch (_) {
      // إكمال مسار العودة لتسجيل الدخول في حال تعذر اتصال الشبكة
    } finally {
      isLoading.value = false;
      await Get.offAllNamed<void>(AppRoutes.login);
    }
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

  Future<void> openSecuritySettings() async {
    await Get.toNamed<void>(AppRoutes.securitySettings);
  }

  Future<void> openActiveSessions() async {
    await Get.toNamed<void>(AppRoutes.activeSessions);
  }

  Future<void> openPasswordSettings() async {
    await Get.toNamed<void>(AppRoutes.securitySettings);
  }
}
