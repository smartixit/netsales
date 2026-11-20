import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب أعضاء وموظفي نقطة البيع (GetPosMembersUseCase)
class GetPosMembersUseCase {
  const GetPosMembersUseCase(this.repository);

  final MembershipRepository repository;

  Future<List<WorkspaceMemberEntity>> call(int posId) =>
      repository.getPosMembers(posId);
}
