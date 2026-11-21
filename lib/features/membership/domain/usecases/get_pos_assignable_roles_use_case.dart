import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب الأدوار المتاح إسنادها لأعضاء نقطة البيع
class GetPosAssignableRolesUseCase {
  final MembershipRepository _repository;

  const GetPosAssignableRolesUseCase(this._repository);

  Future<List<MembershipRoleEntity>> call(int posId) {
    return _repository.getPosAssignableRoles(posId);
  }
}
