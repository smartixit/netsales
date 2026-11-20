import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_active_supply_order_mapper.dart';

void main() {
  RequestEntity request(String? status) => RequestEntity(
    requestId: 9,
    networkId: 3,
    posId: 4,
    requestUuid: 'request-uuid-123',
    requestTotalAmount: 1200,
    statusRaw: status,
    statusLabel: 'بانتظار الاعتماد',
  );

  group('PosActiveSupplyOrderMapper', () {
    test('maps only an API-defined pending request', () {
      final result = PosActiveSupplyOrderMapper.map([
        request('APPROVED'),
        request('PENDING'),
      ]);

      expect(result, isNotNull);
      expect(result!.request.requestId, 9);
      expect(result.reference, 'request-');
      expect(result.statusPresentation.label, 'بانتظار الاعتماد');
      expect(result.formattedAmount, '1,200');
    });

    test('does not infer missing or unknown status as pending', () {
      expect(PosActiveSupplyOrderMapper.map([request(null)]), isNull);
      expect(PosActiveSupplyOrderMapper.map([request('PROCESSING')]), isNull);
    });
  });
}
