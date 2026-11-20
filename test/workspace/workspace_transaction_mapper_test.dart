import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_pending_request_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_transaction_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_workspace_transaction_mapper.dart';

void main() {
  group('NetworkWorkspaceTransactionMapper', () {
    test('maps pending requests and delegates both actions to the caller', () {
      var openedRequestId = 0;
      final request = NetworkPendingRequestEntity(
        requestId: 41,
        requestUuid: 'request-uuid-part-rest',
        posId: 7,
        posName: 'نقطة صنعاء',
        requestDate: '2026-11-16',
        requestTotalAmount: '1250.00',
        statusRaw: 'PENDING',
        statusLabel: 'بانتظار الاعتماد',
      );

      final items = NetworkWorkspaceTransactionMapper.mapPendingRequests(
        [request],
        onOpenRequest: (requestId) => openedRequestId = requestId,
      );

      expect(items, hasLength(1));
      expect(items.single.title, 'نقطة صنعاء');
      expect(items.single.reference, 'request');
      expect(items.single.subtitle, isNotEmpty);
      expect(items.single.formattedAmount, contains('1,250'));
      expect(items.single.actionLabel, 'اعتماد');

      items.single.onTap?.call();
      expect(openedRequestId, 41);

      openedRequestId = 0;
      items.single.onAction?.call();
      expect(openedRequestId, 41);
    });
  });

  group('PosWorkspaceTransactionMapper', () {
    test('merges invoices and requests in global date order', () {
      final openedInvoices = <int>[];
      final openedRequests = <int>[];
      final invoice = InvoiceEntity(
        invoiceId: 11,
        networkId: 3,
        posId: 7,
        invoiceUuid: 'invoice-12345678',
        invoiceTotalAmount: 2500,
        invoiceDate: '2026-11-15',
      );
      final request = RequestEntity(
        requestId: 41,
        networkId: 3,
        posId: 7,
        requestUuid: 'request-12345678',
        requestTotalAmount: 1250,
        statusRaw: 'PENDING',
        statusLabel: 'قيد الانتظار',
        requestDate: '2026-11-16',
      );

      final items = PosWorkspaceTransactionMapper.map(
        invoices: [invoice],
        requests: [request],
        onOpenInvoice: (value) => openedInvoices.add(value.invoiceId),
        onOpenRequest: (value) => openedRequests.add(value.requestId),
      );

      expect(items, hasLength(2));
      expect(items[0].title, 'طلب توريد');
      expect(items[0].reference, 'request-');
      expect(items[1].title, 'فاتورة توريد');
      expect(items[1].reference, 'invoice-');
      expect(items[1].statusPresentation.label, 'فاتورة');

      items[1].onTap?.call();
      items[0].onTap?.call();

      expect(openedInvoices, [11]);
      expect(openedRequests, [41]);
    });
  });
}
