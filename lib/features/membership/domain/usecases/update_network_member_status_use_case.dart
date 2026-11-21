import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل حالة تفعيل عضو الشبكة
class UpdateNetworkMemberStatusUseCase {
  final MembershipRepository _repository;

  const UpdateNetworkMemberStatusUseCase(this._repository);

  Future<WorkspaceMemberEntity> call({
    required int networkId,
    required int userId,
    required String status,
    String? reason,
  }) {
    return _repository.updateNetworkMemberStatus(
      networkId: networkId,
      userId: userId,
      status: status,
      reason: reason,
    );
  }
}
