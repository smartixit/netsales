import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/domain/entities/boot_verification_unavailable_exception.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';

/// تطبيق مستودع الإقلاع بالاعتماد على مصدر البيانات المحلي
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource _dataSource;

  const SplashRepositoryImpl(this._dataSource);

  @override
  Future<void> initializeServices() {
    return _dataSource.initializeInfrastructureServices();
  }

  @override
  Future<String> getBootDestination() async {
    if (_dataSource.isAuthenticated) {
      final result = await _dataSource.validateSessionWithServer();
      return switch (result) {
        SessionValidationResult.valid => AppRoutes.dashboard,
        SessionValidationResult.unauthorized => AppRoutes.login,
        SessionValidationResult.forbidden => AppRoutes.unauthorized,
        SessionValidationResult.unavailable =>
          throw const BootVerificationUnavailableException(),
      };
    }

    return _dataSource.isFirstLaunch ? AppRoutes.onboarding : AppRoutes.welcome;
  }
}
