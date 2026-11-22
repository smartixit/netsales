import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/wallet/data/datasources/network_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_model.dart';

/// تطبيق مصدر البيانات البعيد لمحفظة مزود الشبكة
class NetworkWalletRemoteDataSourceImpl
    implements NetworkWalletRemoteDataSource {
  final ApiService _apiService;

  const NetworkWalletRemoteDataSourceImpl(this._apiService);

  @override
  Future<ApiResponse<NetworkWalletModel>> getWalletByNetworkId(
    int networkId,
  ) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConstants.networkWalletByNetwork(networkId),
    );

    return ApiResponse<NetworkWalletModel>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => NetworkWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<NetworkWalletModel>> getWalletById(int walletId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/network-wallets/$walletId',
    );

    return ApiResponse<NetworkWalletModel>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => NetworkWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<NetworkWalletLogModel>>> getWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConstants.networkWalletLogs(walletId),
      queryParameters: query,
    );

    return ApiResponse<List<NetworkWalletLogModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) {
        if (data is List) {
          return data
              .map(
                (item) => NetworkWalletLogModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }
}
