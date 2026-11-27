import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';

/// واجهة مستودع إدارة أعضاء مساحات العمل الموحد
abstract interface class MembershipRepository {
  // ── مساحة عمل الشبكة (Network Workspace) ──
  Future<PaginatedList<WorkspaceMemberEntity>> getNetworkMembers(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  });

  Future<List<MembershipRoleEntity>> getNetworkAssignableRoles(int networkId);

  Future<WorkspaceMemberEntity> addNetworkMember({
    required int networkId,
    required String phoneNumber,
    required int roleId,
    String? status,
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

  // ── مساحة عمل نقطة البيع (POS Workspace) ──
  Future<PaginatedList<WorkspaceMemberEntity>> getPosMembers(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  });

  Future<List<MembershipRoleEntity>> getPosAssignableRoles(int posId);

  Future<WorkspaceMemberEntity> addPosMember({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String? status,
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
