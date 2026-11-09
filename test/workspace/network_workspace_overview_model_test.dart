import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/data/models/network_workspace_overview_model.dart';

void main() {
  group('NetworkWorkspaceOverviewModel', () {
    test('parses the required network identity, period and server metrics', () {
      final model = NetworkWorkspaceOverviewModel.fromJson({
        'generated_at': '2026-11-09T10:00:00+03:00',
        'timezone': 'Asia/Aden',
        'period': {
          'key': '30d',
          'days': 30,
          'from': '2026-10-11T00:00:00+03:00',
          'to': '2026-11-09T10:00:00+03:00',
        },
        'network': {
          'network_id': 12,
          'network_name': 'شبكة الاختبار',
        },
        'metrics': {
          'points_of_sale': {'total': 8, 'active': 6, 'inactive': 2},
          'requests': {'total': 12, 'pending': 3, 'approved': 7, 'rejected': 2, 'cancelled': 0},
          'sales': {
            'invoice_count': 9,
            'total_amount': '15000.00',
            'paid_amount': '9000.00',
            'outstanding_amount': '6000.00',
          },
          'expenses': {'count': 2, 'total_amount': '500.00'},
          'wallet': {'wallet_id': 4, 'balance': '1200.00', 'is_active': true},
          'packages': {'total': 5, 'active': 4, 'inactive': 1},
        },
        'recent_pending_requests': [
          {
            'request_id': 90,
            'request_uuid': 'REQ-90',
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

      expect(model.networkId, 12);
      expect(model.networkName, 'شبكة الاختبار');
      expect(model.periodKey, '30d');
      expect(model.count('points_of_sale', 'active'), '6');
      expect(model.amount('sales', 'outstanding_amount'), '6000.00');
      expect(model.recentPendingRequests.single['request_id'], 90);
    });

    test('preserves an explicitly null wallet when the server has no wallet record', () {
      final model = NetworkWorkspaceOverviewModel.fromJson({
        'generated_at': '2026-11-09T10:00:00+03:00',
        'timezone': 'Asia/Aden',
        'period': {'key': '30d', 'days': 30, 'from': '2026-10-11T00:00:00+03:00', 'to': '2026-11-09T10:00:00+03:00'},
        'network': {'network_id': 12, 'network_name': 'شبكة الاختبار'},
        'metrics': {'wallet': null},
        'recent_pending_requests': <Map<String, dynamic>>[],
      });

      expect(model.metrics.containsKey('wallet'), isTrue);
      expect(model.metrics['wallet'], isNull);
    });

    test('rejects an incomplete top-level overview contract', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson({
          'network': {'network_id': 12, 'network_name': 'شبكة الاختبار'},
          'period': {'key': '30d'},
          'metrics': <String, dynamic>{},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed metric groups instead of silently accepting them', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson({
          'generated_at': '2026-11-09T10:00:00+03:00',
          'period': {'key': '30d'},
          'network': {'network_id': 12, 'network_name': 'شبكة الاختبار'},
          'metrics': <String, dynamic>{'sales': 'not-an-object'},
          'recent_pending_requests': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
