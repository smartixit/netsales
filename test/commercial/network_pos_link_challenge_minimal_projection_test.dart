import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';

void main() {
  group('NetworkPosLinkChallengeModel minimal response projection', () {
    test('parses only the network name and linkable POS identity', () {
      final model = NetworkPosLinkChallengeModel.fromJson({
        'challenge_id': 91,
        'challenge_uuid': 'CH-91',
        'payload': 'NTS_LINK_V1_ENCRYPTED',
        'network_id': 7,
        'pos_id': 13,
        'status': 'PENDING',
        'status_label': 'قيد الانتظار',
        'expires_at': '2026-11-22T18:30:00+03:00',
        'network': {
          'network_id': 7,
          'network_name': 'شبكة التوزيع',
        },
        'pos': {
          'pos_id': 13,
          'pos_uuid': 'POS-2611-00013-AB12',
          'pos_name': 'نقطة البيع المركزية',
        },
      });

      expect(model.networkId, 7);
      expect(model.posId, 13);
      expect(model.networkName, 'شبكة التوزيع');
      expect(model.pos?.posId, 13);
      expect(model.pos?.posUuid, 'POS-2611-00013-AB12');
      expect(model.pos?.posName, 'نقطة البيع المركزية');
      expect(model.expiresAt, '2026-11-22T18:30:00+03:00');

      final serialized = model.toJson();
      expect(serialized['network'], {
        'network_id': 7,
        'network_name': 'شبكة التوزيع',
      });
      expect(serialized['pos'], {
        'pos_id': 13,
        'pos_uuid': 'POS-2611-00013-AB12',
        'pos_name': 'نقطة البيع المركزية',
      });
      expect(serialized['network'], isNot(contains('owner_id')));
      expect(serialized['pos'], isNot(contains('pos_phone_number')));
    });
  });
}
