import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:netsales/features/splash/domain/entities/boot_verification_unavailable_exception.dart';

class _FakeSplashLocalDataSource implements SplashLocalDataSource {
  bool firstLaunch = false;
  bool authenticated = true;
  SessionValidationResult validationResult = SessionValidationResult.valid;

  @override
  bool get isFirstLaunch => firstLaunch;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<void> initializeInfrastructureServices() async {}

  @override
  Future<SessionValidationResult> validateSessionWithServer() async => validationResult;
}

void main() {
  group('Splash boot decision', () {
    late _FakeSplashLocalDataSource dataSource;
    late SplashRepositoryImpl repository;

    setUp(() {
      dataSource = _FakeSplashLocalDataSource();
      repository = SplashRepositoryImpl(dataSource);
    });

    test('a verified local session goes to dashboard even on first-launch flag', () async {
      dataSource.firstLaunch = true;
      dataSource.validationResult = SessionValidationResult.valid;
      expect(await repository.getBootDestination(), AppRoutes.dashboard);
    });

    test('a rejected session goes to login', () async {
      dataSource.validationResult = SessionValidationResult.unauthorized;
      expect(await repository.getBootDestination(), AppRoutes.login);
    });

    test('a blocked account is not treated as an expired session', () async {
      dataSource.validationResult = SessionValidationResult.forbidden;
      expect(await repository.getBootDestination(), AppRoutes.unauthorized);
    });

    test('temporary verification failure keeps a retryable boot state', () async {
      dataSource.validationResult = SessionValidationResult.unavailable;
      await expectLater(
        repository.getBootDestination(),
        throwsA(isA<BootVerificationUnavailableException>()),
      );
    });

    test('a visitor follows the onboarding or welcome path without server validation', () async {
      dataSource.authenticated = false;
      dataSource.firstLaunch = true;
      expect(await repository.getBootDestination(), AppRoutes.onboarding);

      dataSource.firstLaunch = false;
      expect(await repository.getBootDestination(), AppRoutes.welcome);
    });
  });
}
