import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// تطبيق مستودع العلاقات التجارية والشركاء
class CommercialRepositoryImpl implements CommercialRepository {
  CommercialRepositoryImpl([CommercialRemoteDataSource? remoteDataSource])
      : _remote = remoteDataSource ?? Get.find<CommercialRemoteDataSource>();

  final CommercialRemoteDataSource _remote;

  @override
  Future<List<NetworkEntity>> getMyNetworks() {
    return _remote.getMyNetworks();
  }

  @override
  Future<List<PosEntity>> getMyPos() {
    return _remote.getMyPos();
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _remote.getNetworkPosList(
      networkId: networkId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _remote.getPosNetworksList(
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  }) {
    return _remote.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
    );
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int networkPosId) {
    return _remote.toggleNetworkPosLinkStatus(networkPosId);
  }

  @override
  Future<void> deleteNetworkPosLink(int networkPosId) {
    return _remote.deleteNetworkPosLink(networkPosId);
  }

  @override
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  }) {
    return _remote.createNetworkPosLinkChallenge(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  }) {
    return _remote.previewNetworkPosLinkChallenge(
      payload: payload,
      posId: posId,
      posUuid: posUuid,
    );
  }

  @override
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) {
    return _remote.confirmNetworkPosLinkChallenge(
      challengeUuid: challengeUuid,
      posId: posId,
      posUuid: posUuid,
    );
  }

  @override
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid) {
    return _remote.revokeNetworkPosLinkChallenge(challengeUuid);
  }

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) {
    return _remote.getNetworkDetails(networkId);
  }

  @override
  Future<PosEntity> getPosDetails(int posId) {
    return _remote.getPosDetails(posId);
  }
}
