import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

/// حالة استخدام سحب رصيد مالي مباشر من محفظة نقطة البيع
class WithdrawPosWalletUseCase {
  const WithdrawPosWalletUseCase(this._repository);

  final FinanceRepository _repository;

  Future<void> call({
    required int posWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) {
    return _repository.withdrawFromPosWallet(
      posWalletId: posWalletId,
      amount: amount,
      statement: statement,
      logDate: logDate,
      idempotencyKey: idempotencyKey,
    );
  }
}

