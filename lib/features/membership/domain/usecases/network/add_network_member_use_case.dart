import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إضافة عضو جديد لشبكة التزويد (AddNetworkMemberUseCase)
class AddNetworkMemberUseCase {
  const AddNetworkMemberUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int networkId,
    required String phoneNumber,
    required int roleId,
    String status = 'ACTIVE',
  }) =>
      repository.addNetworkMember(
        networkId: networkId,
        phoneNumber: phoneNumber,
        roleId: roleId,
        status: status,
      );
}
