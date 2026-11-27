import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netsales/features/membership/domain/entities/member_user_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/usecases/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/network_memberships_controller.dart';

import 'membership_use_cases_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMembershipRepository repository;
  late NetworkMembershipsController controller;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    repository = MockMembershipRepository();

    // Setup mock members
    repository.networkMembers = [
      const WorkspaceMemberEntity(
        id: 1,
        tenantId: 5,
        userId: 1,
        roleId: 1,
        statusRaw: 'ACTIVE',
        statusLabel: 'نشط',
        isOwner: true,
        user: MemberUserEntity(
          userId: 1,
          userUuid: 'uuid-1',
          fullName: 'المالك الرئيسي',
          phoneNumber: '777000001',
        ),
        role: MembershipRoleEntity(
          roleId: 1,
          roleKey: 'NETWORK_OWNER',
          roleName: 'مالك الشبكة',
          scope: 'NETWORK',
        ),
      ),
      const WorkspaceMemberEntity(
        id: 2,
        tenantId: 5,
        userId: 2,
        roleId: 2,
        statusRaw: 'ACTIVE',
        statusLabel: 'نشط',
        isOwner: false,
        user: MemberUserEntity(
          userId: 2,
          userUuid: 'uuid-2',
          fullName: 'علي المشغل',
          phoneNumber: '777000002',
        ),
        role: MembershipRoleEntity(
          roleId: 2,
          roleKey: 'NETWORK_USER',
          roleName: 'مشغل شبكة',
          scope: 'NETWORK',
        ),
      ),
      const WorkspaceMemberEntity(
        id: 3,
        tenantId: 5,
        userId: 3,
        roleId: 2,
        statusRaw: 'SUSPENDED',
        statusLabel: 'موقوف',
        isOwner: false,
        user: MemberUserEntity(
          userId: 3,
          userUuid: 'uuid-3',
          fullName: 'محمد الموقوف',
          phoneNumber: '777000003',
        ),
        role: MembershipRoleEntity(
          roleId: 2,
          roleKey: 'NETWORK_USER',
          roleName: 'مشغل شبكة',
          scope: 'NETWORK',
        ),
      ),
      const WorkspaceMemberEntity(
        id: 4,
        tenantId: 5,
        userId: 4,
        roleId: 3,
        statusRaw: 'INVITED',
        statusLabel: 'مدعو',
        isOwner: false,
        user: MemberUserEntity(
          userId: 4,
          userUuid: 'uuid-4',
          fullName: 'عضو جديد مدعو',
          phoneNumber: '777000004',
        ),
      ),
    ];

    repository.networkRoles = [
      const MembershipRoleEntity(
        roleId: 2,
        roleKey: 'NETWORK_USER',
        roleName: 'مشغل شبكة',
        scope: 'NETWORK',
      ),
      const MembershipRoleEntity(
        roleId: 3,
        roleKey: 'NETWORK_ACCOUNTANT',
        roleName: 'محاسب شبكة',
        scope: 'NETWORK',
      ),
    ];

    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    await WorkspaceService.to.saveActiveNetworkId(5);

    controller = NetworkMembershipsController(
      getNetworkMembersUseCase: GetNetworkMembersUseCase(repository),
      getNetworkAssignableRolesUseCase: GetNetworkAssignableRolesUseCase(repository),
      addNetworkMemberUseCase: AddNetworkMemberUseCase(repository),
      updateNetworkMemberRoleUseCase: UpdateNetworkMemberRoleUseCase(repository),
      updateNetworkMemberStatusUseCase: UpdateNetworkMemberStatusUseCase(repository),
      removeNetworkMemberUseCase: RemoveNetworkMemberUseCase(repository),
    );
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('NetworkMembershipsController KPI & Filtering', () {
    test('Calculates KPI metrics accurately from members list', () async {
      await controller.loadMembers();

      expect(controller.pageTitle, 'إدارة أعضاء الشبكة');
      expect(controller.isNetworkView, isTrue);
      expect(controller.expandedMemberId.value, isNull);
      expect(controller.totalMembersCount, 4);
      expect(controller.activeMembersCount, 2);
      expect(controller.suspendedMembersCount, 1);
      expect(controller.invitedMembersCount, 1);
    });

    test('Filters members on the server when status changes', () async {
      await controller.loadMembers();

      controller.setStatusFilter('SUSPENDED');
      await Future<void>.delayed(Duration.zero);

      expect(controller.statusFilter.value, 'SUSPENDED');
      expect(controller.members, hasLength(1));
      expect(controller.members.single.status.wireValue, 'SUSPENDED');
      expect(repository.lastArgs['status'], 'SUSPENDED');

      controller.setStatusFilter(null);
      await Future<void>.delayed(Duration.zero);
      expect(controller.statusFilter.value, isNull);
      expect(controller.members, hasLength(4));
    });

    test('Resets all server-side filters', () async {
      await controller.loadMembers();
      controller.setStatusFilter('SUSPENDED');
      await Future<void>.delayed(Duration.zero);
      controller.searchQuery.value = 'محمد';
      await controller.loadMembers();

      controller.resetFilters();
      await Future<void>.delayed(Duration.zero);
      expect(controller.statusFilter.value, isNull);
      expect(controller.searchQuery.value, isEmpty);
      expect(repository.lastArgs['search'], isNull);
      expect(repository.lastArgs['status'], isNull);
      expect(controller.members, hasLength(4));
    });

    test('ignores stale list responses after a newer search completes', () async {
      final staleResponse =
          Completer<PaginatedList<WorkspaceMemberEntity>>();
      repository.networkMembersCompleter = staleResponse;

      final staleRequest = controller.loadMembers();
      controller.searchQuery.value = 'محمد';
      await controller.loadMembers();

      expect(controller.members, hasLength(1));
      expect(controller.members.single.displayFullName, 'محمد الموقوف');

      staleResponse.complete(
        PaginatedList<WorkspaceMemberEntity>(
          items: repository.networkMembers,
          meta: {
            'summary': {
              'total': 4,
              'active': 2,
              'suspended': 1,
              'invited': 1,
            },
          },
        ),
      );
      await staleRequest;

      expect(controller.members, hasLength(1));
      expect(controller.members.single.displayFullName, 'محمد الموقوف');
    });

    test('Loads subsequent member pages without duplicates', () async {
      repository.networkNextCursor = 'next-members';
      repository.networkNextPage = [
        const WorkspaceMemberEntity(
          id: 5,
          tenantId: 5,
          userId: 5,
          roleId: 2,
          statusRaw: 'ACTIVE',
          statusLabel: 'نشط',
          isOwner: false,
        ),
      ];

      await controller.loadMembers();
      expect(controller.hasMore, isTrue);
      expect(controller.members, hasLength(4));

      await controller.loadMoreMembers();

      expect(controller.members, hasLength(5));
      expect(controller.members.map((member) => member.id).toSet(), hasLength(5));
      expect(repository.lastArgs['cursor'], 'next-members');
      expect(controller.hasMore, isFalse);
    });

    test('Accordion expansion works exclusively for single member', () {
      expect(controller.expandedMemberId.value, isNull);

      controller.toggleAccordion(2);
      expect(controller.expandedMemberId.value, 2);

      // Toggling same member collapses it
      controller.toggleAccordion(2);
      expect(controller.expandedMemberId.value, isNull);

      // Toggling another member expands only that one
      controller.toggleAccordion(3);
      expect(controller.expandedMemberId.value, 3);
      controller.toggleAccordion(4);
      expect(controller.expandedMemberId.value, 4);
    });
  });

  group('Backend RBAC contract alignment', () {
    test('uses granular Network membership capabilities independently', () {
      PermissionService.to.setWorkspaceContext(
        scope: RoleScope.network,
        tenantId: 5,
        roleKey: 'NETWORK_OWNER',
        permissions: const [
          AppPermissions.networkMembersView,
          AppPermissions.networkMembersCreate,
          AppPermissions.networkMembersChangeRole,
        ],
      );

      expect(controller.canViewMembers, isTrue);
      expect(controller.canAddMember, isTrue);
      expect(controller.canChangeMemberRole, isTrue);
      expect(controller.canChangeMemberStatus, isFalse);
      expect(controller.canRemoveMember, isFalse);
    });

    test('exposes only Network-scoped assignable roles for Network', () async {
      repository.networkRoles.add(
        const MembershipRoleEntity(
          roleId: 4,
          roleKey: 'POS_ACCOUNTANT',
          roleName: 'محاسب نقطة بيع',
          scope: 'POS',
        ),
      );

      await controller.loadAssignableRoles();

      expect(
        controller.assignableRoles.map((role) => role.roleKey).toSet(),
        {'NETWORK_USER', 'NETWORK_ACCOUNTANT'},
      );
    });
  });

  group('Owner Protection Invariants', () {
    test('Owner member has isOwner set to true', () {
      final owner = repository.networkMembers.firstWhere((m) => m.isOwner);
      final regularMember = repository.networkMembers.firstWhere((m) => !m.isOwner);

      expect(owner.isOwner, isTrue);
      expect(regularMember.isOwner, isFalse);
    });
  });
}
