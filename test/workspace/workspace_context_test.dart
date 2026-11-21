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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    WorkspaceService.instance.currentWorkspace.value = AppWorkspace.network;
  });

  group('WorkspaceService resolution and routing', () {
    final workspaceService = WorkspaceService.instance;

    test('null session user does not resolve to a guessed workspace', () {
      expect(
        () => workspaceService.resolveWorkspaceForUser(null),
        throwsStateError,
      );
    });

    test('NETWORK_OWNER resolves to the Network workspace', () {
      final networkUser = UserModel(
        userId: 10,
        userFullName: 'Network Owner User',
        userPhoneNumber: '+967770000010',
        role: const RoleModel(
          roleId: 10,
          roleKey: 'NETWORK_OWNER',
          roleName: 'مالك الشبكة',
        ),
      );

      expect(
        workspaceService.resolveWorkspaceForUser(networkUser),
        AppWorkspace.network,
      );
    });

    test('NETWORK_USER resolves to the Network workspace', () {
      final networkUser = UserModel(
        userId: 11,
        userFullName: 'Network Staff',
        userPhoneNumber: '+967770000011',
        role: const RoleModel(
          roleId: 11,
          roleKey: 'NETWORK_USER',
          roleName: 'موظف شبكة',
        ),
      );

      expect(
        workspaceService.resolveWorkspaceForUser(networkUser),
        AppWorkspace.network,
      );
    });

    test('POS_AGENT resolves to the POS workspace', () {
      final posUser = UserModel(
        userId: 20,
        userFullName: 'POS Agent User',
        userPhoneNumber: '+967770000020',
        role: const RoleModel(
          roleId: 20,
          roleKey: 'POS_AGENT',
          roleName: 'وكيل نقطة بيع',
        ),
      );

      expect(
        workspaceService.resolveWorkspaceForUser(posUser),
        AppWorkspace.pos,
      );
    });

    test('POS_USER resolves to the POS workspace', () {
      final posUser = UserModel(
        userId: 21,
        userFullName: 'POS Staff User',
        userPhoneNumber: '+967770000021',
        role: const RoleModel(
          roleId: 21,
          roleKey: 'POS_USER',
          roleName: 'كاشف نقطة بيع',
        ),
      );

      expect(
        workspaceService.resolveWorkspaceForUser(posUser),
        AppWorkspace.pos,
      );
    });

    test('an unknown role is not routed to a guessed workspace', () {
      final unknownUser = UserModel(
        userId: 22,
        userFullName: 'Unknown',
        userPhoneNumber: '700000022',
        role: const RoleModel(
          roleId: 22,
          roleKey: 'UNRECOGNIZED_ROLE',
          roleName: 'دور غير معروف',
        ),
      );

      expect(
        () => workspaceService.resolveWorkspaceForUser(unknownUser),
        throwsStateError,
      );
    });

    test('workspaceRoute returns the route for the active supported workspace', () {
      workspaceService.currentWorkspace.value = AppWorkspace.network;
      expect(workspaceService.workspaceRoute, AppRoutes.networkWorkspace);

      workspaceService.currentWorkspace.value = AppWorkspace.pos;
      expect(workspaceService.workspaceRoute, AppRoutes.posWorkspace);
    });
  });
}
