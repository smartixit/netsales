import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

class _FakeCommercialRepository implements CommercialRepository {
  _FakeCommercialRepository({this.confirmation});

  final Completer<NetworkPosLinkEntity>? confirmation;
  int confirmCalls = 0;

  @override
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  }) {
    confirmCalls++;
    final pending = confirmation;
    if (pending == null) {
      throw StateError('No confirmation response was configured.');
    }
    return pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceRepository implements InvoiceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequestRepository implements RequestRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PosWorkspaceController _buildController(_FakeCommercialRepository commercial) {
  return PosWorkspaceController(
    getMyPosUseCase: GetMyPosUseCase(commercial),
    getPosNetworksListUseCase: GetPosNetworksListUseCase(commercial),
    getPosInvoicesUseCase: GetPosInvoicesUseCase(_FakeInvoiceRepository()),
    getRequestsUseCase: GetRequestsUseCase(_FakeRequestRepository()),
    previewNetworkPosLinkChallengeUseCase:
        PreviewNetworkPosLinkChallengeUseCase(commercial),
    confirmNetworkPosLinkChallengeUseCase:
        ConfirmNetworkPosLinkChallengeUseCase(commercial),
  );
}

PosEntity _pos(int id) => PosEntity(
  posId: id,
  ownerId: 1,
  posUuid: 'pos-$id',
  posName: 'نقطة البيع $id',
  posPhoneNumber: '770000000',
);

NetworkPosLinkEntity _link({required int posId}) => NetworkPosLinkEntity(
  networkPosId: posId + 1000,
  networkId: 7,
  posId: posId,
  status: true,
);

void main() {
  group('POS workspace relationship context safety', () {
    test('does not select a network relationship owned by another POS', () async {
      final controller = _buildController(_FakeCommercialRepository());
      controller.activePos.value = _pos(20);
      final foreignLink = _link(posId: 10);
      controller.networkLinks.add(foreignLink);

      await controller.selectNetwork(foreignLink);

      expect(controller.selectedNetworkLink.value, isNull);
      expect(controller.recentInvoices, isEmpty);
      expect(controller.recentRequests, isEmpty);
    });

    test('does not apply a successful challenge response after the POS changed', () async {
      final confirmation = Completer<NetworkPosLinkEntity>();
      final repository = _FakeCommercialRepository(
        confirmation: confirmation,
      );
      final controller = _buildController(repository);
      controller.activePos.value = _pos(10);

      final pendingConfirmation = controller.confirmNetworkLinkChallenge(
        challengeUuid: 'challenge-uuid',
        posId: 10,
        posUuid: 'pos-10',
      );

      controller.activePos.value = _pos(20);
      confirmation.complete(_link(posId: 10));

      expect(await pendingConfirmation, isTrue);
      expect(controller.networkLinks, isEmpty);
      expect(controller.selectedNetworkLink.value, isNull);
    });

    test('rejects challenge confirmation when its captured POS is no longer active', () async {
      final repository = _FakeCommercialRepository(
        confirmation: Completer<NetworkPosLinkEntity>(),
      );
      final controller = _buildController(repository);
      controller.activePos.value = _pos(20);

      await expectLater(
        controller.confirmNetworkLinkChallenge(
          challengeUuid: 'challenge-uuid',
          posId: 10,
          posUuid: 'pos-10',
        ),
        throwsA(isA<AppException>()),
      );

      expect(repository.confirmCalls, 0);
    });

    test('rejects a server relationship that belongs to another POS', () async {
      final confirmation = Completer<NetworkPosLinkEntity>();
      final repository = _FakeCommercialRepository(
        confirmation: confirmation,
      );
      final controller = _buildController(repository);
      controller.activePos.value = _pos(10);

      final pendingConfirmation = controller.confirmNetworkLinkChallenge(
        challengeUuid: 'challenge-uuid',
        posId: 10,
        posUuid: 'pos-10',
      );
      confirmation.complete(_link(posId: 20));

      await expectLater(pendingConfirmation, throwsA(isA<AppException>()));
      expect(controller.networkLinks, isEmpty);
      expect(controller.selectedNetworkLink.value, isNull);
    });
  });
}
