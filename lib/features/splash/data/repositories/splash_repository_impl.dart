import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';

/// تطبيق مستودع الإقلاع بالاعتماد على مصدر البيانات المحلي
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource _dataSource;

  const SplashRepositoryImpl(this._dataSource);

  @override
  Future<String> getBootDestination() async {
    // 1. إذا كان أول تشغيل للتطبيق -> توجيه لجولة التعريف (Onboarding)
    if (_dataSource.isFirstLaunch) {
      return AppRoutes.onboarding;
    }

    // 2. إذا كانت هناك جلسة مصادقة نشطة وصالحة -> توجيه للوحة التحكم (Dashboard)
    if (_dataSource.isAuthenticated) {
      return AppRoutes.dashboard;
    }

    // 3. مستخدم غير مسجل أكمل جولة التعريف سابقاً -> توجيه لواجهة الترحيب (Welcome)
    return AppRoutes.welcome;
  }
}
