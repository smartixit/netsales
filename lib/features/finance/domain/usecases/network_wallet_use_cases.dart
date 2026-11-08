import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

class GetNetworkWalletsUseCase {
  final FinanceRepository repository;

  const GetNetworkWalletsUseCase(this.repository);

  Future<PaginatedList<NetworkWalletEntity>> call({
    int? networkId,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getNetworkWallets(
      networkId: networkId,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

class GetNetworkWalletByIdUseCase {
  final FinanceRepository repository;

  const GetNetworkWalletByIdUseCase(this.repository);

  Future<NetworkWalletEntity> call(int walletId) {
    return repository.getNetworkWalletById(walletId);
  }
}

class GetNetworkWalletLogsUseCase {
  final FinanceRepository repository;

  const GetNetworkWalletLogsUseCase(this.repository);

  Future<PaginatedList<NetworkWalletLogEntity>> call(
    int walletId, {
    String? operation,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getNetworkWalletLogs(
      walletId,
      operation: operation,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

class TransferFromNetworkToPosUseCase {
  final FinanceRepository repository;

  const TransferFromNetworkToPosUseCase(this.repository);

  Future<void> call({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
    String? idempotencyKey,
  }) {
    return repository.transferFromNetworkToPos(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
      idempotencyKey: idempotencyKey,
    );
  }
}

