import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إنهاء وإزالة عضوية مستخدم من نقطة البيع (RemovePosMemberUseCase)
class RemovePosMemberUseCase {
  const RemovePosMemberUseCase(this.repository);

  final MembershipRepository repository;

  Future<void> call({
    required int posId,
    required int userId,
    String? reason,
  }) =>
      repository.removePosMember(
        posId: posId,
        userId: userId,
        reason: reason,
      );
}
