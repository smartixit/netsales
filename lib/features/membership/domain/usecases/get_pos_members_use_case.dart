import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب قائمة أعضاء وموظفي نقطة البيع
class GetPosMembersUseCase {
  final MembershipRepository _repository;

  const GetPosMembersUseCase(this._repository);

  Future<PaginatedList<WorkspaceMemberEntity>> call(
    int posId, {
    String? search,
    String? status,
    String? cursor,
    int perPage = 20,
  }) {
    return _repository.getPosMembers(
      posId,
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
