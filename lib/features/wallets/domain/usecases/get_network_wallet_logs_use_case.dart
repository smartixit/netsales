import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

class GetNetworkWalletLogsUseCase {
  final WalletsRepository repository;

  const GetNetworkWalletLogsUseCase(this.repository);

  Future<ApiResponse<List<NetworkWalletLogEntity>>> call({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperation,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    return repository.getNetworkWalletLogs(
      walletId: walletId,
      page: page,
      perPage: perPage,
      logOperation: logOperation,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
    );
  }
}

