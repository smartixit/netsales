import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';

abstract interface class MembershipRepository {
  Future<List<MembershipEntity>> getMembers({required bool isNetwork, required int tenantId});
  Future<List<MembershipRoleEntity>> getAssignableRoles({required bool isNetwork, required int tenantId});
  Future<MembershipEntity> addMember({required bool isNetwork, required int tenantId, required String phoneNumber, required int roleId});
  Future<MembershipEntity> updateRole({required bool isNetwork, required int tenantId, required int userId, required int roleId});
  Future<MembershipEntity> updateStatus({required bool isNetwork, required int tenantId, required int userId, required String status});
  Future<void> removeMember({required bool isNetwork, required int tenantId, required int userId});
}
