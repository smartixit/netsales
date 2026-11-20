import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_active_supply_order_mapper.dart';

void main() {
  group('POS workspace request presentation mapper', () {
    test('maps active request progress using the request lifecycle status', () {
      const request = RequestEntity(
        requestId: 41,
        networkId: 3,
        posId: 7,
        requestUuid: 'request-12345678',
        requestTotalAmount: 1250,
        statusRaw: 'PROCESSING',
        statusLabel: 'قيد المعالجة',
      );

      final result = PosActiveSupplyOrderMapper.map([request]);

      expect(result, isNotNull);
      expect(result!.reference, 'request-');
      expect(result.isReviewComplete, isTrue);
      expect(result.isDeliveryActive, isTrue);
      expect(result.isDeliveryComplete, isFalse);
    });

    test('returns no active order for terminal request statuses', () {
      const request = RequestEntity(
        requestId: 42,
        networkId: 3,
        posId: 7,
        requestTotalAmount: 0,
        statusRaw: 'REJECTED',
      );

      expect(PosActiveSupplyOrderMapper.map([request]), isNull);
    });
  });
}
