import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// تطبيق مستودع إدارة أعضاء مساحات العمل الموحد
class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDataSource _remoteDataSource;

  const MembershipRepositoryImpl(this._remoteDataSource);

  // ── مساحة عمل الشبكة (Network Workspace) ──

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> getNetworkMembers(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) async {
    final response = await _remoteDataSource.getNetworkMembers(
      networkId,
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<WorkspaceMemberEntity>(
      items: response.data ?? const [],
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: (response.meta?['per_page'] as num?)?.toInt() ?? perPage,
      meta: response.meta,
    );
  }

  @override
  Future<List<MembershipRoleEntity>> getNetworkAssignableRoles(
    int networkId,
  ) async {
    final response = await _remoteDataSource.getNetworkAssignableRoles(
      networkId,
    );
    return response.data ?? [];
  }

  @override
  Future<WorkspaceMemberEntity> addNetworkMember({
    required int networkId,
    required String phoneNumber,
    required int roleId,
    String? status,
  }) async {
    final response = await _remoteDataSource.addNetworkMember(
      networkId,
      data: {
        'user_phone_number': phoneNumber,
        'role_id': roleId,
        'status': status ?? 'ACTIVE',
      },
    );
    return response.data!;
  }

  @override
  Future<WorkspaceMemberEntity> updateNetworkMemberRole({
    required int networkId,
    required int userId,
    required int roleId,
    String? reason,
  }) async {
    final response = await _remoteDataSource.updateNetworkMemberRole(
      networkId,
      userId,
      data: {
        'role_id': roleId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response.data!;
  }

  @override
  Future<WorkspaceMemberEntity> updateNetworkMemberStatus({
    required int networkId,
    required int userId,
    required String status,
    String? reason,
  }) async {
    final response = await _remoteDataSource.updateNetworkMemberStatus(
      networkId,
      userId,
      data: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response.data!;
  }

  @override
  Future<void> removeNetworkMember({
    required int networkId,
    required int userId,
    String? reason,
  }) async {
    await _remoteDataSource.removeNetworkMember(
      networkId,
      userId,
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  // ── مساحة عمل نقطة البيع (POS Workspace) ──

  @override
  Future<PaginatedList<WorkspaceMemberEntity>> getPosMembers(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) async {
    final response = await _remoteDataSource.getPosMembers(
      posId,
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<WorkspaceMemberEntity>(
      items: response.data ?? const [],
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: (response.meta?['per_page'] as num?)?.toInt() ?? perPage,
      meta: response.meta,
    );
  }

  @override
  Future<List<MembershipRoleEntity>> getPosAssignableRoles(int posId) async {
    final response = await _remoteDataSource.getPosAssignableRoles(posId);
    return response.data ?? [];
  }

  @override
  Future<WorkspaceMemberEntity> addPosMember({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String? status,
  }) async {
    final response = await _remoteDataSource.addPosMember(
      posId,
      data: {
        'user_phone_number': phoneNumber,
        'role_id': roleId,
        'status': status ?? 'ACTIVE',
      },
    );
    return response.data!;
  }

  @override
  Future<WorkspaceMemberEntity> updatePosMemberRole({
    required int posId,
    required int userId,
    required int roleId,
    String? reason,
  }) async {
    final response = await _remoteDataSource.updatePosMemberRole(
      posId,
      userId,
      data: {
        'role_id': roleId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response.data!;
  }

  @override
  Future<WorkspaceMemberEntity> updatePosMemberStatus({
    required int posId,
    required int userId,
    required String status,
    String? reason,
  }) async {
    final response = await _remoteDataSource.updatePosMemberStatus(
      posId,
      userId,
      data: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return response.data!;
  }

  @override
  Future<void> removePosMember({
    required int posId,
    required int userId,
    String? reason,
  }) async {
    await _remoteDataSource.removePosMember(
      posId,
      userId,
      data: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }
}
