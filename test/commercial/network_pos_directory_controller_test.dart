import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_link_challenge_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/search_network_linkable_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_commercial_directory_controller.dart';

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
  Future<NetworkLinkablePosEntity> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  }) async {
    return const NetworkLinkablePosEntity(
      posId: 30,
      posUuid: 'POS-2611-00030-A1B2',
      posName: 'نقطة الاختبار',
    );
  }

  @override
  Future<PaginatedList<NetworkLinkablePosEntity>> searchNetworkLinkablePos({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  }) async {
    final candidates = [
      const NetworkLinkablePosEntity(
        posId: 30,
        posUuid: 'POS-2611-00030-A1B2',
        posName: 'نقطة الاختبار',
      ),
    ].where((item) =>
        item.posName.contains(search) || item.posUuid.contains(search));

    return PaginatedList<NetworkLinkablePosEntity>(
      items: candidates.toList(),
      nextCursor: null,
    );
  }

  @override
  Future<List<PosEntity>> getMyPos() async => const [
    PosEntity(
      posId: 10,
      ownerId: 2,
      posUuid: 'POS-10',
      posName: 'نقطة الأمل',
      posPhoneNumber: '772222222',
    ),
  ];

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
      filtered = filtered.where(
        (l) =>
            l.displayPosName.contains(search) ||
            l.displayPosReference.contains(search),
      );
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
  }) async {
    var filtered = links.where((l) => l.posId == posId);
    if (status != null) {
      filtered = filtered.where((l) => l.isActive == status);
    }
    return PaginatedList<NetworkPosLinkEntity>(
      items: filtered.toList(),
      nextCursor: null,
    );
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(
    int networkPosId,
  ) async {
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
    required String posUuid,
    int durationMinutes = 15,
  }) async {
    return const NetworkPosLinkChallengeEntity(
      challengeId: 1,
      challengeUuid: 'CH-123',
      payload: 'PAYLOAD-123',
      networkId: 1,
      posId: 30,
      networkName: 'الشبكة المركزية',
    );
  }

  @override
  Future<NetworkPosLinkChallengeStatusEntity> getNetworkPosLinkChallengeStatus(
    String challengeUuid,
  ) async {
    return NetworkPosLinkChallengeStatusEntity(
      status: LinkingChallengeStatus.pending,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    required String posUuid,
  }) async {
    return const NetworkPosLinkPreviewEntity(
      challengeUuid: 'CH-123',
      network: NetworkEntity(
        networkId: 1,
        ownerId: 10,
        networkName: 'الشبكة المركزية',
        networkPhoneNumber: '771111111',
      ),
    );
  }

  @override
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  }) async {
    return const NetworkPosLinkEntity(
      networkPosId: 99,
      networkId: 1,
      posId: 10,
      status: true,
    );
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

  group('NetworkCommercialDirectoryController Tests', () {
    late _FakeCommercialRepository repo;
    late NetworkCommercialDirectoryController controller;

    setUp(() {
      Get.testMode = true;
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
            posName: 'نقطة الشروق',
            posPhoneNumber: '773333333',
          ),
        ),
      ];

      repo = _FakeCommercialRepository(sampleLinks);

      controller = NetworkCommercialDirectoryController(
        getNetworkPosListUseCase: GetNetworkPosListUseCase(repo),
        toggleNetworkPosLinkStatusUseCase: ToggleNetworkPosLinkStatusUseCase(
          repo,
        ),
        deleteNetworkPosLinkUseCase: DeleteNetworkPosLinkUseCase(repo),
        createNetworkPosLinkChallengeUseCase:
            CreateNetworkPosLinkChallengeUseCase(repo),
        revokeNetworkPosLinkChallengeUseCase:
            RevokeNetworkPosLinkChallengeUseCase(repo),
        getMyNetworksUseCase: GetMyNetworksUseCase(repo),
        getNetworkPosLinkChallengeStatusUseCase:
            GetNetworkPosLinkChallengeStatusUseCase(repo),
        searchNetworkLinkablePosUseCase:
            SearchNetworkLinkablePosUseCase(repo),
      );
    });

    test('Searches eligible invitation targets and blocks selection outside the dialog', () async {
      await controller.loadInitialData();

      controller.onInvitationBusinessCodeChanged('نقطة الاختبار');
      await controller.loadInvitationTargets();

      expect(controller.invitationTargets, hasLength(1));
      expect(controller.invitationTargets.single.posName, 'نقطة الاختبار');

      // Selection is intentionally accepted only while the target dialog is open.
      controller.selectInvitationTarget(controller.invitationTargets.single);
      expect(controller.resolvedInvitationTarget.value, isNull);
    });

    test('Network actions require their dedicated link permissions', () {
      PermissionService.instance.updateAccess(
        roleKey: 'NETWORK_OWNER',
        permissions: [AppPermissions.networksEdit],
      );

      expect(controller.canCreateInvitation, isFalse);
      expect(controller.canTogglePartnerLink, isFalse);
      expect(controller.canDeletePartnerLink, isFalse);

      controller.onToggleStatus(controller.links.first);
      controller.onDeleteLink(controller.links.first);
      expect(repo.links, hasLength(2));

      PermissionService.instance.updateAccess(
        roleKey: 'NETWORK_OWNER',
        permissions: [
          AppPermissions.networkCreateLinkChallenge,
          AppPermissions.networkTogglePosLink,
          AppPermissions.networkDeletePosLink,
        ],
      );

      expect(controller.canCreateInvitation, isTrue);
      expect(controller.canTogglePartnerLink, isTrue);
      expect(controller.canDeletePartnerLink, isTrue);
    });

    test('Loads initial networks and links successfully', () async {
      await controller.loadInitialData();

      expect(controller.authorizedNetworks.length, equals(1));
      expect(controller.selectedNetworkId.value, equals(1));
      expect(controller.links.length, equals(2));
      expect(controller.isLoading.value, isFalse);
    });

    test('Filters links by status correctly', () async {
      await controller.loadInitialData();

      controller.setStatusFilter('1');
      await controller.loadLinks();
      expect(controller.links.length, equals(1));
      expect(controller.links.first.posId, equals(10));

      controller.setStatusFilter('0');
      await controller.loadLinks();
      expect(controller.links.length, equals(1));
      expect(controller.links.first.posId, equals(20));
    });

    test('Searches links by partner name', () async {
      await controller.loadInitialData();

      controller.searchQuery.value = 'الشروق';
      await controller.loadLinks();
      expect(controller.links.length, equals(1));
      expect(controller.links.first.posId, equals(20));
    });

    test('Toggles partner status locally and updates entity', () async {
      await controller.loadInitialData();
      final link = controller.links.first;

      final updated = await controller.toggleNetworkPosLinkStatusUseCase(
        link.networkPosId,
      );
      expect(updated.isActive, isFalse);
    });

    test('Deletes partner link and removes from list', () async {
      await controller.loadInitialData();
      final link = controller.links.first;

      await controller.deleteNetworkPosLinkUseCase(link.networkPosId);
      controller.links.removeWhere(
        (element) => element.networkPosId == link.networkPosId,
      );
      expect(controller.links.length, equals(1));
    });

    test('onPartnerCardTap delegates to openPosWalletStatement', () async {
      await controller.loadInitialData();
      final link = controller.links.first;

      // Ensure calling onPartnerCardTap does not throw
      expect(() => controller.onPartnerCardTap(link), returnsNormally);
    });
  });

  group('PosCommercialDirectoryController Tests', () {
    late _FakeCommercialRepository repo;
    late PosCommercialDirectoryController controller;

    setUp(() {
      Get.testMode = true;
      final sampleLinks = [
        const NetworkPosLinkEntity(
          networkPosId: 1,
          networkId: 1,
          posId: 10,
          status: true,
          network: NetworkEntity(
            networkId: 1,
            ownerId: 10,
            networkName: 'الشبكة المركزية',
            networkPhoneNumber: '771111111',
          ),
        ),
      ];

      repo = _FakeCommercialRepository(sampleLinks);

      controller = PosCommercialDirectoryController(
        getPosNetworksListUseCase: GetPosNetworksListUseCase(repo),
        previewNetworkPosLinkChallengeUseCase:
            PreviewNetworkPosLinkChallengeUseCase(repo),
        confirmNetworkPosLinkChallengeUseCase:
            ConfirmNetworkPosLinkChallengeUseCase(repo),
        getMyPosUseCase: GetMyPosUseCase(repo),
      );
    });

    test('POS linking requires preview and confirmation permissions', () {
      PermissionService.instance.updateAccess(
        roleKey: 'POS_AGENT',
        permissions: [AppPermissions.posEdit],
      );
      expect(controller.canLinkNetwork, isFalse);

      PermissionService.instance.updateAccess(
        roleKey: 'POS_AGENT',
        permissions: [AppPermissions.posPreviewLinkChallenge],
      );
      expect(controller.canLinkNetwork, isFalse);

      PermissionService.instance.updateAccess(
        roleKey: 'POS_AGENT',
        permissions: [
          AppPermissions.posPreviewLinkChallenge,
          AppPermissions.posConfirmLinkChallenge,
        ],
      );
      expect(controller.canLinkNetwork, isTrue);
    });

    test('Loads POS networks and handles links count', () async {
      await controller.loadInitialData();

      expect(controller.authorizedPosList.length, equals(1));
      expect(controller.selectedPosId.value, equals(10));
      expect(controller.links.length, equals(1));
      expect(controller.isLoading.value, isFalse);
    });
  });
}
