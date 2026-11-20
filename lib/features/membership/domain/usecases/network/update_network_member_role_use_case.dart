import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل دور وصلاحيات عضو الشبكة (UpdateNetworkMemberRoleUseCase)
class UpdateNetworkMemberRoleUseCase {
  const UpdateNetworkMemberRoleUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int networkId,
    required int userId,
    required int roleId,
    String? reason,
  }) =>
      repository.updateNetworkMemberRole(
        networkId: networkId,
        userId: userId,
        roleId: roleId,
        reason: reason,
      );
}
