import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// ============================================================================
/// خدمة إدارة الجلسة والهوية (Enterprise Identity & Session Lifecycle Service)
/// ============================================================================
/// تمثل المصدر الأوحد للحقيقة (Single Source of Truth) لحالة تسجيل الدخول
/// وهوية المستخدم وصلاحياته النشطة، مع المعالجة التلقائية لانتهاء الجلسة.
class SessionService extends GetxService {
  static SessionService get to => Get.find<SessionService>();

  final Rxn<UserModel> _user = Rxn<UserModel>();
  final Rxn<UserSessionModel> _session = Rxn<UserSessionModel>();
  final RxBool _isAuthenticated = false.obs;

  /// بيانات المستخدم الحالي المسجل
  UserModel? get currentUser => _user.value;

  /// بيانات جلسة المستخدم الحالية
  UserSessionModel? get currentSession => _session.value;

  /// معرف الجلسة الفعال
  String? get currentSessionId =>
      _session.value?.sessionId ?? StorageService.instance.sessionId;

  /// حالة المصادقة النشطة
  bool get isAuthenticated => _isAuthenticated.value;

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
      );
      _isAuthenticated.value = true;

      // استعادة الصلاحيات المخزنة
      final cachedPermissions = storage.getStringList(StorageKeys.permissionsStorage);
      if (Get.isRegistered<PermissionService>()) {
        PermissionService.to.updateAccess(
          roleKey: cachedUser.role?.roleKey ?? '',
          permissions: cachedPermissions,
        );
      }

      log('🔑 [SessionService] Session restored for user #${cachedUser.userId} (${cachedUser.userFullName})');
    } else {
      _isAuthenticated.value = false;
      log('ℹ️ [SessionService] No active session found.');
    }

    // ربط انتهاء الصلاحية من عميل الشبكة تلقائياً
    ApiService.onUnauthorized = () {
      log('⚠️ [SessionService] Unauthorized event received (401). Terminating session...');
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

    log('✅ [SessionService] Session started successfully for user #${user.userId}');
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

  /// إنهاء الجلسة بالكامل وتصفير الحالات والتخزين
  Future<void> terminateSession() async {
    final storage = StorageService.instance;
    await storage.clearSession();
    await storage.remove(StorageKeys.userId);
    await storage.remove(StorageKeys.userData);
    await storage.remove(StorageKeys.permissionsStorage);
    await storage.setLoggedIn(false);

    _user.value = null;
    _session.value = null;
    _isAuthenticated.value = false;

    if (Get.isRegistered<PermissionService>()) {
      PermissionService.to.clear();
    }

    log('🚪 [SessionService] Session terminated.');
  }
}
