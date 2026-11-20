import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_directory_controller.dart';

class _FakeCommercialRepository implements CommercialRepository {
  final List<NetworkPosLinkEntity> links;

  _FakeCommercialRepository(this.links);

  @override
  Future<List<NetworkEntity>> getMyNetworks() async {
    return const [
      NetworkEntity(
        networkId: 1,
        ownerId: 10,
        networkName: 'الشبكة المركزية',
        networkPhoneNumber: '771111111',
      ),
    ];
  }

  @override
  Future<List<PosEntity>> getMyPos() async => const [];

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    var filtered = links.where((l) => l.networkId == networkId);
    if (status != null) {
      filtered = filtered.where((l) => l.isActive == status);
    }
    if (search != null && search.trim().isNotEmpty) {
      filtered = filtered.where((l) =>
          l.displayPosName.contains(search) ||
          l.displayPosReference.contains(search));
    }
    return PaginatedList<NetworkPosLinkEntity>(
      items: filtered.toList(),
      nextCursor: null,
    );
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async =>
      const PaginatedList(items: []);

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(
      int networkPosId) async {
    final index = links.indexWhere((l) => l.networkPosId == networkPosId);
    final current = links[index];
    final updated = current.copyWith(status: !current.status);
    links[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteNetworkPosLink(int networkPosId) async {
    links.removeWhere((l) => l.networkPosId == networkPosId);
  }

  @override
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  }) async {
    return const NetworkPosLinkChallengeEntity(
      challengeId: 1,
      challengeUuid: 'CH-123',
      payload: 'PAYLOAD-123',
      networkId: 1,
    );
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid) async {}

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) async {
    throw UnimplementedError();
  }

  @override
  Future<PosEntity> getPosDetails(int posId) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkPosDirectoryController Tests', () {
    late _FakeCommercialRepository repo;
    late NetworkPosDirectoryController controller;

    setUp(() {
      final sampleLinks = [
        const NetworkPosLinkEntity(
          networkPosId: 1,
          networkId: 1,
          posId: 10,
          status: true,
          pos: PosEntity(
            posId: 10,
            ownerId: 2,
            posUuid: 'POS-UUID-10',
            posName: 'نقطة الأمل',
            posPhoneNumber: '772222222',
          ),
        ),
        const NetworkPosLinkEntity(
          networkPosId: 2,
          networkId: 1,
          posId: 20,
          status: false,
          pos: PosEntity(
            posId: 20,
            ownerId: 3,
            posUuid: 'POS-UUID-20',
            posName: 'نقطة السلام',
            posPhoneNumber: '773333333',
          ),
        ),
      ];

      repo = _FakeCommercialRepository(sampleLinks);

      controller = NetworkPosDirectoryController(
        getNetworkPosListUseCase: GetNetworkPosListUseCase(repo),
        toggleNetworkPosLinkStatusUseCase:
            ToggleNetworkPosLinkStatusUseCase(repo),
        deleteNetworkPosLinkUseCase: DeleteNetworkPosLinkUseCase(repo),
        createNetworkPosLinkChallengeUseCase:
            CreateNetworkPosLinkChallengeUseCase(repo),
        revokeNetworkPosLinkChallengeUseCase:
            RevokeNetworkPosLinkChallengeUseCase(repo),
        getMyNetworksUseCase: GetMyNetworksUseCase(repo),
      );
    });

    tearDown(() {
      controller.onClose();
    });

    test('Loads initial networks and links on initialization', () async {
      await controller.loadInitialData();

      expect(controller.authorizedNetworks.length, equals(1));
      expect(controller.selectedNetworkId.value, equals(1));
      expect(controller.links.length, equals(2));
      expect(controller.totalCount, equals(2));
      expect(controller.activeCount, equals(1));
      expect(controller.inactiveCount, equals(1));
      expect(controller.isLoading.value, isFalse);
    });

    test('Filters by active / inactive status correctly', () async {
      await controller.loadInitialData();

      controller.setStatusFilter(true);
      await controller.loadLinks(isRefresh: true);
      expect(controller.links.length, equals(1));
      expect(controller.links.first.isActive, isTrue);

      controller.setStatusFilter(false);
      await controller.loadLinks(isRefresh: true);
      expect(controller.links.length, equals(1));
      expect(controller.links.first.isActive, isFalse);

      controller.resetFilters();
      await controller.loadLinks(isRefresh: true);
      expect(controller.links.length, equals(2));
    });

    test('Toggles accordion expansion exclusively', () {
      controller.toggleAccordion(1);
      expect(controller.expandedLinkId.value, equals(1));

      controller.toggleAccordion(2);
      expect(controller.expandedLinkId.value, equals(2));

      controller.toggleAccordion(2);
      expect(controller.expandedLinkId.value, isNull);
    });

    test('Deletes partner link from local list', () async {
      await controller.loadInitialData();
      expect(controller.links.length, equals(2));

      await controller.deleteLink(controller.links.first);
      expect(controller.links.length, equals(1));
      expect(controller.links.first.networkPosId, equals(2));
    });
  });
}
