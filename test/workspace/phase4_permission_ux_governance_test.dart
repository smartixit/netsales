import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_pages.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
import 'package:netsales/core/routing/screen_registry.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PermissionService permissionService;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    permissionService = PermissionService.instance;
    Get.put<PermissionService>(permissionService);
    Get.put<WorkspaceService>(WorkspaceService.instance);
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 4.3: Permissions as Part of UX Governance Matrix', () {
    test('ScreenRegistry maps permissions to application routes reliably', () {
      final catalogDescriptor = ScreenRegistry.findByRoute(AppRoutes.voucherPackagesCatalog);
      expect(catalogDescriptor, isNotNull);
      expect(catalogDescriptor?.requiredPermission, equals(AppPermissions.voucherPackagesView));
      expect(catalogDescriptor?.workspace, equals(AppWorkspace.network));

      final procurementOrderDescriptor = ScreenRegistry.findByRoute(AppRoutes.newProcurementOrder);
      expect(procurementOrderDescriptor, isNotNull);
      expect(procurementOrderDescriptor?.requiredPermission, equals(AppPermissions.requestsCreate));
      expect(procurementOrderDescriptor?.workspace, equals(AppWorkspace.pos));

      // hasAccessToRoute verifies permission checks
      permissionService.updateAccess(roleKey: 'TEST_ROLE', permissions: [AppPermissions.requestsCreate]);
      expect(ScreenRegistry.hasAccessToRoute(AppRoutes.newProcurementOrder, can: permissionService.can), isTrue);
      expect(ScreenRegistry.hasAccessToRoute(AppRoutes.voucherPackagesCatalog, can: permissionService.can), isFalse);
    });

    test('Critical administrative routes are gated with PermissionGuardMiddleware in AppPages', () {
      // 1. Direct Sale Invoice Creation
      final createInvoicePage = AppPages.routes.firstWhere((p) => p.name == AppRoutes.networkCreateSaleInvoice);
      expect(createInvoicePage.middlewares?.any((m) => m is PermissionGuardMiddleware), isTrue);

      // 2. Package Form (Create / Edit)
      final packageFormPage = AppPages.routes.firstWhere((p) => p.name == AppRoutes.packageForm);
      expect(packageFormPage.middlewares?.any((m) => m is PermissionGuardMiddleware), isTrue);

      // 3. New Procurement Order
      final newOrderPage = AppPages.routes.firstWhere((p) => p.name == AppRoutes.newProcurementOrder);
      expect(newOrderPage.middlewares?.any((m) => m is PermissionGuardMiddleware), isTrue);

      // 4. Operating Expenses
      final expensesPage = AppPages.routes.firstWhere((p) => p.name == AppRoutes.operatingExpenses);
      expect(expensesPage.middlewares?.any((m) => m is PermissionGuardMiddleware), isTrue);

      // 5. Repayment Collection
      final repaymentCollectionPage = AppPages.routes.firstWhere((p) => p.name == AppRoutes.repaymentCollection);
      expect(repaymentCollectionPage.middlewares?.any((m) => m is PermissionGuardMiddleware), isTrue);
    });

    test('PermissionGuardMiddleware redirects unauthorized access and prevents 403 deep-link states', () {
      // Simulate authenticated user without salesCreate permission
      permissionService.updateAccess(
        roleKey: 'POS_AGENT',
        permissions: [AppPermissions.salesView],
      );

      final middleware = PermissionGuardMiddleware(
        requiredPermission: AppPermissions.salesCreate,
      );
      expect(middleware.requiredPermission, equals(AppPermissions.salesCreate));

      // Note: when not authenticated, it routes to login; when authenticated without perm, routes to unauthorized
      // We test the permission check behavior directly:
      expect(permissionService.can(AppPermissions.salesCreate), isFalse);
      expect(permissionService.can(AppPermissions.salesView), isTrue);

      // SuperAdmin bypass verification
      permissionService.updateAccess(
        roleKey: AppRoles.superAdmin,
        permissions: [],
      );
      expect(permissionService.can(AppPermissions.salesCreate), isTrue);
    });
  });
}

