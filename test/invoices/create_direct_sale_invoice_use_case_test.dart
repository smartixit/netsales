import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';

class _RecordingInvoiceRepository implements InvoiceRepository {
  int createCalls = 0;
  int? networkId;
  int? posId;
  SaleType? saleType;
  List<DirectInvoiceItemInputEntity>? items;
  String? idempotencyKey;

  @override
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) async {
    createCalls++;
    this.networkId = networkId;
    this.posId = posId;
    this.saleType = saleType;
    this.items = List<DirectInvoiceItemInputEntity>.unmodifiable(items);
    this.idempotencyKey = idempotencyKey;

    return InvoiceEntity(
      invoiceId: 901,
      networkId: networkId,
      posId: posId,
      saleTypeRaw: saleType.wireValue,
      invoiceTotalAmount: 0,
    );
  }

  @override
  Future<PaginatedList<InvoiceEntity>> getInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) async {
    return const PaginatedList<InvoiceEntity>(items: []);
  }

  @override
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId) {
    throw UnimplementedError();
  }
}

void main() {
  group('CreateDirectSaleInvoiceUseCase', () {
    late _RecordingInvoiceRepository repository;
    late CreateDirectSaleInvoiceUseCase useCase;

    setUp(() {
      repository = _RecordingInvoiceRepository();
      useCase = CreateDirectSaleInvoiceUseCase(repository);
    });

    test(
      'submits only identifiers, sale type and voucher quantities',
      () async {
        final invoice = await useCase(
          networkId: 10,
          posId: 20,
          saleType: SaleType.credit,
          idempotencyKey: 'sale-pos20-unique-test-key',
          items: const [
            DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 100),
            DirectInvoiceItemInputEntity(packageId: 32, voucherCount: 250),
          ],
        );

        expect(invoice.invoiceId, 901);
        expect(repository.createCalls, 1);
        expect(repository.networkId, 10);
        expect(repository.posId, 20);
        expect(repository.saleType, SaleType.credit);
        expect(repository.idempotencyKey, 'sale-pos20-unique-test-key');
        expect(repository.items, const [
          DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 100),
          DirectInvoiceItemInputEntity(packageId: 32, voucherCount: 250),
        ]);
      },
    );

    test('rejects empty item lists before contacting repository', () async {
      expect(
        () => useCase(
          networkId: 10,
          posId: 20,
          saleType: SaleType.cash,
          idempotencyKey: 'sale-test-empty',
          items: const [],
        ),
        throwsArgumentError,
      );
      expect(repository.createCalls, 0);
    });

    test(
      'rejects non-positive item quantities before contacting repository',
      () async {
        expect(
          () => useCase(
            networkId: 10,
            posId: 20,
            saleType: SaleType.cash,
            idempotencyKey: 'sale-test-invalid-count',
            items: const [
              DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 0),
            ],
          ),
          throwsArgumentError,
        );
        expect(repository.createCalls, 0);
      },
    );

    test(
      'rejects an empty idempotency key before contacting repository',
      () async {
        expect(
          () => useCase(
            networkId: 10,
            posId: 20,
            saleType: SaleType.cash,
            idempotencyKey: ' ',
            items: const [
              DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 1),
            ],
          ),
          throwsArgumentError,
        );
        expect(repository.createCalls, 0);
      },
    );

    test('rejects unknown sale type before contacting repository', () async {
      expect(
        () => useCase(
          networkId: 10,
          posId: 20,
          saleType: SaleType.unknown,
          idempotencyKey: 'sale-test-unknown-type',
          items: const [
            DirectInvoiceItemInputEntity(packageId: 31, voucherCount: 1),
          ],
        ),
        throwsArgumentError,
      );
      expect(repository.createCalls, 0);
    });
  });
}
