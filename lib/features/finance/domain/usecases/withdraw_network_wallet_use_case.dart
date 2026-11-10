import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

/// حالة استخدام سحب رصيد مالي مباشر من محفظة الشبكة
class WithdrawNetworkWalletUseCase {
  const WithdrawNetworkWalletUseCase(this._repository);

  final FinanceRepository _repository;

  Future<void> call({
    required int networkWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) {
    return _repository.withdrawFromNetworkWallet(
      networkWalletId: networkWalletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
      idempotencyKey: idempotencyKey,
    );
  }
}

