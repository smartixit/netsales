import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  const MembershipRepositoryImpl(this.remote);
  final MembershipRemoteDataSource remote;

  @override
  Future<List<MembershipEntity>> getMembers({
    required bool isNetwork,
    required int tenantId,
  }) => remote.getMembers(isNetwork, tenantId);

  @override
  Future<List<MembershipRoleEntity>> getAssignableRoles({
    required bool isNetwork,
    required int tenantId,
  }) => remote.getRoles(isNetwork, tenantId);

  @override
  Future<MembershipEntity> addMember({
    required bool isNetwork,
    required int tenantId,
    required String phoneNumber,
    required int roleId,
  }) => remote.add(isNetwork, tenantId, phoneNumber, roleId);

  @override
  Future<MembershipEntity> updateRole({
    required bool isNetwork,
    required int tenantId,
    required int userId,
    required int roleId,
  }) => remote.updateRole(isNetwork, tenantId, userId, roleId);

  @override
  Future<MembershipEntity> updateStatus({
    required bool isNetwork,
    required int tenantId,
    required int userId,
    required String status,
  }) => remote.updateStatus(isNetwork, tenantId, userId, status);

  @override
  Future<void> removeMember({
    required bool isNetwork,
    required int tenantId,
    required int userId,
  }) => remote.remove(isNetwork, tenantId, userId);
}
