import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام تعديل حالة عضوية الشبكة تفعيل/تجميد (UpdateNetworkMemberStatusUseCase)
class UpdateNetworkMemberStatusUseCase {
  const UpdateNetworkMemberStatusUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int networkId,
    required int userId,
    required String status,
    String? reason,
  }) =>
      repository.updateNetworkMemberStatus(
        networkId: networkId,
        userId: userId,
        status: status,
        reason: reason,
      );
}
