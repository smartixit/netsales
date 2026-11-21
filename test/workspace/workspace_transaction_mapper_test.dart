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
        saleTypeLabel: 'آجل',
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
      expect(items.single.title, 'طلب توريد');
      expect(items.single.reference, '#41');
      expect(items.single.subtitle, contains('آجل'));
      expect(items.single.formattedAmount, isEmpty);
      expect(items.single.icon, isNotNull);
      expect(items.single.onAction, isNull);
      expect(items.single.statusPresentation.label, 'بانتظار الاعتماد');
      expect(items.single.statusPresentation.isKnown, isTrue);

      items.single.onTap?.call();
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
        saleTypeRaw: 'CREDIT',
        saleTypeLabel: 'آجل',
        invoiceTotalAmount: 2500,
        paymentStatusRaw: 'PAID',
        paymentStatusLabel: 'مسدد بالكامل',
        invoiceDate: '2026-11-15',
      );
      final request = RequestEntity(
        requestId: 41,
        networkId: 3,
        posId: 7,
        requestUuid: 'request-12345678',
        saleTypeRaw: 'CASH',
        saleTypeLabel: 'نقدي',
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
      expect(items[0].subtitle, contains('نقدي'));
      expect(items[1].title, 'فاتورة توريد');
      expect(items[1].reference, 'invoice-');
      expect(items[1].subtitle, contains('آجل'));
      expect(items[1].statusPresentation.label, 'مسدد بالكامل');
      expect(items[1].statusPresentation.isKnown, isTrue);

      items[1].onTap?.call();
      items[0].onTap?.call();

      expect(openedInvoices, [11]);
      expect(openedRequests, [41]);
    });

    test('uses the centralized unknown invoice status fallback', () {
      final invoice = InvoiceEntity(
        invoiceId: 12,
        networkId: 3,
        posId: 7,
        invoiceTotalAmount: 900,
        paymentStatusRaw: 'FUTURE_STATUS',
      );

      final items = PosWorkspaceTransactionMapper.map(
        invoices: [invoice],
        requests: const [],
        onOpenInvoice: (_) {},
        onOpenRequest: (_) {},
      );

      expect(items, hasLength(1));
      expect(items.single.statusPresentation.isKnown, isFalse);
      expect(items.single.statusPresentation.label, 'حالة غير معروفة');
    });

    test('uses centralized sale type fallback when server label is absent', () {
      final request = RequestEntity(
        requestId: 42,
        networkId: 3,
        posId: 7,
        requestTotalAmount: 300,
        saleTypeRaw: 'CASH',
        statusRaw: 'PENDING',
      );

      final items = PosWorkspaceTransactionMapper.map(
        invoices: const [],
        requests: [request],
        onOpenInvoice: (_) {},
        onOpenRequest: (_) {},
      );

      expect(items.single.subtitle, 'نقدي');
    });
  });
}
