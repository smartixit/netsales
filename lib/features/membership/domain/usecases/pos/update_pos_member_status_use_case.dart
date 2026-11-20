import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل حالة عضوية نقطة البيع تفعيل/تجميد (UpdatePosMemberStatusUseCase)
class UpdatePosMemberStatusUseCase {
  const UpdatePosMemberStatusUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required int userId,
    required String status,
    String? reason,
  }) =>
      repository.updatePosMemberStatus(
        posId: posId,
        userId: userId,
        status: status,
        reason: reason,
      );
}
