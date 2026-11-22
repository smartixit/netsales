import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_model.dart';

/// واجهة مصدر البيانات البعيد لمحافظ نقاط البيع (POS Wallet Remote Data Source)
abstract interface class PosWalletRemoteDataSource {
  Future<ApiResponse<PosWalletModel>> getWalletByNetworkAndPos(
    int networkId,
    int posId,
  );

  Future<ApiResponse<PosWalletModel>> getWalletById(int walletId);

  Future<ApiResponse<List<PosWalletLogModel>>> getWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<Map<String, dynamic>>> transferFromNetwork(
    Map<String, dynamic> data,
  );

  Future<ApiResponse<Map<String, dynamic>>> deposit(
    int walletId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<Map<String, dynamic>>> withdraw(
    int walletId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<PosWalletModel>> updateCreditLimit(
    int walletId,
    Map<String, dynamic> data,
  );
}
