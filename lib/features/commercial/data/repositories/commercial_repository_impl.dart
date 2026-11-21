import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// تطبيق مستودع العلاقات التجارية ونقاط البيع والشبكات
class CommercialRepositoryImpl implements CommercialRepository {
  const CommercialRepositoryImpl(this._remoteDataSource);

  final CommercialRemoteDataSource _remoteDataSource;

  @override
  Future<List<NetworkEntity>> getMyNetworks() {
    return _remoteDataSource.getMyNetworks();
  }

  @override
  Future<List<PosEntity>> getMyPos() {
    return _remoteDataSource.getMyPos();
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final paginatedModels = await _remoteDataSource.getNetworkPosList(
      networkId: networkId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );

    return PaginatedList<NetworkPosLinkEntity>(
      items: paginatedModels.items,
      nextCursor: paginatedModels.nextCursor,
      prevCursor: paginatedModels.prevCursor,
      perPage: paginatedModels.perPage,
    );
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final paginatedModels = await _remoteDataSource.getPosNetworksList(
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );

    return PaginatedList<NetworkPosLinkEntity>(
      items: paginatedModels.items,
      nextCursor: paginatedModels.nextCursor,
      prevCursor: paginatedModels.prevCursor,
      perPage: paginatedModels.perPage,
    );
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  }) {
    return _remoteDataSource.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
    );
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int networkPosId) {
    return _remoteDataSource.toggleNetworkPosLinkStatus(networkPosId);
  }

  @override
  Future<void> deleteNetworkPosLink(int networkPosId) {
    return _remoteDataSource.deleteNetworkPosLink(networkPosId);
  }

  @override
  Future<NetworkLinkablePosEntity> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  }) {
    return _remoteDataSource.resolveNetworkLinkablePos(
      networkId: networkId,
      posBusinessCode: posBusinessCode,
    );
  }

  @override
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    required String posUuid,
    int durationMinutes = 15,
  }) {
    return _remoteDataSource.createNetworkPosLinkChallenge(
      networkId: networkId,
      posUuid: posUuid,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    required String posUuid,
  }) {
    return _remoteDataSource.previewNetworkPosLinkChallenge(
      payload: payload,
      posUuid: posUuid,
    );
  }

  @override
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  }) {
    return _remoteDataSource.confirmNetworkPosLinkChallenge(
      challengeUuid: challengeUuid,
      posUuid: posUuid,
    );
  }

  @override
  Future<NetworkPosLinkChallengeStatusEntity>
  getNetworkPosLinkChallengeStatus(String challengeUuid) {
    return _remoteDataSource.getNetworkPosLinkChallengeStatus(challengeUuid);
  }

  @override
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid) {
    return _remoteDataSource.revokeNetworkPosLinkChallenge(challengeUuid);
  }

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) {
    return _remoteDataSource.getNetworkDetails(networkId);
  }

  @override
  Future<PosEntity> getPosDetails(int posId) {
    return _remoteDataSource.getPosDetails(posId);
  }
}
