import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// ============================================================================
/// خدمة إدارة الجلسة والهوية (Enterprise Identity & Session Lifecycle Service)
/// ============================================================================
/// تمثل المصدر الأوحد للحقيقة (Single Source of Truth) لحالة تسجيل الدخول
/// وهوية المستخدم وصلاحياته النشطة، مع المعالجة التلقائية لانتهاء الجلسة.
class SessionService extends GetxService {
  SessionService._();

  static SessionService instance = SessionService._();

  static SessionService get to => Get.find<SessionService>();

  final Rxn<UserModel> _user = Rxn<UserModel>();
  final Rxn<UserSessionModel> _session = Rxn<UserSessionModel>();
  final RxBool _isAuthenticated = false.obs;

  // سياق الكيان التشغيلي الفعال (شبكة أو نقطة بيع)
  final RxnInt _activeNetworkId = RxnInt();
  final RxnString _activeNetworkName = RxnString();
  final RxnInt _activePosId = RxnInt();
  final RxnString _activePosName = RxnString();

  /// بيانات المستخدم الحالي المسجل
  UserModel? get currentUser => _user.value;

  /// بيانات جلسة المستخدم الحالية
  UserSessionModel? get currentSession => _session.value;

  /// معرف الجلسة الفعال
  String? get currentSessionId =>
      _session.value?.sessionId ?? StorageService.instance.sessionId;

  /// حالة المصادقة النشطة
  bool get isAuthenticated => _isAuthenticated.value;

  /// معرف الشبكة النشطة الفعال
  int? get activeNetworkId => _activeNetworkId.value;

  /// اسم الشبكة النشطة الفعال
  String? get activeNetworkName => _activeNetworkName.value;

  /// معرف نقطة البيع النشطة الفعال
  int? get activePosId => _activePosId.value;

  /// اسم نقطة البيع النشطة الفعال
  String? get activePosName => _activePosName.value;

  /// التحقق مما إذا كان المستخدم مجبراً على تغيير كلمة المرور قبل الوصول للوحة التحكم
  bool get mustChangePassword => _user.value?.mustChangePassword ?? false;

  /// تهيئة الخدمة واستعادة بيانات الجلسة من التخزين المحلي عند إقلاع التطبيق
  Future<SessionService> init() async {
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

      // استعادة سياق الكيان النشط للمستخدم
      _activeNetworkId.value = storage.getInt(StorageKeys.activeNetworkId);
      _activeNetworkName.value =
          storage.getString(StorageKeys.activeNetworkName);
      _activePosId.value = storage.getInt(StorageKeys.activePosId);
      _activePosName.value = storage.getString(StorageKeys.activePosName);

      // استعادة الصلاحيات المخزنة
      final cachedPermissions = storage.getStringList(
        StorageKeys.permissionsStorage,
      );
      if (Get.isRegistered<PermissionService>()) {
        PermissionService.to.updateAccess(
          roleKey: cachedUser.role?.roleKey ?? '',
          permissions: cachedPermissions,
        );
      }

      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.syncTokenWithBackend();
      }

      log(
        '🔑 [SessionService] Session restored for user #${cachedUser.userId} (${cachedUser.userFullName})',
      );
    } else {
      _isAuthenticated.value = false;
      log('ℹ️ [SessionService] No active session found.');
    }

    // ربط انتهاء الصلاحية من عميل الشبكة تلقائياً
    ApiService.onUnauthorized = () {
      log(
        '⚠️ [SessionService] Unauthorized event received (401). Terminating session...',
      );
      terminateSession();
    };

    return this;
  }

  /// بدء وحفظ جلسة جديدة بعد تسجيل الدخول بنجاح
  Future<void> startSession({
    required UserModel user,
    required UserSessionModel session,
    required List<String> permissions,
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

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.updateAccess(
        roleKey: user.role?.roleKey ?? '',
        permissions: permissions,
      );
    }

    if (Get.isRegistered<PushNotificationService>()) {
      PushNotificationService.to.syncTokenWithBackend();
    }

    log(
      '✅ [SessionService] Session started successfully for user #${user.userId}',
    );
  }

  /// تحديث بيانات المستخدم في الذاكرة والتخزين المحلي
  Future<void> updateCurrentUser(UserModel updatedUser) async {
    _user.value = updatedUser;
    await StorageService.instance.setModel(
      StorageKeys.userData,
      updatedUser,
      (u) => u.toJson(),
    );
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
      );
      await updateCurrentUser(updated);
    }
  }

  /// تحديث وتخزين سياق الكيان النشط للمستخدم (شبكة أو نقطة بيع)
  Future<void> updateActiveTenantContext({
    int? networkId,
    String? networkName,
    int? posId,
    String? posName,
  }) async {
    final storage = StorageService.instance;
    if (networkId != null) {
      _activeNetworkId.value = networkId;
      await storage.setInt(StorageKeys.activeNetworkId, networkId);
    }
    if (networkName != null) {
      _activeNetworkName.value = networkName;
      await storage.setString(StorageKeys.activeNetworkName, networkName);
    }
    if (posId != null) {
      _activePosId.value = posId;
      await storage.setInt(StorageKeys.activePosId, posId);
    }
    if (posName != null) {
      _activePosName.value = posName;
      await storage.setString(StorageKeys.activePosName, posName);
    }
  }

  /// إنهاء الجلسة بالكامل وتصفير الحالات والتخزين
  Future<void> terminateSession() async {
    final storage = StorageService.instance;
    await storage.clearSession();
    await storage.remove(StorageKeys.userId);
    await storage.remove(StorageKeys.userData);
    await storage.remove(StorageKeys.permissionsStorage);
    await storage.remove(StorageKeys.activeNetworkId);
    await storage.remove(StorageKeys.activeNetworkName);
    await storage.remove(StorageKeys.activePosId);
    await storage.remove(StorageKeys.activePosName);
    await storage.setLoggedIn(false);

    _user.value = null;
    _session.value = null;
    _isAuthenticated.value = false;
    _activeNetworkId.value = null;
    _activeNetworkName.value = null;
    _activePosId.value = null;
    _activePosName.value = null;

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.clear();
    }

    if (Get.isRegistered<PushNotificationService>()) {
      await PushNotificationService.to.clearFcmToken();
    }

    log('🚪 [SessionService] Session terminated.');
  }
}

