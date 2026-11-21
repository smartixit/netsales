import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل الدور الوظيفي لعضو نقطة البيع
class UpdatePosMemberRoleUseCase {
  final MembershipRepository _repository;

  const UpdatePosMemberRoleUseCase(this._repository);

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required int userId,
    required int roleId,
    String? reason,
  }) {
    return _repository.updatePosMemberRole(
      posId: posId,
      userId: userId,
      roleId: roleId,
      reason: reason,
    );
  }
}
