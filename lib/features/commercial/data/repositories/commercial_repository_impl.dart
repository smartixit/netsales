import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// تطبيق مستودع الكيانات والروابط التجارية
class CommercialRepositoryImpl implements CommercialRepository {
  const CommercialRepositoryImpl(this._remoteDataSource);

  final CommercialRemoteDataSource _remoteDataSource;

  @override
  Future<List<NetworkEntity>> getMyNetworks() async {
    final response = await _remoteDataSource.getMyNetworks();

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<List<PosEntity>> getMyPos() async {
    final response = await _remoteDataSource.getMyPos();

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<List<NetworkPosLinkEntity>> getNetworkPosList(
    int networkId, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _remoteDataSource.getNetworkPosList(
      networkId,
      query: query,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<List<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _remoteDataSource.getPosNetworksList(
      posId,
      query: query,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) async {
    final response = await _remoteDataSource.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      status: status,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int linkId) async {
    final response = await _remoteDataSource.toggleNetworkPosLinkStatus(linkId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<void> deleteNetworkPosLink(int linkId) async {
    final response = await _remoteDataSource.deleteNetworkPosLink(linkId);

    if (!response.success) {
      throw AppException(response.message);
    }
  }

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) async {
    final response = await _remoteDataSource.getNetworkDetails(networkId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PosEntity> getPosDetails(int posId) async {
    final response = await _remoteDataSource.getPosDetails(posId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkEntity> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateNetworkDetails(
      networkId,
      data,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PosEntity> updatePosDetails(
    int posId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updatePosDetails(posId, data);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }
}
