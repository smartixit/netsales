import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب الأدوار المسموح بإسنادها لأعضاء نقطة البيع (GetPosAssignableRolesUseCase)
class GetPosAssignableRolesUseCase {
  const GetPosAssignableRolesUseCase(this.repository);

  final MembershipRepository repository;

  Future<List<MembershipRoleEntity>> call(int posId) =>
      repository.getPosAssignableRoles(posId);
}
