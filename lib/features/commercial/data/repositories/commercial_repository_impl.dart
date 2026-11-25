import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';
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
  Future<PaginatedList<NetworkEntity>> getNetworksPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  }) async {
    final page = await _remoteDataSource.getNetworksPage(
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<NetworkEntity>(
      items: page.items,
      nextCursor: page.nextCursor,
      prevCursor: page.prevCursor,
      perPage: page.perPage,
    );
  }

  @override
  Future<PaginatedList<PosEntity>> getPosPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  }) async {
    final page = await _remoteDataSource.getPosPage(
      search: search,
      status: status,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<PosEntity>(
      items: page.items,
      nextCursor: page.nextCursor,
      prevCursor: page.prevCursor,
      perPage: page.perPage,
    );
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
  Future<PaginatedList<NetworkPosAgreementEntity>> getNetworkPosAgreements({
    required int networkPosId, String? cursor, int perPage = 15,
  }) async {
    final result = await _remoteDataSource.getNetworkPosAgreements(
      networkPosId: networkPosId, cursor: cursor, perPage: perPage,
    );
    return PaginatedList<NetworkPosAgreementEntity>(
      items: result.items, nextCursor: result.nextCursor,
      prevCursor: result.prevCursor, perPage: result.perPage,
    );
  }

  @override
  Future<NetworkPosAgreementEntity> createNetworkPosAgreementDraft({
    required int networkPosId, required Map<String, dynamic> payload,
  }) => _remoteDataSource.createNetworkPosAgreementDraft(
    networkPosId: networkPosId, payload: payload,
  );

  @override
  Future<NetworkPosAgreementEntity> updateNetworkPosAgreementDraft({
    required int networkPosId, required int agreementId,
    required Map<String, dynamic> payload,
  }) => _remoteDataSource.updateNetworkPosAgreementDraft(
    networkPosId: networkPosId, agreementId: agreementId, payload: payload,
  );

  @override
  Future<NetworkPosAgreementEntity> activateNetworkPosAgreement({
    required int networkPosId, required int agreementId,
  }) => _remoteDataSource.activateNetworkPosAgreement(
    networkPosId: networkPosId, agreementId: agreementId,
  );

  @override
  Future<NetworkPosAgreementEntity> terminateNetworkPosAgreement({
    required int networkPosId, required int agreementId,
  }) => _remoteDataSource.terminateNetworkPosAgreement(
    networkPosId: networkPosId, agreementId: agreementId,
  );

  @override
  Future<PaginatedList<NetworkPosEventEntity>> getNetworkPosEvents({
    required int networkPosId, String? cursor, int perPage = 20,
  }) async {
    final result = await _remoteDataSource.getNetworkPosEvents(
      networkPosId: networkPosId, cursor: cursor, perPage: perPage,
    );
    return PaginatedList<NetworkPosEventEntity>(
      items: result.items, nextCursor: result.nextCursor,
      prevCursor: result.prevCursor, perPage: result.perPage,
    );
  }

  @override
  Future<void> restoreNetworkPosLink(int networkPosId) =>
      _remoteDataSource.restoreNetworkPosLink(networkPosId);

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getTrashedNetworkPosLinks({
    required int entityId, required bool isNetwork, String? cursor, int perPage = 15,
  }) async {
    final result = await _remoteDataSource.getTrashedNetworkPosLinks(
      entityId: entityId, isNetwork: isNetwork, cursor: cursor, perPage: perPage,
    );
    return PaginatedList<NetworkPosLinkEntity>(
      items: result.items, nextCursor: result.nextCursor,
      prevCursor: result.prevCursor, perPage: result.perPage,
    );
  }

  @override
  Future<PaginatedList<NetworkLinkablePosEntity>> searchNetworkLinkablePos({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  }) async {
    final result = await _remoteDataSource.searchNetworkLinkablePos(
      networkId: networkId,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );

    return PaginatedList<NetworkLinkablePosEntity>(
      items: result.items,
      nextCursor: result.nextCursor,
      prevCursor: result.prevCursor,
      perPage: result.perPage,
    );
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
  Future<NetworkEntity> createNetwork(Map<String, dynamic> payload) {
    return _remoteDataSource.createNetwork(payload);
  }

  @override
  Future<NetworkEntity> updateNetwork(
    int networkId,
    Map<String, dynamic> payload,
  ) {
    return _remoteDataSource.updateNetwork(networkId, payload);
  }

  @override
  Future<PosEntity> createPos(Map<String, dynamic> payload) {
    return _remoteDataSource.createPos(payload);
  }

  @override
  Future<PosEntity> updatePos(int posId, Map<String, dynamic> payload) {
    return _remoteDataSource.updatePos(posId, payload);
  }

  @override
  Future<void> deleteNetwork(int networkId) {
    return _remoteDataSource.deleteNetwork(networkId);
  }

  @override
  Future<void> deletePos(int posId) {
    return _remoteDataSource.deletePos(posId);
  }

  @override
  Future<PaginatedList<NetworkEntity>> getTrashedNetworks({
    String? search,
    String? cursor,
    int perPage = 15,
  }) async {
    final page = await _remoteDataSource.getTrashedNetworks(
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<NetworkEntity>(
      items: page.items,
      nextCursor: page.nextCursor,
      prevCursor: page.prevCursor,
      perPage: page.perPage,
    );
  }

  @override
  Future<void> restoreNetwork(int networkId) =>
      _remoteDataSource.restoreNetwork(networkId);

  @override
  Future<PaginatedList<PosEntity>> getTrashedPos({
    String? search,
    String? cursor,
    int perPage = 15,
  }) async {
    final page = await _remoteDataSource.getTrashedPos(
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<PosEntity>(
      items: page.items,
      nextCursor: page.nextCursor,
      prevCursor: page.prevCursor,
      perPage: page.perPage,
    );
  }

  @override
  Future<void> restorePos(int posId) => _remoteDataSource.restorePos(posId);

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) {
    return _remoteDataSource.getNetworkDetails(networkId);
  }

  @override
  Future<PosEntity> getPosDetails(int posId) {
    return _remoteDataSource.getPosDetails(posId);
  }
}
