import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/partners/data/models/network_pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_model.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_log_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد للمحافظ (WalletsRemoteDataSourceImpl)
/// ============================================================================
class WalletsRemoteDataSourceImpl implements WalletsRemoteDataSource {
  const WalletsRemoteDataSourceImpl();

  @override
  Future<ApiResponse<NetworkWalletModel>> getNetworkWallet(int networkId) {
    return ApiService.instance.get<NetworkWalletModel>(
      ApiConstants.networkWalletByNetwork(networkId),
      fromJson: (json) => NetworkWalletModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<NetworkWalletLogModel>>> getNetworkWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperation,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (logOperation != null && logOperation.isNotEmpty && logOperation != 'ALL')
        'log_operation': logOperation,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    return ApiService.instance.getList<NetworkWalletLogModel>(
      ApiConstants.networkWalletLogs(walletId),
      queryParameters: queryParams,
      fromJson: (json) => NetworkWalletLogModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> getPosWallet({
    required int networkId,
    required int posId,
  }) {
    return ApiService.instance.get<PosWalletModel>(
      ApiConstants.posWalletByNetworkPos(networkId, posId),
      fromJson: (json) => PosWalletModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperationType,
    String? fromDate,
    String? toDate,
    String? search,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (logOperationType != null && logOperationType.isNotEmpty && logOperationType != 'ALL')
        'log_operation_type': logOperationType,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    return ApiService.instance.getList<PosWalletLogModel>(
      ApiConstants.posWalletLogs(walletId),
      queryParameters: queryParams,
      fromJson: (json) => PosWalletLogModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<NetworkPosModel>>> getPosLinkedNetworks(int posId) {
    return ApiService.instance.getList<NetworkPosModel>(
      ApiConstants.posNetworksList(posId),
      fromJson: (json) => NetworkPosModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}

