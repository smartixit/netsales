import 'dart:async';

import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';

/// تطبيق مصدر البيانات المحلي لشاشة الإقلاع وتنسيق الخدمات الأساسية
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  const SplashLocalDataSourceImpl();

  @override
  Future<void> initializeInfrastructureServices() async {
    // تشغيل التهيئة المتوازية للخدمات الأساسية في طبقة البنية التحتية
    await Future.wait([
      DeviceService.instance.init(),
      AppCryptoService.instance.init(),
      PushNotificationService.instance.init(),
      PublicSettingsService.instance.init(),
      InternetConnectionService.instance.initialize(),
    ]);

    // مزامنة مفاتيح السيرفر السيادية في الخلفية فور جاهزية محرك التشفير
    unawaited(
      AppCryptoService.instance.syncServerPublicKeys(
        dio: ApiService.instance.dio,
      ),
    );

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
}

