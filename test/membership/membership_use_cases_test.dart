import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';
import 'package:netsales/features/membership/domain/usecases/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_status_use_case.dart';

class MockMembershipRepository implements MembershipRepository {
  List<WorkspaceMemberEntity> networkMembers = [];
  List<WorkspaceMemberEntity> posMembers = [];
  List<MembershipRoleEntity> networkRoles = [];
  List<MembershipRoleEntity> posRoles = [];

  String? lastAction;
  Map<String, dynamic> lastArgs = {};
  String? networkNextCursor;
  String? posNextCursor;
  List<WorkspaceMemberEntity> networkNextPage = [];
  List<WorkspaceMemberEntity> posNextPage = [];
  Completer<PaginatedList<WorkspaceMemberEntity>>? networkMembersCompleter;

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> getNetworkMembers(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) async {
    lastAction = 'getNetworkMembers';
    lastArgs = {
      'networkId': networkId,
      'search': search,
      'status': status,
      'cursor': cursor,
      'perPage': perPage,
    };
    final pendingResponse = networkMembersCompleter;
    networkMembersCompleter = null;
    if (pendingResponse != null) return pendingResponse.future;
    final source = cursor == null ? networkMembers : networkNextPage;
    final filtered = source.where((member) {
      final matchesStatus = status == null || member.status.wireValue == status;
      final query = search?.trim().toLowerCase() ?? '';
      final matchesSearch = query.isEmpty ||
          member.displayFullName.toLowerCase().contains(query) ||
          member.displayPhoneNumber.contains(query) ||
          member.displayReference.toLowerCase().contains(query) ||
          member.displayRoleName.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList(growable: false);
    return PaginatedList<WorkspaceMemberEntity>(
      items: filtered,
      nextCursor: cursor == null ? networkNextCursor : null,
      perPage: perPage,
      meta: {
        'summary': {
          'total': networkMembers.length,
          'active': networkMembers.where((m) => m.isActive).length,
          'suspended': networkMembers.where((m) => m.isSuspended).length,
          'invited': networkMembers.where((m) => m.isInvited).length,
        },
      },
    );
  }

  @override
  Future<List<MembershipRoleEntity>> getNetworkAssignableRoles(int networkId) async {
    lastAction = 'getNetworkAssignableRoles';
    lastArgs = {'networkId': networkId};
    return networkRoles;
  }

  @override
  Future<WorkspaceMemberEntity> addNetworkMember({
    required int networkId,
    required String phoneNumber,
    required int roleId,
    String? status,
  }) async {
    lastAction = 'addNetworkMember';
    lastArgs = {
      'networkId': networkId,
      'phoneNumber': phoneNumber,
      'roleId': roleId,
      'status': status,
    };
    final created = WorkspaceMemberEntity(
      id: 99,
      tenantId: networkId,
      userId: 99,
      roleId: roleId,
      statusRaw: status ?? 'ACTIVE',
      statusLabel: 'نشط',
      isOwner: false,
    );
    networkMembers.add(created);
    return created;
  }

  @override
  Future<WorkspaceMemberEntity> updateNetworkMemberRole({
    required int networkId,
    required int userId,
    required int roleId,
    String? reason,
  }) async {
    lastAction = 'updateNetworkMemberRole';
    lastArgs = {
      'networkId': networkId,
      'userId': userId,
      'roleId': roleId,
      'reason': reason,
    };
    return WorkspaceMemberEntity(
      id: 1,
      tenantId: networkId,
      userId: userId,
      roleId: roleId,
      statusRaw: 'ACTIVE',
      statusLabel: 'نشط',
      isOwner: false,
    );
  }

  @override
  Future<WorkspaceMemberEntity> updateNetworkMemberStatus({
    required int networkId,
    required int userId,
    required String status,
    String? reason,
  }) async {
    lastAction = 'updateNetworkMemberStatus';
    lastArgs = {
      'networkId': networkId,
      'userId': userId,
      'status': status,
      'reason': reason,
    };
    return WorkspaceMemberEntity(
      id: 1,
      tenantId: networkId,
      userId: userId,
      roleId: 1,
      statusRaw: status,
      statusLabel: 'محدث',
      isOwner: false,
    );
  }

  @override
  Future<void> removeNetworkMember({
    required int networkId,
    required int userId,
    String? reason,
  }) async {
    lastAction = 'removeNetworkMember';
    lastArgs = {
      'networkId': networkId,
      'userId': userId,
      'reason': reason,
    };
    networkMembers.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> getPosMembers(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) async {
    lastAction = 'getPosMembers';
    lastArgs = {
      'posId': posId,
      'search': search,
      'status': status,
      'cursor': cursor,
      'perPage': perPage,
    };
    final source = cursor == null ? posMembers : posNextPage;
    final filtered = source.where((member) {
      final matchesStatus = status == null || member.status.wireValue == status;
      final query = search?.trim().toLowerCase() ?? '';
      final matchesSearch = query.isEmpty ||
          member.displayFullName.toLowerCase().contains(query) ||
          member.displayPhoneNumber.contains(query) ||
          member.displayReference.toLowerCase().contains(query) ||
          member.displayRoleName.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList(growable: false);
    return PaginatedList<WorkspaceMemberEntity>(
      items: filtered,
      nextCursor: cursor == null ? posNextCursor : null,
      perPage: perPage,
      meta: {
        'summary': {
          'total': posMembers.length,
          'active': posMembers.where((m) => m.isActive).length,
          'suspended': posMembers.where((m) => m.isSuspended).length,
          'invited': posMembers.where((m) => m.isInvited).length,
        },
      },
    );
  }

  @override
  Future<List<MembershipRoleEntity>> getPosAssignableRoles(int posId) async {
    lastAction = 'getPosAssignableRoles';
    lastArgs = {'posId': posId};
    return posRoles;
  }

  @override
  Future<WorkspaceMemberEntity> addPosMember({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String? status,
  }) async {
    lastAction = 'addPosMember';
    lastArgs = {
      'posId': posId,
      'phoneNumber': phoneNumber,
      'roleId': roleId,
      'status': status,
    };
    final created = WorkspaceMemberEntity(
      id: 88,
      tenantId: posId,
      userId: 88,
      roleId: roleId,
      statusRaw: status ?? 'ACTIVE',
      statusLabel: 'نشط',
      isOwner: false,
    );
    posMembers.add(created);
    return created;
  }

  @override
  Future<WorkspaceMemberEntity> updatePosMemberRole({
    required int posId,
    required int userId,
    required int roleId,
    String? reason,
  }) async {
    lastAction = 'updatePosMemberRole';
    lastArgs = {
      'posId': posId,
      'userId': userId,
      'roleId': roleId,
      'reason': reason,
    };
    return WorkspaceMemberEntity(
      id: 2,
      tenantId: posId,
      userId: userId,
      roleId: roleId,
      statusRaw: 'ACTIVE',
      statusLabel: 'نشط',
      isOwner: false,
    );
  }

  @override
  Future<WorkspaceMemberEntity> updatePosMemberStatus({
    required int posId,
    required int userId,
    required String status,
    String? reason,
  }) async {
    lastAction = 'updatePosMemberStatus';
    lastArgs = {
      'posId': posId,
      'userId': userId,
      'status': status,
      'reason': reason,
    };
    return WorkspaceMemberEntity(
      id: 2,
      tenantId: posId,
      userId: userId,
      roleId: 2,
      statusRaw: status,
      statusLabel: 'محدث',
      isOwner: false,
    );
  }

  @override
  Future<void> removePosMember({
    required int posId,
    required int userId,
    String? reason,
  }) async {
    lastAction = 'removePosMember';
    lastArgs = {
      'posId': posId,
      'userId': userId,
      'reason': reason,
    };
    posMembers.removeWhere((m) => m.userId == userId);
  }
}

void main() {
  late MockMembershipRepository repository;

  setUp(() {
    repository = MockMembershipRepository();
  });

  group('Network Membership Use Cases', () {
    test('GetNetworkMembersUseCase delegates to repository', () async {
      final useCase = GetNetworkMembersUseCase(repository);
      repository.networkMembers = [
        const WorkspaceMemberEntity(
          id: 1,
          tenantId: 5,
          userId: 1,
          roleId: 10,
          statusRaw: 'ACTIVE',
          statusLabel: 'نشط',
          isOwner: true,
        ),
      ];

      final result = await useCase(5);

      expect(result.length, 1);
      expect(result.items.first.userId, 1);
      expect(repository.lastAction, 'getNetworkMembers');
      expect(repository.lastArgs['networkId'], 5);
    });

    test('GetNetworkAssignableRolesUseCase delegates to repository', () async {
      final useCase = GetNetworkAssignableRolesUseCase(repository);
      repository.networkRoles = [
        const MembershipRoleEntity(
          roleId: 2,
          roleKey: 'NETWORK_USER',
          roleName: 'مشغل شبكة',
          scope: 'NETWORK',
        ),
      ];

      final result = await useCase(5);

      expect(result.length, 1);
      expect(result.first.roleKey, 'NETWORK_USER');
      expect(result.first.typedRoleKey, RoleKey.networkUser);
      expect(result.first.typedScope, RoleScope.network);
      expect(repository.lastAction, 'getNetworkAssignableRoles');
    });

    test('AddNetworkMemberUseCase delegates to repository', () async {
      final useCase = AddNetworkMemberUseCase(repository);

      final result = await useCase(
        networkId: 5,
        phoneNumber: '777123456',
        roleId: 2,
        status: 'ACTIVE',
      );

      expect(result.userId, 99);
      expect(repository.lastAction, 'addNetworkMember');
      expect(repository.lastArgs['phoneNumber'], '777123456');
      expect(repository.lastArgs['roleId'], 2);
    });

    test('UpdateNetworkMemberRoleUseCase delegates to repository', () async {
      final useCase = UpdateNetworkMemberRoleUseCase(repository);

      final result = await useCase(
        networkId: 5,
        userId: 99,
        roleId: 3,
        reason: 'ترقية وظيفية',
      );

      expect(result.roleId, 3);
      expect(repository.lastAction, 'updateNetworkMemberRole');
      expect(repository.lastArgs['reason'], 'ترقية وظيفية');
    });

    test('UpdateNetworkMemberStatusUseCase delegates to repository', () async {
      final useCase = UpdateNetworkMemberStatusUseCase(repository);

      final result = await useCase(
        networkId: 5,
        userId: 99,
        status: 'SUSPENDED',
        reason: 'إيقاف مؤقت',
      );

      expect(result.status, MembershipStatus.suspended);
      expect(repository.lastAction, 'updateNetworkMemberStatus');
      expect(repository.lastArgs['status'], 'SUSPENDED');
    });

    test('RemoveNetworkMemberUseCase delegates to repository', () async {
      final useCase = RemoveNetworkMemberUseCase(repository);
      repository.networkMembers = [
        const WorkspaceMemberEntity(
          id: 99,
          tenantId: 5,
          userId: 99,
          roleId: 10,
          statusRaw: 'ACTIVE',
          statusLabel: 'نشط',
          isOwner: false,
        ),
      ];

      await useCase(networkId: 5, userId: 99, reason: 'إنهاء التعاقد');

      expect(repository.networkMembers, isEmpty);
      expect(repository.lastAction, 'removeNetworkMember');
    });
  });

  group('POS Membership Use Cases', () {
    test('GetPosMembersUseCase delegates to repository', () async {
      final useCase = GetPosMembersUseCase(repository);
      repository.posMembers = [
        const WorkspaceMemberEntity(
          id: 2,
          tenantId: 12,
          userId: 2,
          roleId: 20,
          statusRaw: 'ACTIVE',
          statusLabel: 'نشط',
          isOwner: true,
        ),
      ];

      final result = await useCase(12);

      expect(result.length, 1);
      expect(result.items.first.userId, 2);
      expect(repository.lastAction, 'getPosMembers');
      expect(repository.lastArgs['posId'], 12);
    });

    test('GetPosAssignableRolesUseCase delegates to repository', () async {
      final useCase = GetPosAssignableRolesUseCase(repository);
      repository.posRoles = [
        const MembershipRoleEntity(
          roleId: 5,
          roleKey: 'POS_USER',
          roleName: 'مشغل نقطة بيع',
          scope: 'POS',
        ),
      ];

      final result = await useCase(12);

      expect(result.length, 1);
      expect(result.first.roleKey, 'POS_USER');
      expect(result.first.typedRoleKey, RoleKey.posUser);
      expect(result.first.typedScope, RoleScope.pos);
      expect(repository.lastAction, 'getPosAssignableRoles');
    });

    test('AddPosMemberUseCase delegates to repository', () async {
      final useCase = AddPosMemberUseCase(repository);

      final result = await useCase(
        posId: 12,
        phoneNumber: '777654321',
        roleId: 5,
        status: 'ACTIVE',
      );

      expect(result.userId, 88);
      expect(repository.lastAction, 'addPosMember');
      expect(repository.lastArgs['phoneNumber'], '777654321');
    });

    test('UpdatePosMemberRoleUseCase delegates to repository', () async {
      final useCase = UpdatePosMemberRoleUseCase(repository);

      final result = await useCase(
        posId: 12,
        userId: 88,
        roleId: 6,
        reason: 'تغيير قسم',
      );

      expect(result.roleId, 6);
      expect(repository.lastAction, 'updatePosMemberRole');
    });

    test('UpdatePosMemberStatusUseCase delegates to repository', () async {
      final useCase = UpdatePosMemberStatusUseCase(repository);

      final result = await useCase(
        posId: 12,
        userId: 88,
        status: 'SUSPENDED',
      );

      expect(result.status, MembershipStatus.suspended);
      expect(repository.lastAction, 'updatePosMemberStatus');
    });

    test('RemovePosMemberUseCase delegates to repository', () async {
      final useCase = RemovePosMemberUseCase(repository);
      repository.posMembers = [
        const WorkspaceMemberEntity(
          id: 88,
          tenantId: 12,
          userId: 88,
          roleId: 5,
          statusRaw: 'ACTIVE',
          statusLabel: 'نشط',
          isOwner: false,
        ),
      ];

      await useCase(posId: 12, userId: 88);

      expect(repository.posMembers, isEmpty);
      expect(repository.lastAction, 'removePosMember');
    });
  });
}
