import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/data/models/network_workspace_overview_model.dart';

void main() {
  group('NetworkWorkspaceOverviewModel', () {
    test('parses a scoped overview and preserves nullable wallet state', () {
      final model = NetworkWorkspaceOverviewModel.fromJson({
        'generated_at': '2026-11-09T10:00:00+03:00',
        'timezone': 'Asia/Aden',
        'period': {'key': '30d', 'days': 30},
        'network': {'network_id': 17, 'network_name': 'شبكة الاختبار'},
        'metrics': {
          'points_of_sale': {'total': 4, 'active': 3, 'inactive': 1},
          'requests': {'total': 8, 'pending': 2},
          'wallet': null,
        },
        'recent_pending_requests': [
          {
            'request_id': 51,
            'request_uuid': 'REQ-51',
            'pos_id': 7,
            'pos_name': 'نقطة الاختبار',
            'sale_type': 'CREDIT',
            'sale_type_label': 'آجل',
            'request_date': '2026-11-08T09:00:00+03:00',
            'status': 'PENDING',
            'status_label': 'قيد الانتظار',
          },
        ],
      });

      expect(model.networkId, 17);
      expect(model.networkName, 'شبكة الاختبار');
      expect(model.periodKey, '30d');
      expect(model.count('points_of_sale', 'total'), '4');
      expect(model.count('requests', 'pending'), '2');
      expect(model.metrics.containsKey('wallet'), isTrue);
      expect(model.metrics['wallet'], isNull);
      expect(model.recentPendingRequests.single['request_id'], 51);
    });

    test('rejects incomplete network overview contracts', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson({
          'generated_at': '2026-11-09T10:00:00+03:00',
          'period': {'key': '30d'},
          'network': {'network_id': 17, 'network_name': 'شبكة الاختبار'},
          'metrics': <String, dynamic>{},
          'recent_pending_requests': <Map<String, dynamic>>[],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed metric groups instead of coercing them', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson({
          'generated_at': '2026-11-09T10:00:00+03:00',
          'period': {'key': '30d'},
          'network': {'network_id': 17, 'network_name': 'شبكة الاختبار'},
          'metrics': {'sales': 'not-an-object'},
          'recent_pending_requests': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
