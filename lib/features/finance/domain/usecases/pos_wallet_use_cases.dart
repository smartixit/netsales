import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

class GetPosWalUseCase {
  final FinanceRepository repository;

  const GetPosWalUseCase(this.repository);

  Future<PaginatedList<PosWalletEntity>> call({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getPosWallets(
      networkId: networkId,
      posId: posId,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

class GetPosWalletByNetworkAndPosUseCase {
  final FinanceRepository repository;

  const GetPosWalletByNetworkAndPosUseCase(this.repository);

  Future<PosWalletEntity> call(int networkId, int posId) {
    return repository.getPosWalletByNetworkAndPos(networkId, posId);
  }
}

class GetPosWalletLogsUseCase {
  final FinanceRepository repository;

  const GetPosWalletLogsUseCase(this.repository);

  Future<PaginatedList<PosWalletLogEntity>> call(
    int walletId, {
    String? operationType,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getPosWalletLogs(
      walletId,
      operationType: operationType,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
