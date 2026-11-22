import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_model.dart';

/// واجهة مصدر البيانات البعيد لمحفظة مزود الشبكة (Network Wallet Remote Data Source)
abstract interface class NetworkWalletRemoteDataSource {
  Future<ApiResponse<NetworkWalletModel>> getWalletByNetworkId(int networkId);

  Future<ApiResponse<NetworkWalletModel>> getWalletById(int walletId);

  Future<ApiResponse<List<NetworkWalletLogModel>>> getWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  });
}
