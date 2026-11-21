import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إضافة عضو جديد لنقطة البيع
class AddPosMemberUseCase {
  final MembershipRepository _repository;

  const AddPosMemberUseCase(this._repository);

  Future<WorkspaceMemberEntity> call({
    required int posId,
    required String phoneNumber,
    required int roleId,
    String? status,
  }) {
    return _repository.addPosMember(
      posId: posId,
      phoneNumber: phoneNumber,
      roleId: roleId,
      status: status,
    );
  }
}
