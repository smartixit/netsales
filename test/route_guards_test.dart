import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionService sessionService;
  late PermissionService permissionService;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance, permanent: true);

    await sessionService.init();
    permissionService = Get.put<PermissionService>(
      PermissionService.instance,
      permanent: true,
    );
    sessionService = Get.put<SessionService>(
      SessionService.instance,
      permanent: true,
    );
  });

  group('AuthGuard Tests', () {
    test('redirects unauthenticated user to AppRoutes.login', () {
      final guard = AuthGuard();
      final result = guard.redirect('/dashboard');

      expect(result, isNotNull);
      expect(result?.name, equals(AppRoutes.login));
    });

    test('allows authenticated user through (returns null)', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 1,
          userFullName: 'Test User',
          userPhoneNumber: '777000000',
        ),
        session: const UserSessionModel(sessionId: 'valid-sess-1', userId: 1),
        permissions: [AppPermissions.networksView],
      );

      final guard = AuthGuard();
      final result = guard.redirect('/dashboard');

      expect(result, isNull);
    });
  });

  group('GuestGuard Tests', () {
    test('allows unauthenticated guest through (returns null)', () {
      final guard = GuestGuard();
      final result = guard.redirect(AppRoutes.login);

      expect(result, isNull);
    });

    test('redirects authenticated user to AppRoutes.dashboard', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 1,
          userFullName: 'Test User',
          userPhoneNumber: '777000000',
        ),
        session: const UserSessionModel(sessionId: 'valid-sess-1', userId: 1),
        permissions: [],
      );

      final guard = GuestGuard();
      final result = guard.redirect(AppRoutes.login);

      expect(result, isNotNull);
      expect(result?.name, equals(AppRoutes.dashboard));
    });
  });

  group('PermissionGuardMiddleware Tests', () {
    test('redirects unauthenticated user to AppRoutes.login', () {
      final guard = PermissionGuardMiddleware(
        requiredPermission: AppPermissions.networksView,
      );
      final result = guard.redirect(AppRoutes.networks);

      expect(result, isNotNull);
      expect(result?.name, equals(AppRoutes.login));
    });

    test('bypasses checks for SUPER_ADMIN role', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 99,
          userFullName: 'Super Admin',
          userPhoneNumber: '777111222',
        ),
        session: const UserSessionModel(sessionId: 'admin-sess', userId: 99),
        permissions: [],
      );
      permissionService.updateAccess(
        roleKey: AppRoles.superAdmin,
        permissions: [],
      );

      final guard = PermissionGuardMiddleware(
        requiredPermission: AppPermissions.networksDelete,
        requiredRole: AppRoles.superAdmin,
      );
      final result = guard.redirect(AppRoutes.networks);

      expect(result, isNull);
    });

    test('redirects to AppRoutes.unauthorized when requiredPermission is missing', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 2,
          userFullName: 'Agent',
          userPhoneNumber: '777333444',
        ),
        session: const UserSessionModel(sessionId: 'agent-sess', userId: 2),
        permissions: [AppPermissions.posView],
      );
      permissionService.updateAccess(
        roleKey: AppRoles.posAgent,
        permissions: [AppPermissions.posView],
      );

      final guard = PermissionGuardMiddleware(
        requiredPermission: AppPermissions.networksDelete,
      );
      final result = guard.redirect(AppRoutes.networks);

      expect(result, isNotNull);
      expect(result?.name, equals(AppRoutes.unauthorized));
    });

    test('allows access when requiredPermission is granted', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 2,
          userFullName: 'Network Owner',
          userPhoneNumber: '777333444',
        ),
        session: const UserSessionModel(sessionId: 'net-sess', userId: 2),
        permissions: [AppPermissions.networksView],
      );
      permissionService.updateAccess(
        roleKey: AppRoles.networkOwner,
        permissions: [AppPermissions.networksView],
      );

      final guard = PermissionGuardMiddleware(
        requiredPermission: AppPermissions.networksView,
      );
      final result = guard.redirect(AppRoutes.networks);

      expect(result, isNull);
    });

    test('redirects to AppRoutes.unauthorized when requiredRole does not match', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 3,
          userFullName: 'POS Agent',
          userPhoneNumber: '777555666',
        ),
        session: const UserSessionModel(sessionId: 'pos-sess', userId: 3),
        permissions: [AppPermissions.posView],
      );
      permissionService.updateAccess(
        roleKey: AppRoles.posAgent,
        permissions: [AppPermissions.posView],
      );

      final guard = PermissionGuardMiddleware(
        requiredRole: AppRoles.networkOwner,
      );
      final result = guard.redirect(AppRoutes.networks);

      expect(result, isNotNull);
      expect(result?.name, equals(AppRoutes.unauthorized));
    });

    test('allows access when anyPermissions is satisfied', () async {
      await sessionService.startSession(
        user: UserModel(
          userId: 4,
          userFullName: 'Accountant',
          userPhoneNumber: '777888999',
        ),
        session: const UserSessionModel(sessionId: 'acc-sess', userId: 4),
        permissions: [AppPermissions.expensesView],
      );
      permissionService.updateAccess(
        roleKey: AppRoles.accountant,
        permissions: [AppPermissions.expensesView],
      );

      final guard = PermissionGuardMiddleware(
        anyPermissions: [
          AppPermissions.networksView,
          AppPermissions.expensesView,
        ],
      );
      final result = guard.redirect(AppRoutes.expenses);

      expect(result, isNull);
    });
  });
}
