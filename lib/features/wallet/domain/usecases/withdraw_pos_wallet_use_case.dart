import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام سحب / خصم مالي مباشر من محفظة نقطة البيع
class WithdrawPosWalletUseCase {
  final PosWalletRepository _repository;

  const WithdrawPosWalletUseCase(this._repository);

  Future<PosWalletEntity> call({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) {
    return _repository.withdraw(
      walletId: walletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
    );
  }
}
