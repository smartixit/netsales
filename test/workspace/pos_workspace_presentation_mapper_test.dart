import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_active_supply_order_mapper.dart';

void main() {
  RequestEntity request(String? status) => RequestEntity(
    requestId: 41,
    networkId: 3,
    posId: 7,
    requestUuid: 'request-12345678',
    requestTotalAmount: 1250,
    statusRaw: status,
    statusLabel: status == 'PENDING' ? 'قيد الانتظار' : null,
  );

  group('POS workspace active supply order mapper', () {
    test('maps a request only when the API reports PENDING', () {
      final result = PosActiveSupplyOrderMapper.map([
        request('APPROVED'),
        request('PENDING'),
      ]);

      expect(result, isNotNull);
      expect(result!.request.requestId, 41);
      expect(result.reference, 'request-12345678');
      expect(result.statusPresentation.label, 'قيد الانتظار');
      expect(result.formattedAmount, isNotEmpty);
    });

    test('does not infer an unknown or missing status as pending', () {
      expect(PosActiveSupplyOrderMapper.map([request('PROCESSING')]), isNull);
      expect(PosActiveSupplyOrderMapper.map([request(null)]), isNull);
      expect(PosActiveSupplyOrderMapper.map([request('UNKNOWN')]), isNull);
    });

    test('returns no active order when every request is terminal', () {
      expect(
        PosActiveSupplyOrderMapper.map([
          request('APPROVED'),
          request('REJECTED'),
          request('CANCELLED'),
        ]),
        isNull,
      );
    });
  });
}
