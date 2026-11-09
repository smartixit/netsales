import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/models/role_model.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  group('WorkspaceService Resolution & Scope Boundaries Tests', () {
    final workspaceService = WorkspaceService.instance;

    test('Null user resolves to AppWorkspace.unsupported', () {
      final workspace = workspaceService.resolveWorkspaceForUser(null);
      expect(workspace, equals(AppWorkspace.unsupported));
    });

    test('SUPER_ADMIN role is strictly resolved to AppWorkspace.unsupported (AUTH-06)', () {
      final superAdminUser = UserModel(
        userId: 1,
        userFullName: 'Super Admin User',
        userPhoneNumber: '+967770000001',
        userEmail: 'admin@platform.com',
        role: const RoleModel(
          roleId: 1,
          roleKey: 'SUPER_ADMIN',
          roleName: 'مدير المنصة',
        ),
      );

      final workspace = workspaceService.resolveWorkspaceForUser(
        superAdminUser,
      );
      expect(workspace, equals(AppWorkspace.unsupported));
    });

    test(
      'SUPPORT_AGENT role is strictly resolved to AppWorkspace.unsupported',
      () {
        final supportUser = UserModel(
          userId: 2,
          userFullName: 'Support Agent',
          userPhoneNumber: '+967770000002',
          userEmail: 'support@platform.com',
          role: const RoleModel(
            roleId: 2,
            roleKey: 'SUPPORT_AGENT',
            roleName: 'وكيل دعم فني',
          ),
        );

        final workspace = workspaceService.resolveWorkspaceForUser(supportUser);
        expect(workspace, equals(AppWorkspace.unsupported));
      },
    );

    test('NETWORK_OWNER role resolves to AppWorkspace.network', () {
      final networkUser = UserModel(
        userId: 10,
        userFullName: 'Network Owner User',
        userPhoneNumber: '+967770000010',
        userEmail: 'owner@network.com',
        role: const RoleModel(
          roleId: 10,
          roleKey: 'NETWORK_OWNER',
          roleName: 'مالك الشبكة',
        ),
      );

      final workspace = workspaceService.resolveWorkspaceForUser(networkUser);
      expect(workspace, equals(AppWorkspace.network));
    });

    test('NETWORK_USER role resolves to AppWorkspace.network', () {
      final networkUser = UserModel(
        userId: 11,
        userFullName: 'Network Staff',
        userPhoneNumber: '+967770000011',
        userEmail: 'staff@network.com',
        role: const RoleModel(
          roleId: 11,
          roleKey: 'NETWORK_USER',
          roleName: 'موظف شبكة',
        ),
      );

      final workspace = workspaceService.resolveWorkspaceForUser(networkUser);
      expect(workspace, equals(AppWorkspace.network));
    });

    test('POS_AGENT role resolves to AppWorkspace.pos', () {
      final posUser = UserModel(
        userId: 20,
        userFullName: 'POS Agent User',
        userPhoneNumber: '+967770000020',
        userEmail: 'agent@pos.com',
        role: const RoleModel(
          roleId: 20,
          roleKey: 'POS_AGENT',
          roleName: 'وكيل نقطة بيع',
        ),
      );

      final workspace = workspaceService.resolveWorkspaceForUser(posUser);
      expect(workspace, equals(AppWorkspace.pos));
    });

    test('POS_USER role resolves to AppWorkspace.pos', () {
      final posUser = UserModel(
        userId: 21,
        userFullName: 'POS Staff User',
        userPhoneNumber: '+967770000021',
        userEmail: 'posstaff@pos.com',
        role: const RoleModel(
          roleId: 21,
          roleKey: 'POS_USER',
          roleName: 'كاشف نقطة بيع',
        ),
      );

      final workspace = workspaceService.resolveWorkspaceForUser(posUser);
      expect(workspace, equals(AppWorkspace.pos));
    });

    test('workspaceRoute returns correct route strings for all workspaces', () {
      workspaceService.currentWorkspace.value = AppWorkspace.network;
      expect(
        workspaceService.workspaceRoute,
        equals(AppRoutes.networkWorkspace),
      );

      workspaceService.currentWorkspace.value = AppWorkspace.pos;
      expect(workspaceService.workspaceRoute, equals(AppRoutes.posWorkspace));

      workspaceService.currentWorkspace.value = AppWorkspace.unsupported;
      expect(
        workspaceService.workspaceRoute,
        equals(AppRoutes.unsupportedPlatform),
      );
    });
  });
}
