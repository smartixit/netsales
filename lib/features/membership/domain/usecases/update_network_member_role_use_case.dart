import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل الدور الوظيفي لعضو الشبكة
class UpdateNetworkMemberRoleUseCase {
  final MembershipRepository _repository;

  const UpdateNetworkMemberRoleUseCase(this._repository);

  Future<WorkspaceMemberEntity> call({
    required int networkId,
    required int userId,
    required int roleId,
    String? reason,
  }) {
    return _repository.updateNetworkMemberRole(
      networkId: networkId,
      userId: userId,
      roleId: roleId,
      reason: reason,
    );
  }
}
