import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

/// حالة استخدام إيداع رصيد مالي مباشر في محفظة نقطة البيع
class DepositPosWalletUseCase {
  const DepositPosWalletUseCase(this._repository);

  final FinanceRepository _repository;

  Future<void> call({
    required int posWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) {
    return _repository.depositToPosWallet(
      posWalletId: posWalletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
      idempotencyKey: idempotencyKey,
    );
  }
}

