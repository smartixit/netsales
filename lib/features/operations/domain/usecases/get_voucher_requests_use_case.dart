import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام جلب طلبات توريد الكروت (GetVoucherRequestsUseCase)
/// ============================================================================
class GetVoucherRequestsUseCase {
  final OperationsRepository _repository;

  const GetVoucherRequestsUseCase(this._repository);

  Future<List<VoucherRequestEntity>> call({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  }) {
    return _repository.getVoucherRequests(
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
      perPage: perPage,
      page: page,
    );
  }
}
