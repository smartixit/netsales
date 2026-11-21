import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/enums/network_status.dart';
import 'package:netsales/core/enums/pos_status.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

void main() {
  group('Commercial Entities & Models Invariant Tests', () {
    test('NetworkEntity formats displayReference and getters accurately', () {
      const entityWithUuid = NetworkEntity(
        networkId: 10,
        ownerId: 1,
        networkUuid: 'NET-2026-UUID-1234',
        networkName: 'شبكة الأمل',
        networkPhoneNumber: '771234567',
        status: 'ACTIVE',
        governorateName: 'صنعاء',
        directorateName: 'السبعين',
        networkAddress: 'شارع حدة',
      );

      expect(entityWithUuid.displayReference, equals('NET-2026-UUID-1234'));
      expect(entityWithUuid.displayName, equals('شبكة الأمل'));
      expect(entityWithUuid.displayPhone, equals('771234567'));
      expect(entityWithUuid.displayLocation, contains('صنعاء'));
      expect(entityWithUuid.typedStatus, equals(NetworkStatus.active));
      expect(entityWithUuid.isActive, isTrue);

      const entityWithoutUuid = NetworkEntity(
        networkId: 5,
        ownerId: 2,
        networkName: 'شبكة النور',
        networkPhoneNumber: '779876543',
        status: 'INACTIVE',
      );

      expect(entityWithoutUuid.displayReference, equals('#5'));
      expect(entityWithoutUuid.isActive, isFalse);
    });

    test('PosEntity preserves raw UUID without truncation', () {
      const pos = PosEntity(
        posId: 25,
        ownerId: 3,
        posUuid: 'POS-2026-LONG-SOVEREIGN-UUID-98765',
        posName: 'نقطة بيع النصر',
        posPhoneNumber: '773333333',
        status: 'ACTIVE',
      );

      expect(
        pos.displayReference,
        equals('POS-2026-LONG-SOVEREIGN-UUID-98765'),
      );
      expect(pos.displayName, equals('نقطة بيع النصر'));
      expect(pos.typedStatus, equals(PosStatus.active));
      expect(pos.isActive, isTrue);
    });

    test('NetworkPosLinkEntity resolves both partner names and getters', () {
      const link = NetworkPosLinkEntity(
        networkPosId: 100,
        networkId: 1,
        posId: 2,
        status: true,
        createdAt: '2026-05-15T10:00:00Z',
        network: NetworkEntity(
          networkId: 1,
          ownerId: 10,
          networkUuid: 'NET-UUID-01',
          networkName: 'شبكة الجنوب',
          networkPhoneNumber: '771111111',
        ),
        pos: PosEntity(
          posId: 2,
          ownerId: 20,
          posUuid: 'POS-UUID-02',
          posName: 'مركز المدينة',
          posPhoneNumber: '772222222',
        ),
      );

      expect(link.isActive, isTrue);
      expect(link.displayNetworkName, equals('شبكة الجنوب'));
      expect(link.displayNetworkReference, equals('NET-UUID-01'));
      expect(link.displayPosName, equals('مركز المدينة'));
      expect(link.displayPosReference, equals('POS-UUID-02'));
      expect(link.networkPhone, equals('771111111'));
      expect(link.posPhone, equals('772222222'));
      expect(link.formattedLinkedDate, isNotEmpty);
    });

    test('NetworkPosLinkChallengeEntity parses statuses correctly', () {
      const pendingChallenge = NetworkPosLinkChallengeEntity(
        challengeId: 1,
        challengeUuid: 'CHALLENGE-UUID-001',
        payload: 'NETSALES:LINK:001',
        networkId: 1,
        posId: 2,
        status: 'PENDING',
      );

      expect(pendingChallenge.isPending, isTrue);
      expect(pendingChallenge.isConsumed, isFalse);
      expect(pendingChallenge.isRevoked, isFalse);
      expect(pendingChallenge.typedStatus, equals(LinkingChallengeStatus.pending));
    });

    test('NetworkModel fromJson and toJson serialization', () {
      final json = {
        'network_id': 10,
        'owner_id': 1,
        'network_uuid': 'NET-UUID-10',
        'network_name': 'شبكة الرواد',
        'network_phone_number': '770000000',
        'status': 'ACTIVE',
        'status_label': 'نشط',
        'created_at': '2026-01-01',
      };

      final model = NetworkModel.fromJson(json);
      expect(model.networkId, equals(10));
      expect(model.networkUuid, equals('NET-UUID-10'));
      expect(model.networkName, equals('شبكة الرواد'));

      final backToJson = model.toJson();
      expect(backToJson['network_id'], equals(10));
      expect(backToJson['network_uuid'], equals('NET-UUID-10'));
    });

    test('PosModel fromJson and toJson serialization', () {
      final json = {
        'pos_id': 20,
        'owner_id': 2,
        'pos_uuid': 'POS-UUID-20',
        'pos_name': 'نقطة المجد',
        'pos_phone_number': '778888888',
        'status': 'ACTIVE',
        'status_label': 'نشط',
      };

      final model = PosModel.fromJson(json);
      expect(model.posId, equals(20));
      expect(model.posUuid, equals('POS-UUID-20'));
      expect(model.posName, equals('نقطة المجد'));

      final backToJson = model.toJson();
      expect(backToJson['pos_id'], equals(20));
      expect(backToJson['pos_uuid'], equals('POS-UUID-20'));
    });

    test('PaginatedList handles items and cursors accurately', () {
      final page = PaginatedList<NetworkPosLinkEntity>(
        items: const [
          NetworkPosLinkEntity(
            networkPosId: 1,
            networkId: 10,
            posId: 20,
            status: true,
          ),
        ],
        nextCursor: 'cursor-abc',
        prevCursor: null,
      );

      expect(page.hasMore, isTrue);
      expect(page.length, equals(1));
      expect(page.nextCursor, equals('cursor-abc'));
    });
  });
}
