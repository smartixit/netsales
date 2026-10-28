import 'package:netsales/features/operations/domain/entities/sales_trend_point_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class GetSalesTrendUseCase {
  final OperationsRepository _repository;

  const GetSalesTrendUseCase(this._repository);

  Future<List<SalesTrendPointEntity>> call({
    String period = 'daily',
    int? networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  }) {
    return _repository.getSalesTrend(
      period: period,
      networkId: networkId,
      posId: posId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
