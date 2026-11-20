import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل دور وصلاحيات عضو نقطة البيع (UpdatePosMemberRoleUseCase)
class UpdatePosMemberRoleUseCase {
  const UpdatePosMemberRoleUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required int userId,
    required int roleId,
    String? reason,
  }) =>
      repository.updatePosMemberRole(
        posId: posId,
        userId: userId,
        roleId: roleId,
        reason: reason,
      );
}
