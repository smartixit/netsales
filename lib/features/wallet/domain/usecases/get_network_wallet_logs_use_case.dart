import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/network_wallet_repository.dart';

/// حالة استخدام جلب قيود دفتر أستاذ محفظة مزود الشبكة مع الفلترة والترقيم التدريجي
class GetNetworkWalletLogsUseCase {
  final NetworkWalletRepository _repository;

  const GetNetworkWalletLogsUseCase(this._repository);

  Future<PaginatedList<NetworkWalletLogEntity>> call({
    required int walletId,
    WalletOperationType? operationType,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _repository.getWalletLogs(
      walletId: walletId,
      operationType: operationType,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
