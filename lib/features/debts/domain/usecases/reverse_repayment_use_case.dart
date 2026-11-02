import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';

class ReverseRepaymentUseCase {
  final DebtsRepository repository;

  const ReverseRepaymentUseCase(this.repository);

  Future<ApiResponse<PosRepaymentEntity>> call({
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

