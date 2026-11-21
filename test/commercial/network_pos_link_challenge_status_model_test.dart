import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_status_model.dart';

void main() {
  group('NetworkPosLinkChallengeStatusModel', () {
    test('parses a pending challenge and timezone-aware expiry', () {
      final model = NetworkPosLinkChallengeStatusModel.fromJson({
        'status': 'PENDING',
        'status_label': 'بانتظار المسح',
        'expires_at': '2026-11-21T18:30:00+03:00',
      });

      expect(model.status, LinkingChallengeStatus.pending);
      expect(model.statusLabel, 'بانتظار المسح');
      expect(model.expiresAt, isNotNull);
      expect(model.expiresAt!.isUtc, isTrue);
      expect(model.expiresAt, DateTime.utc(2026, 11, 21, 15, 30));
    });

    test('parses terminal challenge states without secret fields', () {
      final states = <String, LinkingChallengeStatus>{
        'CONSUMED': LinkingChallengeStatus.consumed,
        'EXPIRED': LinkingChallengeStatus.expired,
        'REVOKED': LinkingChallengeStatus.revoked,
      };

      for (final entry in states.entries) {
        final model = NetworkPosLinkChallengeStatusModel.fromJson({
          'status': entry.key,
        });
        expect(model.status, entry.value);
        expect(model.expiresAt, isNull);
      }
    });

    test('fails closed for an unknown server status', () {
      final model = NetworkPosLinkChallengeStatusModel.fromJson({
        'status': 'UNRECOGNIZED',
      });

      expect(model.status, LinkingChallengeStatus.unknown);
      expect(model.isActiveAt(DateTime.utc(2026, 11, 21, 15, 30)), isFalse);
    });
  });
}
