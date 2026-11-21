import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب قائمة أعضاء وموظفي نقطة البيع
class GetPosMembersUseCase {
  final MembershipRepository _repository;

  const GetPosMembersUseCase(this._repository);

  Future<List<WorkspaceMemberEntity>> call(int posId) {
    return _repository.getPosMembers(posId);
  }
}
