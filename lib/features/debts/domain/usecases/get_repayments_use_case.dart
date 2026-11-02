import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';

class GetRepaymentsUseCase {
  final DebtsRepository repository;

  const GetRepaymentsUseCase(this.repository);

  Future<ApiResponse<List<PosRepaymentEntity>>> call({
    required int networkId,
    int? posId,
    int page = 1,
    int perPage = 20,
  }) {
    return repository.getRepayments(
      networkId: networkId,
      posId: posId,
      page: page,
      perPage: perPage,
    );
  }
}

