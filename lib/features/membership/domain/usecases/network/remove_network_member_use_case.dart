import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';

/// حالة استخدام إنهاء وإزالة عضوية مستخدم من الشبكة (RemoveNetworkMemberUseCase)
class RemoveNetworkMemberUseCase {
  const RemoveNetworkMemberUseCase(this.repository);

  final MembershipRepository repository;

  Future<void> call({
    required int networkId,
    required int userId,
    String? reason,
  }) =>
      repository.removeNetworkMember(
        networkId: networkId,
        userId: userId,
        reason: reason,
      );
}
