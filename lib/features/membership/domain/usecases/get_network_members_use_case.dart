import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب قائمة أعضاء وموظفي الشبكة
class GetNetworkMembersUseCase {
  final MembershipRepository _repository;

  const GetNetworkMembersUseCase(this._repository);

  Future<PaginatedList<WorkspaceMemberEntity>> call(
    int networkId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) {
    return _repository.getNetworkMembers(
      networkId,
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
