import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';

class _RecordingInvoiceRemoteDataSource implements InvoiceRemoteDataSource {
  int? submittedNetworkId;
  int? submittedPosId;
  SaleType? submittedSaleType;
  List<DirectInvoiceItemInputEntity>? submittedItems;
  String? submittedIdempotencyKey;
  bool failCreation = false;

  @override
  Future<InvoiceModel> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) async {
    submittedNetworkId = networkId;
    submittedPosId = posId;
    submittedSaleType = saleType;
    submittedItems = items;
    submittedIdempotencyKey = idempotencyKey;

    if (failCreation) {
      throw Exception('رفض الخادم إنشاء الفاتورة.');
    }

    return const InvoiceModel(
      invoiceId: 501,
      networkId: 10,
      posId: 20,
      invoiceTotalAmount: 0,
    );
  }

  @override
  Future<PaginatedList<InvoiceModel>> getInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? paymentStatus,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) async {
    return const PaginatedList<InvoiceModel>(items: []);
  }

  @override
  Future<InvoiceModel> getInvoiceDetails(int invoiceId) async {
    return InvoiceModel(
      invoiceId: invoiceId,
      networkId: 10,
      posId: 20,
      invoiceTotalAmount: 0,
    );
  }
}

void main() {
  group('InvoiceRepositoryImpl direct invoice contract', () {
    late _RecordingInvoiceRemoteDataSource remote;
    late InvoiceRepositoryImpl repository;

    setUp(() {
      remote = _RecordingInvoiceRemoteDataSource();
      repository = InvoiceRepositoryImpl(remoteDataSource: remote);
    });

    test('sends identifiers, sale type and voucher counts only', () async {
      final invoice = await repository.createDirectInvoice(
        networkId: 10,
        posId: 20,
        saleType: SaleType.credit,
        idempotencyKey: 'sale-pos20-idempotent-key',
        items: const [
          DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 100),
          DirectInvoiceItemInputEntity(packageId: 32, voucherCount: 250),
        ],
      );

      expect(invoice.invoiceId, 501);
      expect(remote.submittedIdempotencyKey, 'sale-pos20-idempotent-key');
      expect(remote.submittedNetworkId, 10);
      expect(remote.submittedPosId, 20);
      expect(remote.submittedSaleType, SaleType.credit);
      expect(remote.submittedItems?.length, 2);
      expect(remote.submittedItems?[0].packageId, 31);
      expect(remote.submittedItems?[0].voucherCount, 100);
      expect(remote.submittedItems?[1].packageId, 32);
      expect(remote.submittedItems?[1].voucherCount, 250);

      // Verify serialized JSON contract of items
      final serializedPayload = {
        'network_id': remote.submittedNetworkId,
        'pos_id': remote.submittedPosId,
        'sale_type': remote.submittedSaleType?.wireValue,
        'items': remote.submittedItems?.map((e) => e.toJson()).toList(),
      };
      expect(serializedPayload, {
        'network_id': 10,
        'pos_id': 20,
        'sale_type': 'CREDIT',
        'items': [
          {'package_id': 31, 'voucher_count': 100},
          {'package_id': 32, 'voucher_count': 250},
        ],
      });
      expect(serializedPayload.containsKey('paid_amount'), isFalse);
      expect(serializedPayload.containsKey('invoice_total_amount'), isFalse);
      final sentItems = serializedPayload['items'] as List;
      for (final item in sentItems.cast<Map<String, dynamic>>()) {
        expect(item.containsKey('voucher_price'), isFalse);
        expect(item.containsKey('item_discount'), isFalse);
        expect(item.containsKey('item_total_amount'), isFalse);
        expect(item.containsKey('unit_price'), isFalse);
        expect(item.containsKey('subtotal'), isFalse);
      }
    });

    test('converts unsuccessful server response into Exception', () async {
      remote.failCreation = true;

      await expectLater(
        repository.createDirectInvoice(
          networkId: 10,
          posId: 20,
          saleType: SaleType.cash,
          idempotencyKey: 'sale-pos20-error-key',
          items: const [
            DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 1),
          ],
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('رفض الخادم إنشاء الفاتورة'),
          ),
        ),
      );
    });
  });
}
