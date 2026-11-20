import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/server_task_runner_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';

/// ============================================================================
/// خدمة إدارة الجلسة والهوية (Enterprise Identity & Session Lifecycle Service)
/// ============================================================================
/// تمثل المصدر الأوحد للحقيقة (Single Source of Truth) لحالة تسجيل الدخول
/// وهوية المستخدم وصلاحياته وعضوياته النشطة، مع المعالجة التلقائية لانتهاء الجلسة.
class SessionService extends GetxService {
  SessionService._();

  static SessionService instance = SessionService._();

  static SessionService get to => Get.isRegistered<SessionService>()
      ? Get.find<SessionService>()
      : instance;

  final Rxn<UserModel> _user = Rxn<UserModel>();
  final Rxn<UserSessionModel> _session = Rxn<UserSessionModel>();
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isSessionVerified = false.obs;
  final RxBool _isAccessBlocked = false.obs;
  Future<void>? _terminationFuture;
  bool _handlingUnauthorized = false;

  /// بيانات المستخدم الحالي المسجل
  UserModel? get currentUser => _user.value;

  /// بيانات جلسة المستخدم الحالية
  UserSessionModel? get currentSession => _session.value;

  /// معرف الجلسة الفعال
  String? get currentSessionId =>
      _session.value?.sessionId ?? StorageService.instance.sessionId;

  /// حالة المصادقة النشطة
  bool get isAuthenticated => _isAuthenticated.value;

  /// True only after /auth/me succeeds or a fresh login succeeds.
  bool get isSessionVerified => _isSessionVerified.value;

  /// Backend denied account/device access with 403; local credentials remain intact.
  bool get isAccessBlocked => _isAccessBlocked.value;

  /// التحقق مما إذا كان المستخدم مجبراً على تغيير كلمة المرور قبل الوصول للوحة التحكم
  bool get mustChangePassword => _user.value?.mustChangePassword ?? false;

  /// تهيئة الخدمة واستعادة بيانات الجلسة من التخزين المحلي عند إقلاع التطبيق
  Future<SessionService> init() async {
    _isSessionVerified.value = false;
    _isAccessBlocked.value = false;
    final storage = StorageService.instance;
    final sessionId = storage.sessionId;
    final cachedUser = storage.getModel<UserModel>(
      StorageKeys.userData,
      UserModel.fromJson,
    );

    if (sessionId != null && sessionId.isNotEmpty && cachedUser != null) {
      _user.value = cachedUser;
      _session.value = UserSessionModel(
        sessionId: sessionId,
        userId: cachedUser.userId,
        deviceUuid: DeviceService.instance.deviceUuid,
      );
      _isAuthenticated.value = true;

      // استعادة الصلاحيات المخزنة
      final cachedPermissions = storage.getStringList(
        StorageKeys.permissionsStorage,
      );
      if (Get.isRegistered<PermissionService>()) {
        PermissionService.to.updateAccess(
          roleKey: cachedUser.primaryWorkspaceRoleKey ?? '',
          permissions: cachedPermissions,
        );
      }

      log(
        '🔑 [SessionService] Local session restored with ${cachedUser.workspaceMemberships.length} workspace memberships; awaiting server verification.',
      );
    } else {
      _isAuthenticated.value = false;
      log('ℹ️ [SessionService] No active session found.');
    }

    // ربط انتهاء الصلاحية من عميل الشبكة تلقائياً
    ApiService.onUnauthorized = () async {
      if (_handlingUnauthorized ||
          (!_isAuthenticated.value && Get.currentRoute == AppRoutes.login)) {
        return;
      }
      _handlingUnauthorized = true;
      try {
        log('⚠️ [SessionService] Protected request rejected with 401.');
        await terminateSession();
        if (Get.currentRoute != AppRoutes.login) {
          await Get.offAllNamed<void>(AppRoutes.login);
        }
      } finally {
        _handlingUnauthorized = false;
      }
    };

    return this;
  }

  /// بدء وحفظ جلسة جديدة بعد تسجيل الدخول بنجاح
  Future<void> startSession({
    required UserModel user,
    required UserSessionModel session,
    required List<String> permissions,
    String? roleKey,
  }) async {
    final storage = StorageService.instance;

    await storage.saveSession(session.sessionId);
    await storage.setInt(StorageKeys.userId, user.userId);
    await storage.setModel(StorageKeys.userData, user, (u) => u.toJson());
    await storage.setStringList(StorageKeys.permissionsStorage, permissions);
    await storage.setLoggedIn(true);

    _user.value = user;
    _session.value = session;
    _isAuthenticated.value = true;
    _isSessionVerified.value = true;
    _isAccessBlocked.value = false;

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.updateAccess(
        roleKey: roleKey ?? user.primaryWorkspaceRoleKey ?? '',
        permissions: permissions,
      );
    }

    if (Get.isRegistered<WorkspaceService>()) {
      await WorkspaceService.to.syncWithUserMemberships(user);
    }

    if (Get.isRegistered<PushNotificationService>()) {
      unawaited(PushNotificationService.to.syncTokenWithBackend());
      _releasePendingNotificationNavigationAfterFrame();
    }

    if (Get.isRegistered<ServerTaskRunnerService>()) {
      ServerTaskRunnerService.to.startForegroundHeartbeat();
    }

    log('✅ [SessionService] Authenticated session started successfully.');
  }

  /// Confirm a restored local session only after the backend accepts /auth/me.
  /// This method is idempotent and starts authenticated background work once.
  void markSessionVerified() {
    if (!_isAuthenticated.value || _isSessionVerified.value) return;

    _isSessionVerified.value = true;
    if (Get.isRegistered<PushNotificationService>()) {
      unawaited(PushNotificationService.to.syncTokenWithBackend());
      _releasePendingNotificationNavigationAfterFrame();
    }
    if (Get.isRegistered<ServerTaskRunnerService>()) {
      ServerTaskRunnerService.to.startForegroundHeartbeat();
    }
  }

  /// A 403 from /auth/me blocks protected access without deleting local credentials.
  void markSessionAccessBlocked() {
    _isAccessBlocked.value = true;
    _isSessionVerified.value = false;
  }

  void _releasePendingNotificationNavigationAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isAuthenticated.value && _isSessionVerified.value &&
          Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.markNavigationReady();
      }
    });
  }

  /// تحديث ومزامنة سياق جلسة المستخدم بالكامل وبشكل ذري
  Future<void> syncSessionProfile({
    required UserModel user,
    required List<String> permissions,
    String? roleKey,
  }) async {
    final storage = StorageService.instance;

    _user.value = user;
    await storage.setModel(StorageKeys.userData, user, (u) => u.toJson());
    await storage.setStringList(StorageKeys.permissionsStorage, permissions);

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.updateAccess(
        roleKey: roleKey ?? user.primaryWorkspaceRoleKey ?? '',
        permissions: permissions,
      );
    }

    if (Get.isRegistered<WorkspaceService>()) {
      await WorkspaceService.to.syncWithUserMemberships(user);
    }

    log('🔄 [SessionService] User profile and workspace memberships synced.');
  }

  /// تحديث بيانات المستخدم في الذاكرة والتخزين المحلي
  Future<void> updateCurrentUser(UserModel updatedUser) async {
    _user.value = updatedUser;
    await StorageService.instance.setModel(
      StorageKeys.userData,
      updatedUser,
      (u) => u.toJson(),
    );

    if (Get.isRegistered<WorkspaceService>()) {
      await WorkspaceService.to.syncWithUserMemberships(updatedUser);
    }
  }

  /// تحديث حالة تغيير كلمة المرور عند اكتمال تعيين كلمة المرور الجديدة
  Future<void> markPasswordChanged() async {
    final current = _user.value;
    if (current != null) {
      final updated = UserModel(
        userId: current.userId,
        roleId: current.roleId,
        userFullName: current.userFullName,
        userProfileLogo: current.userProfileLogo,
        userPhoneNumber: current.userPhoneNumber,
        userEmail: current.userEmail,
        user2faEnabled: current.user2faEnabled,
        mustChangePassword: false,
        status: current.status,
        statusLabel: current.statusLabel,
        lastLoginAt: current.lastLoginAt,
        role: current.role,
        rawIsSuperAdmin: current.rawIsSuperAdmin,
        generalRoleKey: current.generalRoleKey,
        workspaceMemberships: current.workspaceMemberships,
      );
      await updateCurrentUser(updated);
    }
  }

  /// إنهاء الجلسة مرة واحدة حتى لو وصلت عدة استجابات 401 بالتزامن.
  Future<void> terminateSession() {
    final activeTermination = _terminationFuture;
    if (activeTermination != null) return activeTermination;

    final termination = _performSessionTermination();
    _terminationFuture = termination;
    return termination.whenComplete(() {
      if (identical(_terminationFuture, termination)) {
        _terminationFuture = null;
      }
    });
  }

  Future<void> _performSessionTermination() async {
    _isSessionVerified.value = false;
    _isAccessBlocked.value = false;
    _isAuthenticated.value = false;
    final storage = StorageService.instance;
    await storage.clearSession();
    await storage.remove(StorageKeys.userId);
    await storage.remove(StorageKeys.userData);
    await storage.remove(StorageKeys.permissionsStorage);
    await storage.setLoggedIn(false);

    final previousUserId = _user.value?.userId;
    if (previousUserId != null) {
      final posContextKey = '${StorageKeys.activePosTenantPrefix}_$previousUserId';
      final savedPosId = storage.getInt(posContextKey);
      if (savedPosId != null) {
        await storage.remove(
          '${StorageKeys.activePosNetworkPrefix}_${previousUserId}_$savedPosId',
        );
      }
      await storage.remove(posContextKey);
      await storage.remove(
        '${StorageKeys.activeNetworkTenantPrefix}_$previousUserId',
      );
      await storage.remove(StorageKeys.activeWorkspaceKey);
    }

    _user.value = null;
    _session.value = null;

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.clear();
    }

    if (Get.isRegistered<PushNotificationService>()) {
      await PushNotificationService.to.clearFcmToken();
    }

    // Reset the singleton without resolving its lazy GetX registration.
    await ServerTaskRunnerService.instance.reset();

    // if (Get.isRegistered<WorkspaceService>()) {
    //   await WorkspaceService.to.setActiveWorkspace(AppWorkspace.unsupported);
    // }

    log('🚪 [SessionService] Session terminated.');
  }
}
