import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';

/// تطبيق مصدر البيانات البعيد للكيانات والروابط التجارية
class CommercialRemoteDataSourceImpl implements CommercialRemoteDataSource {
  const CommercialRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<NetworkModel>>> getMyNetworks() {
    return ApiService.instance.get<List<NetworkModel>>(
      ApiConstants.networks,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => NetworkModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<PosModel>>> getMyPos() {
    return ApiService.instance.get<List<PosModel>>(
      ApiConstants.pos,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => PosModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<NetworkPosLinkModel>>> getNetworkPosList(
    int networkId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<NetworkPosLinkModel>>(
      ApiConstants.networkPosList(networkId),
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => NetworkPosLinkModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<NetworkPosLinkModel>>> getPosNetworksList(
    int posId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<NetworkPosLinkModel>>(
      ApiConstants.posNetworksList(posId),
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => NetworkPosLinkModel.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<NetworkPosLinkModel>> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) {
    final body = <String, dynamic>{
      'network_id': networkId,
      'pos_id': ?posId,
      'pos_uuid': ?posUuid,
      'status': ?status,
    };

    return ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPos,
      data: body,
      fromJson: NetworkPosLinkModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<NetworkPosLinkModel>> toggleNetworkPosLinkStatus(int linkId) {
    return ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPosToggleStatus(linkId),
      fromJson: NetworkPosLinkModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<void>> deleteNetworkPosLink(int linkId) {
    return ApiService.instance.delete<void>(
      ApiConstants.networkPosItem(linkId),
    );
  }

  @override
  Future<ApiResponse<NetworkModel>> getNetworkDetails(int networkId) {
    return ApiService.instance.get<NetworkModel>(
      ApiConstants.network(networkId),
      fromJson: NetworkModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<PosModel>> getPosDetails(int posId) {
    return ApiService.instance.get<PosModel>(
      ApiConstants.posItem(posId),
      fromJson: PosModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<NetworkModel>> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<NetworkModel>(
      ApiConstants.network(networkId),
      data: data,
      fromJson: NetworkModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<PosModel>> updatePosDetails(
    int posId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<PosModel>(
      ApiConstants.posItem(posId),
      data: data,
      fromJson: PosModel.fromJson,
    );
  }
}
