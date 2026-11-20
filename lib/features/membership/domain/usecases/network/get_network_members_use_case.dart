import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب أعضاء شبكة التزويد (GetNetworkMembersUseCase)
class GetNetworkMembersUseCase {
  const GetNetworkMembersUseCase(this.repository);

  final MembershipRepository repository;

  Future<List<WorkspaceMemberEntity>> call(int networkId) =>
      repository.getNetworkMembers(networkId);
}
