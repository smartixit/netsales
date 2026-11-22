import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/wallet/data/datasources/pos_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_model.dart';

/// تطبيق مصدر البيانات البعيد لمحافظ نقاط البيع عبر ApiService
class PosWalletRemoteDataSourceImpl implements PosWalletRemoteDataSource {
  const PosWalletRemoteDataSourceImpl();

  @override
  Future<ApiResponse<PosWalletModel>> getWalletByNetworkAndPos(
    int networkId,
    int posId,
  ) {
    return ApiService.instance.get<PosWalletModel>(
      ApiConstants.posWalletByNetworkPos(networkId, posId),
      fromJson: (data) => PosWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> getWalletById(int walletId) {
    return ApiService.instance.get<PosWalletModel>(
      ApiConstants.posWallet(walletId),
      fromJson: (data) => PosWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<PosWalletLogModel>>> getWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PosWalletLogModel>>(
      ApiConstants.posWalletLogs(walletId),
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) =>
                    PosWalletLogModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> transferFromNetwork(
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.posWalletTransferFromNetwork,
      data: data,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> deposit(
    int walletId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.posWalletDeposit(walletId),
      data: data,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> withdraw(
    int walletId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.posWalletWithdraw(walletId),
      data: data,
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> updateCreditLimit(
    int walletId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.patch<PosWalletModel>(
      ApiConstants.posWalletCreditLimit(walletId),
      data: data,
      fromJson: (resData) =>
          PosWalletModel.fromJson(resData as Map<String, dynamic>),
    );
  }
}
