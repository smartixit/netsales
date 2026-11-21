import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل حالة تفعيل عضو نقطة البيع
class UpdatePosMemberStatusUseCase {
  final MembershipRepository _repository;

  const UpdatePosMemberStatusUseCase(this._repository);

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required int userId,
    required String status,
    String? reason,
  }) {
    return _repository.updatePosMemberStatus(
      posId: posId,
      userId: userId,
      status: status,
      reason: reason,
    );
  }
}
