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
    Get.put<WorkspaceService>(workspaceService);
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 4.1: Workspace & Tenant Context Governance Matrix', () {
    test('WorkspaceService resolves network and POS dual membership and allows switching', () {
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

      final canSwitch = workspaceService.canSwitchWorkspace(dualUser);
      expect(canSwitch, isTrue);

      final defaultWorkspace = workspaceService.resolveWorkspaceForUser(dualUser);
      expect(defaultWorkspace, equals(AppWorkspace.network));

      final posPreferred = workspaceService.resolveWorkspaceForUser(
        dualUser,
        preferredWorkspace: AppWorkspace.pos.name,
      );
      expect(posPreferred, equals(AppWorkspace.pos));
    });

    test('Network active tenant resolution and storage synchronization', () async {
      // 1. Single network -> auto resolves to that network
      expect(workspaceService.resolveActiveNetworkId([50]), equals(50));

      // 2. Multiple networks without saved selection -> returns null (forces explicit selection)
      expect(workspaceService.resolveActiveNetworkId([50, 60, 70]), isNull);

      // 3. Save active network and verify resolution
      await workspaceService.saveActiveNetworkId(60);
      expect(workspaceService.savedActiveNetworkId, equals(60));
      expect(workspaceService.resolveActiveNetworkId([50, 60, 70]), equals(60));

      // 4. If saved network is not in available authorized list -> returns null
      expect(workspaceService.resolveActiveNetworkId([80, 90]), isNull);

      // 5. Clear active network
      await workspaceService.clearActiveNetworkId();
      expect(workspaceService.savedActiveNetworkId, isNull);
    });

    test('POS active tenant resolution and storage synchronization', () async {
      // 1. Single POS -> auto resolves
      expect(workspaceService.resolveActivePosId([101]), equals(101));

      // 2. Multiple POS without saved selection -> returns null
      expect(workspaceService.resolveActivePosId([101, 102, 103]), isNull);

      // 3. Save active POS and verify resolution
      await workspaceService.saveActivePosId(102);
      expect(workspaceService.savedActivePosId, equals(102));
      expect(workspaceService.resolveActivePosId([101, 102, 103]), equals(102));

      // 4. Clear active POS
      await workspaceService.clearActivePosId();
      expect(workspaceService.savedActivePosId, isNull);
    });

    test('Strict tenant isolation: revoked membership context is purged upon sync', () async {
      final storage = StorageService.instance;
      const userId = 55;

      // Seed previous active pos and network in storage for user 55
      await storage.setInt('${StorageKeys.activePosTenantPrefix}_$userId', 200);
      await storage.setInt('${StorageKeys.activePosNetworkPrefix}_${userId}_200', 88);
      await storage.setInt('${StorageKeys.activeNetworkTenantPrefix}_$userId', 99);

      // User session updated with only POS 300 and Network 77 (200 & 99 were revoked)
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

      await workspaceService.syncWithUserMemberships(user);

      // Verification: Revoked contexts are purged from storage to prevent tenant leakage
      expect(storage.getInt('${StorageKeys.activePosTenantPrefix}_$userId'), isNull);
      expect(storage.getInt('${StorageKeys.activePosNetworkPrefix}_${userId}_200'), isNull);
      expect(storage.getInt('${StorageKeys.activeNetworkTenantPrefix}_$userId'), isNull);
    });
  });
}
