import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';

class MockInvoiceDocumentRepository implements InvoiceDocumentRepository {
  @override
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) async => true;

  @override
  Future<bool> shareInvoice(InvoiceEntity invoice) async => true;

  @override
  Future<bool> printInvoice(InvoiceEntity invoice) async => true;
}

class MockInvoiceRepository implements InvoiceRepository {
  List<InvoiceEntity> mockList = [];
  String? returnNextCursor;
  InvoiceEntity? mockDetails;
  int callCount = 0;
  String? lastSearch;
  String? lastSaleType;

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
    callCount++;
    lastSearch = search;
    lastSaleType = saleType;

    return PaginatedList<InvoiceEntity>(
      items: mockList,
      nextCursor: returnNextCursor,
      prevCursor: null,
    );
  }

  @override
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) async {
    if (networkId <= 0 ||
        posId <= 0 ||
        items.isEmpty ||
        idempotencyKey.trim().isEmpty) {
      throw ArgumentError('Invalid direct invoice test payload.');
    }
    return mockDetails ??
        InvoiceEntity(
          invoiceId: 999,
          networkId: networkId,
          posId: posId,
          saleTypeRaw: saleType.wireValue,
          invoiceTotalAmount: 0,
        );
  }

  @override
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId) async {
    return mockDetails ??
        InvoiceEntity(
          invoiceId: invoiceId,
          networkId: 1,
          posId: 2,
          invoiceTotalAmount: 2500.0,
          paidAmount: 2500.0,
          remainingAmount: 0.0,
          paymentStatusRaw: 'PAID',
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInvoiceRepository mockRepo;
  late GetNetworkInvoicesUseCase getNetworkInvoicesUseCase;
  late GetPosInvoicesUseCase getPosInvoicesUseCase;
  late GetInvoiceDetailsUseCase getInvoiceDetailsUseCase;
  late InvoiceDocumentUseCase invoiceDocumentUseCase;

  final sampleInvoice1 = const InvoiceEntity(
    invoiceId: 1,
    networkId: 1,
    posId: 2,
    invoiceTotalAmount: 1500.0,
    paidAmount: 1500.0,
    remainingAmount: 0.0,
    paymentStatusRaw: 'PAID',
  );

  final sampleInvoice2 = const InvoiceEntity(
    invoiceId: 2,
    networkId: 1,
    posId: 3,
    invoiceTotalAmount: 3000.0,
    paidAmount: 1000.0,
    remainingAmount: 2000.0,
    paymentStatusRaw: 'PARTIALLY_PAID',
  );

  setUp(() {
    mockRepo = MockInvoiceRepository();
    getNetworkInvoicesUseCase = GetNetworkInvoicesUseCase(mockRepo);
    getPosInvoicesUseCase = GetPosInvoicesUseCase(mockRepo);
    getInvoiceDetailsUseCase = GetInvoiceDetailsUseCase(mockRepo);
    invoiceDocumentUseCase = InvoiceDocumentUseCase(MockInvoiceDocumentRepository());
  });

  group('NetworkInvoicesController Tests', () {
    test('Initial loading populates invoices list correctly', () async {
      mockRepo.mockList = [sampleInvoice1, sampleInvoice2];

      final controller = NetworkInvoicesController(
        getNetworkInvoicesUseCase: getNetworkInvoicesUseCase,
      );

      await controller.loadInvoices(isRefresh: true);

      expect(controller.invoices.length, equals(2));
      expect(controller.invoices.first.invoiceId, equals(1));
      expect(controller.invoices[1].invoiceId, equals(2));
      expect(controller.isLoading.value, isFalse);
    });

    test(
      'Cursor pagination appends invoices and handles deduplication',
      () async {
        mockRepo.mockList = [sampleInvoice1];
        mockRepo.returnNextCursor = 'cursor-token-123';

        final controller = NetworkInvoicesController(
          getNetworkInvoicesUseCase: getNetworkInvoicesUseCase,
        );

        await controller.loadInvoices(isRefresh: true);
        expect(controller.invoices.length, equals(1));
        expect(controller.hasMore, isTrue);

        // تحميل صفحة ثانية تتضمن نفس العنصر وعنصر جديد
        mockRepo.mockList = [sampleInvoice1, sampleInvoice2];
        mockRepo.returnNextCursor = null;

        await controller.loadMoreInvoices();

        // يجب ألا يتكرر sampleInvoice1
        expect(controller.invoices.length, equals(2));
        expect(controller.hasMore, isFalse);
      },
    );

    test('Changing sale type filter resets list and queries backend', () async {
      mockRepo.mockList = [sampleInvoice1];

      final controller = NetworkInvoicesController(
        getNetworkInvoicesUseCase: getNetworkInvoicesUseCase,
      );

      await controller.loadInvoices(isRefresh: true);
      expect(controller.invoices.length, equals(1));

      controller.onSaleTypeChanged('CREDIT');
      await controller.loadInvoices(isRefresh: true);

      expect(controller.selectedSaleType.value, equals('CREDIT'));
      expect(mockRepo.lastSaleType, equals('CREDIT'));
    });
  });

  group('PosInvoicesController Tests', () {
    test('Initial loading populates POS purchase invoices', () async {
      mockRepo.mockList = [sampleInvoice1];

      final controller = PosInvoicesController(
        getPosInvoicesUseCase: getPosInvoicesUseCase,
      );

      await controller.loadInvoices(isRefresh: true);

      expect(controller.invoices.length, equals(1));
      expect(controller.invoices.first.invoiceId, equals(1));
      expect(controller.isLoading.value, isFalse);
    });

    test('Reset filters clears search and restores full list', () async {
      final controller = PosInvoicesController(
        getPosInvoicesUseCase: getPosInvoicesUseCase,
      );

      controller.searchController.text = 'فاتورة 99';
      controller.selectedSaleType.value = 'CASH';

      controller.resetFilters();

      expect(controller.searchController.text, isEmpty);
      expect(controller.searchQuery.value, isEmpty);
      expect(controller.selectedSaleType.value, isNull);
    });
  });

  group('InvoiceDetailsController Tests', () {
    test('loadInvoiceDetails sets invoice entity correctly', () async {
      mockRepo.mockDetails = sampleInvoice2;

      final controller = InvoiceDetailsController(
        getInvoiceDetailsUseCase: getInvoiceDetailsUseCase,
        invoiceDocumentUseCase: invoiceDocumentUseCase,
      );

      await controller.loadInvoiceDetails(2);

      expect(controller.invoice.value, isNotNull);
      expect(controller.invoice.value!.invoiceId, equals(2));
      expect(controller.invoice.value!.remainingAmount, equals(2000.0));
      expect(controller.isLoading.value, isFalse);
    });
  });
}
