import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إضافة عضو جديد لنقطة البيع (AddPosMemberUseCase)
class AddPosMemberUseCase {
  const AddPosMemberUseCase(this.repository);

  final MembershipRepository repository;

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String status = 'ACTIVE',
  }) =>
      repository.addPosMember(
        posId: posId,
        phoneNumber: phoneNumber,
        roleId: roleId,
        status: status,
      );
}
