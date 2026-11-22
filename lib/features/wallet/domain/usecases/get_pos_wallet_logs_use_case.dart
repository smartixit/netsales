import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام جلب قيود دفتر أستاذ محفظة نقطة البيع مع الفلترة والترقيم بالمؤشر
class GetPosWalletLogsUseCase {
  final PosWalletRepository _repository;

  const GetPosWalletLogsUseCase(this._repository);

  Future<PaginatedList<PosWalletLogEntity>> call({
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
