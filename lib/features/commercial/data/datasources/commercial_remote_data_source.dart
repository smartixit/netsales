import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_status_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/data/models/network_linkable_pos_model.dart';

/// العقد التجريدي لمصدر البيانات البعيد للعلاقات التجارية
abstract class CommercialRemoteDataSource {
  Future<List<NetworkModel>> getMyNetworks();

  Future<List<PosModel>> getMyPos();

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

  Future<NetworkLinkablePosModel> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  });

  Future<NetworkPosLinkChallengeModel> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  });

  Future<NetworkPosLinkPreviewModel> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  });

  Future<NetworkPosLinkModel> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  });

  Future<NetworkPosLinkChallengeStatusModel> getNetworkPosLinkChallengeStatus(
    String challengeUuid,
  );

  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid);

  Future<NetworkModel> getNetworkDetails(int networkId);

  Future<PosModel> getPosDetails(int posId);
}
