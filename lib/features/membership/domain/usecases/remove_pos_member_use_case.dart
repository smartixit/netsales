import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إزالة وإنهاء عضوية مستخدم من نقطة البيع
class RemovePosMemberUseCase {
  final MembershipRepository _repository;

  const RemovePosMemberUseCase(this._repository);

  Future<void> call({
    required int posId,
    required int userId,
    String? reason,
  }) {
    return _repository.removePosMember(
      posId: posId,
      userId: userId,
      reason: reason,
    );
  }
}
