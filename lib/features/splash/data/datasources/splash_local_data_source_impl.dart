import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';

/// تطبيق مصدر البيانات المحلي لشاشة الإقلاع بالاعتماد على StorageService و SessionService
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
