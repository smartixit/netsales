import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام إيداع مالي مباشر في محفظة نقطة البيع (سند قبض نقدي)
class DepositPosWalletUseCase {
  final PosWalletRepository _repository;

  const DepositPosWalletUseCase(this._repository);

  Future<PosWalletEntity> call({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) {
    return _repository.deposit(
      walletId: walletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
    );
  }
}
