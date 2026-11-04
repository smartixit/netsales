import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_pos_details_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';

class MockCommercialRepository implements CommercialRepository {
  final List<NetworkPosLinkEntity> _links = [];

  MockCommercialRepository(List<NetworkPosLinkEntity> initial) {
    _links.addAll(initial);
  }

  @override
  Future<List<NetworkEntity>> getMyNetworks() async {
    return [
      const NetworkEntity(
        networkId: 1,
        ownerId: 10,
        networkName: 'Al-Amal Network',
        networkPhoneNumber: '771111111',
        status: 'ACTIVE',
      ),
    ];
  }

  @override
  Future<List<PosEntity>> getMyPos() async {
    return [
      const PosEntity(
        posId: 1,
        ownerId: 20,
        posUuid: 'POS-2611-00001-A1B2',
        posName: 'Al-Nour POS',
        posPhoneNumber: '772222222',
        status: 'ACTIVE',
      ),
    ];
  }

  @override
  Future<List<NetworkPosLinkEntity>> getNetworkPosList(
    int networkId, {
    Map<String, dynamic>? query,
  }) async {
    return _links.where((l) => l.networkId == networkId).toList();
  }

  @override
  Future<List<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    Map<String, dynamic>? query,
  }) async {
    return _links.where((l) => l.posId == posId).toList();
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) async {
    final link = NetworkPosLinkEntity(
      networkPosId: _links.length + 1,
      networkId: networkId,
      posId: posId ?? 999,
      status: status ?? true,
      pos: PosEntity(
        posId: posId ?? 999,
        ownerId: 50,
        posUuid: posUuid ?? 'POS-TEST-UUID',
        posName: 'Created POS',
        posPhoneNumber: '773333333',
        status: 'ACTIVE',
      ),
    );
    _links.add(link);
    return link;
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int linkId) async {
    final index = _links.indexWhere((l) => l.networkPosId == linkId);
    final current = _links[index];
    final updated = NetworkPosLinkEntity(
      networkPosId: current.networkPosId,
      networkId: current.networkId,
      posId: current.posId,
      status: !current.status,
      network: current.network,
      pos: current.pos,
    );
    _links[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteNetworkPosLink(int linkId) async {
    _links.removeWhere((l) => l.networkPosId == linkId);
  }

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) async {
    return const NetworkEntity(
      networkId: 1,
      ownerId: 10,
      networkName: 'Al-Amal Network',
      networkPhoneNumber: '771111111',
      status: 'ACTIVE',
    );
  }

  @override
  Future<PosEntity> getPosDetails(int posId) async {
    return const PosEntity(
      posId: 1,
      ownerId: 20,
      posUuid: 'POS-2611-00001-A1B2',
      posName: 'Al-Nour POS',
      posPhoneNumber: '772222222',
      status: 'ACTIVE',
    );
  }

  @override
  Future<NetworkEntity> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  ) async {
    return NetworkEntity(
      networkId: networkId,
      ownerId: 10,
      networkName: (data['network_name'] as String?) ?? 'Updated Network',
      networkPhoneNumber: '771111111',
      status: 'ACTIVE',
    );
  }

  @override
  Future<PosEntity> updatePosDetails(
    int posId,
    Map<String, dynamic> data,
  ) async {
    return PosEntity(
      posId: posId,
      ownerId: 20,
      posUuid: 'POS-2611-00001-A1B2',
      posName: (data['pos_name'] as String?) ?? 'Updated POS',
      posPhoneNumber: '772222222',
      status: 'ACTIVE',
    );
  }

  @override
  Future<NetworkPosLinkChallengeEntity> createLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  }) async {
    return NetworkPosLinkChallengeEntity(
      challengeUuid: 'test-challenge-uuid',
      networkId: networkId,
      payloadToken: 'NTS_LINK_V1_MOCK',
      status: LinkingChallengeStatus.pending,
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  }) async {
    return NetworkPosLinkPreviewEntity(
      challengeUuid: 'test-challenge-uuid',
      networkId: 1,
      networkName: 'Al-Amal Network',
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      alreadyLinked: false,
    );
  }

  @override
  Future<NetworkPosLinkEntity> confirmLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) async {
    final link = NetworkPosLinkEntity(
      networkPosId: _links.length + 1,
      networkId: 1,
      posId: posId ?? 1,
      status: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _links.add(link);
    return link;
  }

  @override
  Future<void> revokeLinkChallenge(String uuid) async {}
}

void main() {
  group('Commercial Entities & Data Models Tests', () {
    test('NetworkModel parsing and serialization', () {
      final json = {
        'network_id': 10,
        'owner_id': 5,
        'network_name': 'Sanaa Wholesale Network',
        'network_phone_number': '771234567',
        'network_email': 'network@sanaa.com',
        'status': 'ACTIVE',
        'status_label': 'نشط',
        'owner': {'owner_id': 5, 'user_full_name': 'Ahmed Al-Network'},
      };

      final model = NetworkModel.fromJson(json);

      expect(model.networkId, equals(10));
      expect(model.ownerId, equals(5));
      expect(model.networkName, equals('Sanaa Wholesale Network'));
      expect(model.ownerName, equals('Ahmed Al-Network'));
      expect(model.isActive, isTrue);

      final serialized = model.toJson();
      expect(serialized['network_id'], equals(10));
      expect(serialized['network_name'], equals('Sanaa Wholesale Network'));
    });

    test('PosModel parsing and serialization', () {
      final json = {
        'pos_id': 25,
        'owner_id': 12,
        'pos_uuid': 'POS-2611-00025-C3D4',
        'pos_name': 'Al-Farooq POS Store',
        'pos_phone_number': '777654321',
        'status': 'ACTIVE',
        'status_label': 'نشط',
        'owner': {'owner_id': 12, 'user_full_name': 'Farooq Merchant'},
      };

      final model = PosModel.fromJson(json);

      expect(model.posId, equals(25));
      expect(model.posUuid, equals('POS-2611-00025-C3D4'));
      expect(model.posName, equals('Al-Farooq POS Store'));
      expect(model.ownerName, equals('Farooq Merchant'));
      expect(model.isActive, isTrue);

      final serialized = model.toJson();
      expect(serialized['pos_id'], equals(25));
      expect(serialized['pos_uuid'], equals('POS-2611-00025-C3D4'));
    });

    test('NetworkPosLinkModel parsing with nested relations', () {
      final json = {
        'network_pos_id': 101,
        'network_id': 10,
        'pos_id': 25,
        'status': true,
        'network': {
          'network_id': 10,
          'owner_id': 5,
          'network_name': 'Sanaa Wholesale Network',
          'network_phone_number': '771234567',
          'status': 'ACTIVE',
        },
        'pos': {
          'pos_id': 25,
          'owner_id': 12,
          'pos_uuid': 'POS-2611-00025-C3D4',
          'pos_name': 'Al-Farooq POS Store',
          'pos_phone_number': '777654321',
          'status': 'ACTIVE',
        },
      };

      final model = NetworkPosLinkModel.fromJson(json);

      expect(model.networkPosId, equals(101));
      expect(model.networkId, equals(10));
      expect(model.posId, equals(25));
      expect(model.isActive, isTrue);
      expect(model.network?.networkName, equals('Sanaa Wholesale Network'));
      expect(model.pos?.posName, equals('Al-Farooq POS Store'));
    });
  });

  group('Commercial UseCases and Repository Clean Architecture', () {
    late MockCommercialRepository repository;
    late GetNetworkPosListUseCase getNetworkPosListUseCase;
    late GetPosNetworksListUseCase getPosNetworksListUseCase;
    late CreateNetworkPosLinkUseCase createNetworkPosLinkUseCase;
    late ToggleNetworkPosLinkStatusUseCase toggleNetworkPosLinkStatusUseCase;
    late DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;

    final initialLink = NetworkPosLinkEntity(
      networkPosId: 1,
      networkId: 1,
      posId: 10,
      status: true,
      pos: const PosEntity(
        posId: 10,
        ownerId: 2,
        posUuid: 'POS-0010',
        posName: 'Super POS',
        posPhoneNumber: '771122334',
        status: 'ACTIVE',
      ),
      network: const NetworkEntity(
        networkId: 1,
        ownerId: 1,
        networkName: 'Main Network',
        networkPhoneNumber: '770011223',
        status: 'ACTIVE',
      ),
    );

    setUp(() {
      repository = MockCommercialRepository([initialLink]);
      getNetworkPosListUseCase = GetNetworkPosListUseCase(repository);
      getPosNetworksListUseCase = GetPosNetworksListUseCase(repository);
      createNetworkPosLinkUseCase = CreateNetworkPosLinkUseCase(repository);
      toggleNetworkPosLinkStatusUseCase = ToggleNetworkPosLinkStatusUseCase(
        repository,
      );
      deleteNetworkPosLinkUseCase = DeleteNetworkPosLinkUseCase(repository);
    });

    test(
      'GetNetworkPosListUseCase returns linked POS list for network',
      () async {
        final list = await getNetworkPosListUseCase(1);
        expect(list.length, equals(1));
        expect(list.first.pos?.posName, equals('Super POS'));
      },
    );

    test(
      'GetPosNetworksListUseCase returns linked networks list for POS',
      () async {
        final list = await getPosNetworksListUseCase(10);
        expect(list.length, equals(1));
        expect(list.first.network?.networkName, equals('Main Network'));
      },
    );

    test('CreateNetworkPosLinkUseCase links new POS to network', () async {
      final created = await createNetworkPosLinkUseCase(
        networkId: 1,
        posId: 30,
        posUuid: 'POS-0030',
        status: true,
      );

      expect(created.networkId, equals(1));
      expect(created.posId, equals(30));
      expect(created.isActive, isTrue);

      final list = await getNetworkPosListUseCase(1);
      expect(list.length, equals(2));
    });

    test('ToggleNetworkPosLinkStatusUseCase updates link status', () async {
      final toggled = await toggleNetworkPosLinkStatusUseCase(1);
      expect(toggled.status, isFalse);

      final reToggled = await toggleNetworkPosLinkStatusUseCase(1);
      expect(reToggled.status, isTrue);
    });

    test('DeleteNetworkPosLinkUseCase unlinks POS from network', () async {
      await deleteNetworkPosLinkUseCase(1);
      final list = await getNetworkPosListUseCase(1);
      expect(list, isEmpty);
    });

    test(
      'GetNetworkDetailsUseCase and UpdateNetworkDetailsUseCase manage network details',
      () async {
        final getDetails = GetNetworkDetailsUseCase(repository);
        final updateDetails = UpdateNetworkDetailsUseCase(repository);

        final network = await getDetails(1);
        expect(network.networkName, equals('Al-Amal Network'));

        final updated = await updateDetails(1, {
          'network_name': 'New Hope Network',
        });
        expect(updated.networkName, equals('New Hope Network'));
      },
    );

    test(
      'GetPosDetailsUseCase and UpdatePosDetailsUseCase manage POS details',
      () async {
        final getPos = GetPosDetailsUseCase(repository);
        final updatePos = UpdatePosDetailsUseCase(repository);

        final pos = await getPos(1);
        expect(pos.posName, equals('Al-Nour POS'));

        final updated = await updatePos(1, {'pos_name': 'Al-Nour Super POS'});
        expect(updated.posName, equals('Al-Nour Super POS'));
      },
    );
  });

  group('CommercialDirectoryController Filtering and Logic', () {
    test('Search query and status filtering matches correct records', () {
      final link1 = NetworkPosLinkEntity(
        networkPosId: 1,
        networkId: 1,
        posId: 10,
        status: true,
        pos: const PosEntity(
          posId: 10,
          ownerId: 2,
          posUuid: 'POS-ALPHA-01',
          posName: 'Sanaa Retail Hub',
          posPhoneNumber: '771111111',
          status: 'ACTIVE',
        ),
      );

      final link2 = NetworkPosLinkEntity(
        networkPosId: 2,
        networkId: 1,
        posId: 20,
        status: false,
        pos: const PosEntity(
          posId: 20,
          ownerId: 3,
          posUuid: 'POS-BETA-02',
          posName: 'Aden Branch Outlet',
          posPhoneNumber: '772222222',
          status: 'INACTIVE',
        ),
      );

      final repo = MockCommercialRepository([link1, link2]);
      final controller = CommercialDirectoryController(
        getNetworkPosListUseCase: GetNetworkPosListUseCase(repo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(repo),
        createNetworkPosLinkUseCase: CreateNetworkPosLinkUseCase(repo),
        toggleNetworkPosLinkStatusUseCase: ToggleNetworkPosLinkStatusUseCase(
          repo,
        ),
        deleteNetworkPosLinkUseCase: DeleteNetworkPosLinkUseCase(repo),
        getMyNetworksUseCase: GetMyNetworksUseCase(repo),
        getMyPosUseCase: GetMyPosUseCase(repo),
        getNetworkDetailsUseCase: GetNetworkDetailsUseCase(repo),
        getPosDetailsUseCase: GetPosDetailsUseCase(repo),
        updateNetworkDetailsUseCase: UpdateNetworkDetailsUseCase(repo),
        updatePosDetailsUseCase: UpdatePosDetailsUseCase(repo),
      );

      controller.links.assignAll([link1, link2]);

      // 1. بدون فلترة
      expect(controller.filteredLinks.length, equals(2));

      // 2. فلترة الحالة: نشط
      controller.setStatusFilter(true);
      expect(controller.filteredLinks.length, equals(1));
      expect(
        controller.filteredLinks.first.pos?.posName,
        equals('Sanaa Retail Hub'),
      );

      // 3. فلترة الحالة: معطل
      controller.setStatusFilter(false);
      expect(controller.filteredLinks.length, equals(1));
      expect(
        controller.filteredLinks.first.pos?.posName,
        equals('Aden Branch Outlet'),
      );

      // 4. إعادة الفلتر وبحث نصي
      controller.setStatusFilter(null);
      controller.setSearchQuery('Sanaa');
      expect(controller.filteredLinks.length, equals(1));
      expect(controller.filteredLinks.first.posId, equals(10));

      // 5. بحث بالمعرف الفريد UUID
      controller.setSearchQuery('BETA');
      expect(controller.filteredLinks.length, equals(1));
      expect(controller.filteredLinks.first.posId, equals(20));

      // 6. بحث غير مطابق
      controller.setSearchQuery('XYZNOTFOUND');
      expect(controller.filteredLinks, isEmpty);
    });
  });
}
