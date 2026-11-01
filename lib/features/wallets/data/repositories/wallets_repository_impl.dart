import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

/// ============================================================================
/// تطبيق مستودع المحافظ والعمليات المالية (WalletsRepositoryImpl)
/// ============================================================================
class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource remoteDataSource;

  const WalletsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<NetworkWalletEntity>> getNetworkWallet(int networkId) {
    return remoteDataSource.getNetworkWallet(networkId);
  }

  @override
  Future<ApiResponse<List<NetworkWalletLogEntity>>> getNetworkWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperation,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    return remoteDataSource.getNetworkWalletLogs(
      walletId: walletId,
      page: page,
      perPage: perPage,
      logOperation: logOperation,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
    );
  }

  @override
  Future<ApiResponse<PosWalletEntity>> getPosWallet({
    required int networkId,
    required int posId,
  }) {
    return remoteDataSource.getPosWallet(networkId: networkId, posId: posId);
  }

  @override
  Future<ApiResponse<List<PosWalletLogEntity>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperationType,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    return remoteDataSource.getPosWalletLogs(
      walletId: walletId,
      page: page,
      perPage: perPage,
      logOperationType: logOperationType,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
    );
  }

  @override
  Future<ApiResponse<List<NetworkPosEntity>>> getPosLinkedNetworks(int posId) {
    return remoteDataSource.getPosLinkedNetworks(posId);
  }
}

