import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source.dart';
import 'package:netsales/features/partners/data/models/network_model.dart';
import 'package:netsales/features/partners/data/models/network_pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد للشركاء (PartnersRemoteDataSourceImpl)
/// ============================================================================
/// ينفذ استدعاءات الشبكة للواجهة الخلفية عبر [ApiService].
class PartnersRemoteDataSourceImpl implements PartnersRemoteDataSource {
  const PartnersRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<NetworkModel>>> getNetworks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty && status != 'ALL') 'status': status,
      if (governorateId != null && governorateId > 0)
        'governorate_id': governorateId,
      if (directorateId != null && directorateId > 0)
        'directorate_id': directorateId,
    };

    return ApiService.instance.getList<NetworkModel>(
      ApiConstants.networks,
      queryParameters: queryParams,
      fromJson: (json) => NetworkModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<PosModel>>> getPosList({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty && status != 'ALL') 'status': status,
      if (governorateId != null && governorateId > 0)
        'governorate_id': governorateId,
      if (directorateId != null && directorateId > 0)
        'directorate_id': directorateId,
    };

    return ApiService.instance.getList<PosModel>(
      ApiConstants.pos,
      queryParameters: queryParams,
      fromJson: (json) => PosModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<NetworkPosModel>>> getNetworkPosList({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (networkId != null && networkId > 0) 'network_id': networkId,
      if (posId != null && posId > 0) 'pos_id': posId,
      if (status != null) 'status': status ? 1 : 0,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    return ApiService.instance.getList<NetworkPosModel>(
      ApiConstants.networkPos,
      queryParameters: queryParams,
      fromJson: (json) =>
          NetworkPosModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<NetworkPosModel>> toggleNetworkPosStatus(int networkPosId) {
    return ApiService.instance.post<NetworkPosModel>(
      ApiConstants.networkPosToggleStatus(networkPosId),
      fromJson: (json) =>
          NetworkPosModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<NetworkModel>> approveNetwork(int networkId) {
    return ApiService.instance.post<NetworkModel>(
      ApiConstants.networkApprove(networkId),
      fromJson: (json) =>
          NetworkModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<void>> rejectNetwork(int networkId, String reason) {
    return ApiService.instance.post<void>(
      ApiConstants.networkReject(networkId),
      data: {'rejection_reason': reason},
    );
  }

  @override
  Future<ApiResponse<PosModel>> approvePos(int posId) {
    return ApiService.instance.post<PosModel>(
      ApiConstants.posApprove(posId),
      fromJson: (json) => PosModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<void>> rejectPos(int posId, String reason) {
    return ApiService.instance.post<void>(
      ApiConstants.posReject(posId),
      data: {'rejection_reason': reason},
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> getPosWallet({
    required int networkId,
    required int posId,
  }) {
    return ApiService.instance.get<PosWalletModel>(
      ApiConstants.posWalletByNetworkPos(networkId, posId),
      fromJson: (json) =>
          PosWalletModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<dynamic>> transferNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletTransferFromNetwork,
      data: {
        'network_id': networkId,
        'pos_id': posId,
        'amount': amount,
        if (statement != null && statement.trim().isNotEmpty)
          'statement': statement.trim(),
      },
    );
  }

  @override
  Future<ApiResponse<dynamic>> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletTransferToNetwork,
      data: {
        'network_id': networkId,
        'pos_id': posId,
        'amount': amount,
        if (statement != null && statement.trim().isNotEmpty)
          'statement': statement.trim(),
      },
    );
  }

  @override
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
  }) {
    return ApiService.instance.getList<PosWalletLogModel>(
      ApiConstants.posWalletLogs(walletId),
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      fromJson: (json) =>
          PosWalletLogModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
