import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/data/models/network_pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_model.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_log_model.dart';

/// ============================================================================
/// واجهة مصدر البيانات البعيد للمحافظ (WalletsRemoteDataSource)
/// ============================================================================
abstract class WalletsRemoteDataSource {
  Future<ApiResponse<NetworkWalletModel>> getNetworkWallet(int networkId);

  Future<ApiResponse<List<NetworkWalletLogModel>>> getNetworkWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperation,
    String? fromDate,
    String? toDate,
    String? search,
  });

  Future<ApiResponse<PosWalletModel>> getPosWallet({
    required int networkId,
    required int posId,
  });

  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperationType,
    String? fromDate,
    String? toDate,
    String? search,
  });

  Future<ApiResponse<List<NetworkPosModel>>> getPosLinkedNetworks(int posId);
}

