import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';

class MockSplashDataSource implements SplashLocalDataSource {
  final bool _isFirstLaunch;
  final bool _isAuthenticated;

  const MockSplashDataSource({
    required bool isFirstLaunch,
    required bool isAuthenticated,
  })  : _isFirstLaunch = isFirstLaunch,
        _isAuthenticated = isAuthenticated;

  @override
  bool get isFirstLaunch => _isFirstLaunch;

  @override
  bool get isAuthenticated => _isAuthenticated;
}

void main() {
  group('Splash Bootstrapping Tests', () {
    test('routes to Onboarding when isFirstLaunch is true', () async {
      const dataSource = MockSplashDataSource(
        isFirstLaunch: true,
        isAuthenticated: false,
      );
      final repository = SplashRepositoryImpl(dataSource);
      final useCase = DetermineBootDestinationUseCase(repository);

      final destination = await useCase();
      expect(destination, equals(AppRoutes.onboarding));
    });

    test('routes to Dashboard when user has active session', () async {
      const dataSource = MockSplashDataSource(
        isFirstLaunch: false,
        isAuthenticated: true,
      );
      final repository = SplashRepositoryImpl(dataSource);
      final useCase = DetermineBootDestinationUseCase(repository);

      final destination = await useCase();
      expect(destination, equals(AppRoutes.dashboard));
    });

    test('routes to Welcome when user completed onboarding but not logged in', () async {
      const dataSource = MockSplashDataSource(
        isFirstLaunch: false,
        isAuthenticated: false,
      );
      final repository = SplashRepositoryImpl(dataSource);
      final useCase = DetermineBootDestinationUseCase(repository);

      final destination = await useCase();
      expect(destination, equals(AppRoutes.welcome));
    });
  });
}
