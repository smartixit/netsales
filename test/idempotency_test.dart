import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';

void main() {
  group('IdempotencyHelper Tests', () {
    test('generate returns expected format and domain prefixes', () {
      final defaultKey = IdempotencyHelper.generate();
      expect(defaultKey.startsWith('req-'), isTrue);

      final saleKey = IdempotencyHelper.forSaleInvoice(15);
      expect(saleKey.startsWith('sale-pos15-'), isTrue);

      final walletKey = IdempotencyHelper.forWalletTransaction('recharge');
      expect(walletKey.startsWith('wallet-recharge-'), isTrue);

      final voucherKey = IdempotencyHelper.forVoucherRequest(3);
      expect(voucherKey.startsWith('vouch-net3-'), isTrue);

      final subKey = IdempotencyHelper.forSubscription(101);
      expect(subKey.startsWith('sub-plan101-'), isTrue);

      final expKey = IdempotencyHelper.forExpense(5);
      expect(expKey.startsWith('exp-cat5-'), isTrue);

      final batchKey = IdempotencyHelper.forBatchOperation('delete');
      expect(batchKey.startsWith('batch-delete-'), isTrue);
    });

    test('generates collision-resistant unique keys in batch', () {
      final keys = <String>{};
      const count = 1000;

      for (var i = 0; i < count; i++) {
        keys.add(IdempotencyHelper.generate('test'));
      }

      expect(keys.length, equals(count));
    });
  });

  group('ApiResponse Idempotency Metadata Tests', () {
    test('parses isIdempotentHit and idempotencyKey correctly', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        {
          'success': true,
          'message': 'تم تنفيذ العملية',
          'data': {'id': 99},
        },
        (json) => json as Map<String, dynamic>,
        isIdempotentHit: true,
        idempotencyKey: 'sale-pos1-123456-abc',
      );

      expect(response.success, isTrue);
      expect(response.isIdempotentHit, isTrue);
      expect(response.idempotencyKey, equals('sale-pos1-123456-abc'));
      expect(response.data?['id'], equals(99));
    });

    test('default isIdempotentHit is false and idempotencyKey is null', () {
      final response = ApiResponse<void>.fromSimpleJson({
        'success': true,
        'message': 'OK',
      });

      expect(response.isIdempotentHit, isFalse);
      expect(response.idempotencyKey, isNull);
    });
  });
}
