import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';

class _RecordingInvoiceRemoteDataSource implements InvoiceRemoteDataSource {
  Map<String, dynamic>? submittedPayload;
  String? submittedIdempotencyKey;
  bool failCreation = false;

  @override
  Future<ApiResponse<InvoiceModel>> createDirectInvoice(
    Map<String, dynamic> payload, {
    required String idempotencyKey,
  }) async {
    submittedPayload = Map<String, dynamic>.from(payload);
    submittedIdempotencyKey = idempotencyKey;
    if (failCreation) {
      return ApiResponse<InvoiceModel>(
        success: false,
        message: 'رفض الخادم إنشاء الفاتورة.',
      );
    }
    return ApiResponse<InvoiceModel>(
      success: true,
      message: 'تم إنشاء الفاتورة.',
      data: const InvoiceModel(
        invoiceId: 501,
        networkId: 10,
        posId: 20,
        invoiceTotalAmount: 0,
      ),
    );
  }

  @override
  Future<ApiResponse<List<InvoiceModel>>> getInvoices({
    Map<String, dynamic>? query,
  }) async {
    return ApiResponse<List<InvoiceModel>>(
      success: true,
      message: 'ok',
      data: const [],
    );
  }

  @override
  Future<ApiResponse<InvoiceModel>> getInvoiceDetails(int invoiceId) async {
    return ApiResponse<InvoiceModel>(
      success: true,
      message: 'ok',
      data: InvoiceModel(
        invoiceId: invoiceId,
        networkId: 10,
        posId: 20,
        invoiceTotalAmount: 0,
      ),
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
      expect(remote.submittedPayload, {
        'network_id': 10,
        'pos_id': 20,
        'sale_type': 'CREDIT',
        'items': [
          {'package_id': 31, 'voucher_count': 100},
          {'package_id': 32, 'voucher_count': 250},
        ],
      });
      expect(remote.submittedPayload!.containsKey('paid_amount'), isFalse);
      expect(
        remote.submittedPayload!.containsKey('invoice_total_amount'),
        isFalse,
      );
      final sentItems = remote.submittedPayload!['items'] as List;
      for (final item in sentItems.cast<Map<String, dynamic>>()) {
        expect(item.containsKey('voucher_price'), isFalse);
        expect(item.containsKey('item_discount'), isFalse);
        expect(item.containsKey('item_total_amount'), isFalse);
        expect(item.containsKey('unit_price'), isFalse);
        expect(item.containsKey('subtotal'), isFalse);
      }
    });

    test('converts unsuccessful server response into AppException', () async {
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
