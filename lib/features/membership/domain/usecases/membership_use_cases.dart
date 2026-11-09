import 'package:netsales/features/membership/domain/entities/membership_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

class GetMembersUseCase {
  const GetMembersUseCase(this.repository);
  final MembershipRepository repository;
  Future<List<MembershipEntity>> call(bool isNetwork, int tenantId) =>
      repository.getMembers(isNetwork: isNetwork, tenantId: tenantId);
}

class GetAssignableMembershipRolesUseCase {
  const GetAssignableMembershipRolesUseCase(this.repository);
  final MembershipRepository repository;
  Future<List<MembershipRoleEntity>> call(bool isNetwork, int tenantId) =>
      repository.getAssignableRoles(isNetwork: isNetwork, tenantId: tenantId);
}

class AddMembershipUseCase {
  const AddMembershipUseCase(this.repository);
  final MembershipRepository repository;
  Future<MembershipEntity> call(
    bool isNetwork,
    int tenantId,
    String phone,
    int roleId,
  ) => repository.addMember(
    isNetwork: isNetwork,
    tenantId: tenantId,
    phoneNumber: phone,
    roleId: roleId,
  );
}

class UpdateMembershipRoleUseCase {
  const UpdateMembershipRoleUseCase(this.repository);
  final MembershipRepository repository;
  Future<MembershipEntity> call(
    bool isNetwork,
    int tenantId,
    int userId,
    int roleId,
  ) => repository.updateRole(
    isNetwork: isNetwork,
    tenantId: tenantId,
    userId: userId,
    roleId: roleId,
  );
}

class UpdateMembershipStatusUseCase {
  const UpdateMembershipStatusUseCase(this.repository);
  final MembershipRepository repository;
  Future<MembershipEntity> call(
    bool isNetwork,
    int tenantId,
    int userId,
    String status,
  ) => repository.updateStatus(
    isNetwork: isNetwork,
    tenantId: tenantId,
    userId: userId,
    status: status,
  );
}

class RemoveMembershipUseCase {
  const RemoveMembershipUseCase(this.repository);
  final MembershipRepository repository;
  Future<void> call(bool isNetwork, int tenantId, int userId) => repository
      .removeMember(isNetwork: isNetwork, tenantId: tenantId, userId: userId);
}
