import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

/// حالة استخدام إيداع رصيد مالي مباشر في محفظة الشبكة
class DepositNetworkWalletUseCase {
  const DepositNetworkWalletUseCase(this._repository);

  final FinanceRepository _repository;

  Future<void> call({
    required int networkWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) {
    return _repository.depositToNetworkWallet(
      networkWalletId: networkWalletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
      idempotencyKey: idempotencyKey,
    );
  }
}

