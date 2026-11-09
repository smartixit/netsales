import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/data/models/network_workspace_overview_model.dart';

Map<String, dynamic> _validOverview({
  bool includeTimezone = true,
  bool includePeriodRange = true,
  bool includeRequestDate = true,
  bool includeRequestTotalAmount = true,
  Map<String, dynamic>? metrics,
}) {
  final period = <String, dynamic>{
    'key': '30d',
    'days': 30,
  };
  if (includePeriodRange) {
    period['from'] = '2026-10-11T00:00:00+03:00';
    period['to'] = '2026-11-09T10:00:00+03:00';
  }

  final request = <String, dynamic>{
    'request_id': 90,
    'request_uuid': 'REQ-90',
    'pos_id': 7,
    'pos_name': 'نقطة الاختبار',
    'sale_type': 'CREDIT',
    'sale_type_label': 'آجل',
    'status': 'PENDING',
    'status_label': 'قيد الانتظار',
  };
  if (includeRequestDate) {
    request['request_date'] = '2026-11-08T09:00:00+03:00';
  }
  if (includeRequestTotalAmount) {
    request['request_total_amount'] = '900.00';
  }

  final response = <String, dynamic>{
    'generated_at': '2026-11-09T10:00:00+03:00',
    'period': period,
    'network': {
      'network_id': 12,
      'network_name': 'شبكة الاختبار',
    },
    'metrics': metrics ??
        {
          'points_of_sale': {'total': 8, 'active': 6, 'inactive': 2},
          'requests': {
            'total': 12,
            'pending': 3,
            'approved': 7,
            'rejected': 2,
            'cancelled': 0,
          },
          'sales': {
            'invoice_count': 9,
            'total_amount': '15000.00',
            'paid_amount': '9000.00',
            'outstanding_amount': '6000.00',
          },
          'expenses': {'count': 2, 'total_amount': '500.00'},
          'wallet': {
            'wallet_id': 4,
            'balance': '1200.00',
            'is_active': true,
          },
          'packages': {'total': 5, 'active': 4, 'inactive': 1},
        },
    'recent_pending_requests': [request],
  };

  if (includeTimezone) {
    response['timezone'] = 'Asia/Aden';
  }
  return response;
}

void main() {
  group('NetworkWorkspaceOverviewModel', () {
    test('parses the complete server contract and operational metrics', () {
      final model =
          NetworkWorkspaceOverviewModel.fromJson(_validOverview());

      expect(model.networkId, 12);
      expect(model.networkName, 'شبكة الاختبار');
      expect(model.periodKey, '30d');
      expect(model.count('points_of_sale', 'active'), '6');
      expect(model.amount('sales', 'outstanding_amount'), '6000.00');
      expect(model.recentPendingRequests.single['request_id'], 90);
      expect(
        model.recentPendingRequests.single['request_total_amount'],
        '900.00',
      );
    });

    test('preserves an explicitly null wallet from the server', () {
      final model = NetworkWorkspaceOverviewModel.fromJson(
        _validOverview(metrics: {'wallet': null}),
      );

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

    test('rejects a response that omits the server timezone', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson(
          _validOverview(includeTimezone: false),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a response that omits the server period range', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson(
          _validOverview(includePeriodRange: false),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects recent requests without the date required by the dashboard',
        () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson(
          _validOverview(includeRequestDate: false),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'rejects recent requests without the amount required by the dashboard',
        () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson(
          _validOverview(includeRequestTotalAmount: false),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed metric groups instead of coercing them', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson(
          _validOverview(metrics: {'sales': 'not-an-object'}),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed pending request entries', () {
      expect(
        () => NetworkWorkspaceOverviewModel.fromJson({
          ..._validOverview(),
          'recent_pending_requests': ['not-an-object'],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
