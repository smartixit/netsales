import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/models/network_linkable_pos_model.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_status_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_agreement_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_event_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';

/// العقد التجريدي لمصدر البيانات البعيد للعلاقات التجارية
abstract class CommercialRemoteDataSource {
  Future<List<NetworkModel>> getMyNetworks();

  Future<List<PosModel>> getMyPos();

  Future<PaginatedList<NetworkModel>> getNetworksPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  });

  Future<PaginatedList<PosModel>> getPosPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  });

  Future<PaginatedList<NetworkPosLinkModel>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  Future<PaginatedList<NetworkPosLinkModel>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  Future<NetworkPosLinkModel> createNetworkPosLink({
    required int networkId,
    required int posId,
  });

  Future<NetworkPosLinkModel> toggleNetworkPosLinkStatus(int networkPosId);

  Future<void> deleteNetworkPosLink(int networkPosId);

  Future<PaginatedList<NetworkPosAgreementModel>> getNetworkPosAgreements({
    required int networkPosId,
    String? cursor,
    int perPage = 15,
  });

  Future<NetworkPosAgreementModel> createNetworkPosAgreementDraft({
    required int networkPosId,
    required Map<String, dynamic> payload,
  });

  Future<NetworkPosAgreementModel> updateNetworkPosAgreementDraft({
    required int networkPosId,
    required int agreementId,
    required Map<String, dynamic> payload,
  });

  Future<NetworkPosAgreementModel> activateNetworkPosAgreement({
    required int networkPosId,
    required int agreementId,
  });

  Future<NetworkPosAgreementModel> terminateNetworkPosAgreement({
    required int networkPosId,
    required int agreementId,
  });

  Future<PaginatedList<NetworkPosEventModel>> getNetworkPosEvents({
    required int networkPosId,
    String? cursor,
    int perPage = 20,
  });

  Future<void> restoreNetworkPosLink(int networkPosId);

  Future<PaginatedList<NetworkPosLinkModel>> getTrashedNetworkPosLinks({
    required int entityId,
    required bool isNetwork,
    String? cursor,
    int perPage = 15,
  });

  Future<PaginatedList<NetworkLinkablePosModel>> searchNetworkLinkablePos({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  });

  Future<NetworkLinkablePosModel> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  });

  Future<NetworkPosLinkChallengeModel> createNetworkPosLinkChallenge({
    required int networkId,
    required String posUuid,
    int durationMinutes = 15,
  });

  Future<NetworkPosLinkPreviewModel> previewNetworkPosLinkChallenge({
    required String payload,
    required String posUuid,
  });

  Future<NetworkPosLinkModel> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  });

  Future<NetworkPosLinkChallengeStatusModel> getNetworkPosLinkChallengeStatus(
    String challengeUuid,
  );

  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid);

  Future<NetworkModel> createNetwork(Map<String, dynamic> payload);

  Future<NetworkModel> updateNetwork(int networkId, Map<String, dynamic> payload);

  Future<PosModel> createPos(Map<String, dynamic> payload);

  Future<PosModel> updatePos(int posId, Map<String, dynamic> payload);

  Future<void> deleteNetwork(int networkId);

  Future<void> deletePos(int posId);

  Future<PaginatedList<NetworkModel>> getTrashedNetworks({
    String? search,
    String? cursor,
    int perPage = 15,
  });

  Future<void> restoreNetwork(int networkId);

  Future<PaginatedList<PosModel>> getTrashedPos({
    String? search,
    String? cursor,
    int perPage = 15,
  });

  Future<void> restorePos(int posId);


  Future<NetworkModel> getNetworkDetails(int networkId);

  Future<PosModel> getPosDetails(int posId);
}
