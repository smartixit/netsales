import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';

class CollectRepaymentUseCase {
  final DebtsRepository repository;

  const CollectRepaymentUseCase(this.repository);

  Future<ApiResponse<PosRepaymentEntity>> call({
    required int networkId,
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  }) {
    return repository.collectRepayment(
      networkId: networkId,
      posId: posId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      idempotencyKey: idempotencyKey,
    );
  }
}

