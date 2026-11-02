import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';

class GetReceivablesSummaryUseCase {
  final DebtsRepository repository;

  const GetReceivablesSummaryUseCase(this.repository);

  Future<ApiResponse<PosDebtSummaryEntity>> call({int? networkId, int? posId}) {
    return repository.getReceivablesSummary(networkId: networkId, posId: posId);
  }
}

