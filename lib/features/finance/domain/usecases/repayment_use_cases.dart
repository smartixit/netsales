import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

class GetRepaymentsUseCase {
  final FinanceRepository repository;

  const GetRepaymentsUseCase(this.repository);

  Future<PaginatedList<PosRepaymentEntity>> call({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getRepayments(
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

class GetRepaymentDetailsUseCase {
  final FinanceRepository repository;

  const GetRepaymentDetailsUseCase(this.repository);

  Future<PosRepaymentEntity> call(int repaymentId) {
    return repository.getRepaymentById(repaymentId);
  }
}

class CollectRepaymentUseCase {
  final FinanceRepository repository;

  const CollectRepaymentUseCase(this.repository);

  Future<PosRepaymentEntity> call({
    required int networkId,
    required int posId,
    required double amount,
    String? paymentMethod,
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

class ReverseRepaymentUseCase {
  final FinanceRepository repository;

  const ReverseRepaymentUseCase(this.repository);

  Future<PosRepaymentEntity> call({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  }) {
    return repository.reverseRepayment(
      repaymentId: repaymentId,
      reversalReason: reversalReason,
      idempotencyKey: idempotencyKey,
    );
  }
}
