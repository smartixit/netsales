import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkspaceService workspaceService;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    workspaceService = WorkspaceService.instance;
    workspaceService.currentWorkspace.value = AppWorkspace.network;
    Get.put<WorkspaceService>(workspaceService);
  });

  tearDown(() {
    Get.reset();
  });

  group('Workspace and tenant context', () {
    test('dual membership supports explicit workspace preference', () {
      final dualUser = UserModel(
        userId: 100,
        userFullName: 'Dual Scope Manager',
        userPhoneNumber: '+967770000100',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.network,
            tenantId: 10,
            roleKey: 'NETWORK_OWNER',
            roleName: 'مالك الشبكة',
          ),
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 20,
            roleKey: 'POS_AGENT',
            roleName: 'وكيل نقطة البيع',
          ),
        ],
      );

      expect(workspaceService.canSwitchWorkspace(dualUser), isTrue);
      expect(
        workspaceService.resolveWorkspaceForUser(
          dualUser,
          preferredWorkspace: 'pos',
        ),
        AppWorkspace.pos,
      );
      expect(
        workspaceService.resolveWorkspaceForUser(
          dualUser,
          preferredWorkspace: 'network',
        ),
        AppWorkspace.network,
      );
    });

    test('single tenant resolves automatically but multiple tenants require choice', () async {
      expect(workspaceService.resolveWorkspaceActiveNetworkId([50]), 50);
      expect(workspaceService.resolveWorkspaceActiveNetworkId([50, 60, 70]), isNull);
      await workspaceService.saveActiveNetworkId(60);
      expect(workspaceService.resolveWorkspaceActiveNetworkId([50, 60, 70]), 60);
      expect(workspaceService.resolveWorkspaceActiveNetworkId([80, 90]), isNull);
      await workspaceService.clearActiveNetworkId();
      expect(workspaceService.savedActiveNetworkId, isNull);
    });

    test('single POS resolves automatically but multiple POS require choice', () async {
      expect(workspaceService.resolveWorkspaceActivePosId([101]), 101);
      expect(workspaceService.resolveWorkspaceActivePosId([101, 102, 103]), isNull);
      await workspaceService.saveActivePosId(102);
      expect(workspaceService.resolveWorkspaceActivePosId([101, 102, 103]), 102);
      expect(workspaceService.resolveWorkspaceActivePosId([201, 202]), isNull);
      await workspaceService.clearActivePosId();
      expect(workspaceService.savedActivePosId, isNull);
    });

    test('saved tenant is restored only when it remains authorized', () async {
      await workspaceService.saveActiveNetworkId(60);
      expect(workspaceService.resolveWorkspaceActiveNetworkId([50, 60]), 60);
      expect(workspaceService.resolveWorkspaceActiveNetworkId([50, 70]), isNull);

      await workspaceService.saveActivePosId(102);
      expect(workspaceService.resolveWorkspaceActivePosId([101, 102]), 102);
      expect(workspaceService.resolveWorkspaceActivePosId([101, 103]), isNull);
    });

    test('revoked membership context is purged during synchronization', () async {
      final storage = StorageService.instance;
      const userId = 55;

      await storage.setInt('${StorageKeys.activePosTenantPrefix}_$userId', 200);
      await storage.setInt('${StorageKeys.activePosNetworkPrefix}_${userId}_200', 88);
      await storage.setInt('${StorageKeys.activeNetworkTenantPrefix}_$userId', 99);

      final user = UserModel(
        userId: userId,
        userFullName: 'Isolated User',
        userPhoneNumber: '+967770000055',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 300,
            roleKey: 'POS_AGENT',
            roleName: 'وكيل نقطة البيع',
          ),
          WorkspaceMembershipModel(
            scope: RoleScope.network,
            tenantId: 77,
            roleKey: 'NETWORK_USER',
            roleName: 'موظف شبكة',
          ),
        ],
      );

      await workspaceService.setActiveWorkspace(AppWorkspace.network);
      await workspaceService.syncWithUserMemberships(user);

      expect(storage.getInt('${StorageKeys.activePosTenantPrefix}_$userId'), isNull);
      expect(storage.getInt('${StorageKeys.activePosNetworkPrefix}_${userId}_200'), isNull);
      expect(storage.getInt('${StorageKeys.activeNetworkTenantPrefix}_$userId'), isNull);
    });
  });
}
