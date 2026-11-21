import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب قائمة أعضاء وموظفي الشبكة
class GetNetworkMembersUseCase {
  final MembershipRepository _repository;

  const GetNetworkMembersUseCase(this._repository);

  Future<List<WorkspaceMemberEntity>> call(int networkId) {
    return _repository.getNetworkMembers(networkId);
  }
}
