import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// عقد مصدر البيانات المحلي لشاشة الإقلاع
abstract interface class SplashLocalDataSource {
  /// التحقق مما إذا كان التطبيق يُفتح للمرة الأولى
  bool get isFirstLaunch;

  /// التحقق من توفر جلسة مصادقة نشطة
  bool get isAuthenticated;
}

/// تطبيق مصدر البيانات المحلي بالاعتماد على StorageService و SessionService
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  const SplashLocalDataSourceImpl();

  @override
  bool get isFirstLaunch {
    return StorageService.instance.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  @override
  bool get isAuthenticated {
    return SessionService.to.isAuthenticated;
  }
}
