import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

class GetPosWalletLogsUseCase {
  final WalletsRepository repository;

  const GetPosWalletLogsUseCase(this.repository);

  Future<ApiResponse<List<PosWalletLogEntity>>> call({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperationType,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    return repository.getPosWalletLogs(
      walletId: walletId,
      page: page,
      perPage: perPage,
      logOperationType: logOperationType,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
    );
  }
}

