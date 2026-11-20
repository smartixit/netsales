import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';

/// العقد المجرد لمستودع إدارة أعضاء مساحات العمل (Domain Repository)
abstract interface class MembershipRepository {
  // ── عمليات مساحة عمل الشبكة (Network Workspace) ──
  Future<List<WorkspaceMemberEntity>> getNetworkMembers(int networkId);

  Future<List<MembershipRoleEntity>> getNetworkAssignableRoles(int networkId);

  Future<WorkspaceMemberEntity> addNetworkMember({
    required int networkId,
    required String phoneNumber,
    required int roleId,
    String status = 'ACTIVE',
  });

  Future<WorkspaceMemberEntity> updateNetworkMemberRole({
    required int networkId,
    required int userId,
    required int roleId,
    String? reason,
  });

  Future<WorkspaceMemberEntity> updateNetworkMemberStatus({
    required int networkId,
    required int userId,
    required String status,
    String? reason,
  });

  Future<void> removeNetworkMember({
    required int networkId,
    required int userId,
    String? reason,
  });

  // ── عمليات مساحة عمل نقطة البيع (POS Workspace) ──
  Future<List<WorkspaceMemberEntity>> getPosMembers(int posId);

  Future<List<MembershipRoleEntity>> getPosAssignableRoles(int posId);

  Future<WorkspaceMemberEntity> addPosMember({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String status = 'ACTIVE',
  });

  Future<WorkspaceMemberEntity> updatePosMemberRole({
    required int posId,
    required int userId,
    required int roleId,
    String? reason,
  });

  Future<WorkspaceMemberEntity> updatePosMemberStatus({
    required int posId,
    required int userId,
    required String status,
    String? reason,
  });

  Future<void> removePosMember({
    required int posId,
    required int userId,
    String? reason,
  });
}
