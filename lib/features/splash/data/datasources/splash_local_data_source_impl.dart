import 'dart:async';
import 'dart:developer';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/package_info_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/server_task_runner_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';

/// تطبيق مصدر البيانات المحلي لشاشة الإقلاع وتنسيق الخدمات الأساسية
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  const SplashLocalDataSourceImpl();

  @override
  Future<void> initializeInfrastructureServices() async {
    // خدمات المنصة المحلية المستقلة يمكن تهيئتها بالتوازي.
    await Future.wait([
      PackageInfoService.instance.init(),
      DeviceService.instance.init(),
      AppCryptoService.instance.init(),
    ]);

    // DeviceService جاهز؛ نستعيد الجلسة ونزامن عضويات مساحة العمل محليًا.
    await SessionService.instance.init();
    await WorkspaceService.instance.init();

    // لا يُسمح بأي طلب شبكي قبل اكتمال فحص الاتصال الأولي.
    await InternetConnectionService.instance.initialize();

    // تجهيز الإشعارات اختياري ولا يحجب التحقق من الجلسة أو قرار الإقلاع.
    unawaited(PushNotificationService.instance.init());

    // الإعدادات المحلية حُمّلت في PublicSettingsService.onInit قبل أول إطار.
    // لا نحدّثها من الخادم إلا بعد اكتمال فحص الاتصال وثبوت توفر الإنترنت.
    if (InternetConnectionService.instance.isConnected) {
      unawaited(PublicSettingsService.instance.fetchSettings());
    }

    if (InternetConnectionService.instance.isConnected) {
      // عمليات عامة لا تتطلب جلسة مستخدم.
      unawaited(_warmUpBackendServer());
      unawaited(
        AppCryptoService.instance.syncServerPublicKeys(
          dio: ApiService.instance.dio,
        ),
      );
    }

    // تفعيل مراقبة الاتصال الشبكي بعد اكتمال واجهات التطبيق بأمان
    InternetConnectionService.instance.showInternetConnectionState();
  }

  @override
  bool get isFirstLaunch {
    return StorageService.instance.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  @override
  bool get isAuthenticated {
    return SessionService.to.isAuthenticated;
  }

  @override
  Future<SessionValidationResult> validateSessionWithServer() async {
    if (!await InternetConnectionService.instance.hasInternet()) {
      return SessionValidationResult.unavailable;
    }

    final response = await ApiService.instance.get<Map<String, dynamic>>(
      ApiConstants.me,
      fromJson: (json) => json is Map
          ? Map<String, dynamic>.from(json)
          : <String, dynamic>{},
    );

    if (response.statusCode == 401) {
      await SessionService.to.terminateSession();
      return SessionValidationResult.unauthorized;
    }
    if (response.statusCode == 403) {
      return SessionValidationResult.forbidden;
    }
    if (!response.success || response.statusCode != 200 || response.data == null) {
      return SessionValidationResult.unavailable;
    }

    final profileData = response.data!;
    final rawUser = profileData['user'];
    final rawPermissions = profileData['permissions'];
    if (rawUser is! Map || rawPermissions is! List) {
      return SessionValidationResult.unavailable;
    }

    try {
      final updatedUser = UserModel.fromJson({
        ...Map<String, dynamic>.from(rawUser),
        'workspace_roles': profileData['workspace_roles'] ?? const <dynamic>[],
        'is_super_admin': profileData['is_super_admin'],
        'role_key': profileData['role_key'],
      });
      final permissions = rawPermissions.map((value) => value.toString()).toList();

      await SessionService.to.syncSessionProfile(
        user: updatedUser,
        permissions: permissions,
        roleKey: profileData['role_key']?.toString(),
      );
      SessionService.to.markSessionVerified();
      return SessionValidationResult.valid;
    } catch (error, stack) {
      log('❌ [Splash] Invalid /auth/me payload.', stackTrace: stack);
      return SessionValidationResult.unavailable;
    }
  }

  /// إيقاظ الخادم وفحص صحته مسبقاً (Warm-up / Health Activity)
  /// يحل مشكلة الـ Cold Start ويفتح اتصال الـ TCP/TLS مسبقاً قبل وصول المستخدم لتسجيل الدخول
  Future<void> _warmUpBackendServer() async {
    try {
      final response = await ApiService.instance.get<Map<String, dynamic>>(
        ApiConstants.healthCheck,
        fromJson: (json) =>
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      );
      if (response.success) {
        log(
          '🟢 [Backend Health Warm-up] Server is active & ready: ${response.message}',
        );
      } else {
        log(
          '🟡 [Backend Health Warm-up] Server responded with notice: ${response.message}',
        );
      }
    } catch (e) {
      log(
        '⚠️ [Backend Health Warm-up] Server warm-up ping failed (tolerated): $e',
      );
    }
  }
}
