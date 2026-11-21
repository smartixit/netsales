import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إزالة وإنهاء عضوية مستخدم من الشبكة
class RemoveNetworkMemberUseCase {
  final MembershipRepository _repository;

  const RemoveNetworkMemberUseCase(this._repository);

  Future<void> call({
    required int networkId,
    required int userId,
    String? reason,
  }) {
    return _repository.removeNetworkMember(
      networkId: networkId,
      userId: userId,
      reason: reason,
    );
  }
}
