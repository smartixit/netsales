import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

class TransferPosToNetworkUseCase {
  final FinanceRepository repository;

  const TransferPosToNetworkUseCase(this.repository);

  Future<void> call({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
    String? idempotencyKey,
  }) {
    return repository.transferPosToNetwork(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
      idempotencyKey: idempotencyKey,
    );
  }
}

