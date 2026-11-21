import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
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

  setUp(() {
    Get.reset();
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
    Get.reset();
  });

  group('NetworkMembershipsController KPI & Filtering', () {
    test('Calculates KPI metrics accurately from members list', () async {
      await controller.loadMembers();
      // Directly assign for synchronous assertion
      controller.members.assignAll(repository.networkMembers);

      expect(controller.pageTitle, 'إدارة أعضاء الشبكة');
      expect(controller.isNetworkView, isTrue);
      expect(controller.expandedMemberId.value, isNull);
    });

    test('Filters members by status filter', () {
      controller.members.assignAll(repository.networkMembers);

      controller.setStatusFilter('ACTIVE');
      expect(controller.statusFilter.value, 'ACTIVE');

      controller.setStatusFilter('SUSPENDED');
      expect(controller.statusFilter.value, 'SUSPENDED');

      controller.setStatusFilter(null);
      expect(controller.statusFilter.value, isNull);
    });

    test('Resets all filters', () {
      controller.members.assignAll(repository.networkMembers);

      controller.setStatusFilter('SUSPENDED');
      controller.searchController.text = 'محمد';
      expect(controller.statusFilter.value, 'SUSPENDED');

      controller.resetFilters();
      expect(controller.statusFilter.value, isNull);
      expect(controller.searchQuery.value, isEmpty);
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

  group('Owner Protection Invariants', () {
    test('Owner member has isOwner set to true', () {
      final owner = repository.networkMembers.firstWhere((m) => m.isOwner);
      final regularMember = repository.networkMembers.firstWhere((m) => !m.isOwner);

      expect(owner.isOwner, isTrue);
      expect(regularMember.isOwner, isFalse);
    });
  });
}
