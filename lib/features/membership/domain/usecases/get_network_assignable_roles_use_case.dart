import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام جلب الأدوار المتاح إسنادها لأعضاء الشبكة
class GetNetworkAssignableRolesUseCase {
  final MembershipRepository _repository;

  const GetNetworkAssignableRolesUseCase(this._repository);

  Future<List<MembershipRoleEntity>> call(int networkId) {
    return _repository.getNetworkAssignableRoles(networkId);
  }
}
