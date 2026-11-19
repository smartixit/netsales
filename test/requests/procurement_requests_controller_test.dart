import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';

class MockRequestRepository implements RequestRepository {
  List<RequestEntity> items;
  bool shouldThrow = false;
  int? lastRequestedNetworkId;

  MockRequestRepository(this.items);

  @override
  Future<RequestStatusSummaryEntity> getRequestStatusSummary({
    int? networkId,
    int? posId,
  }) async {
    final filtered = items.where((r) {
      if (networkId != null && r.networkId != networkId) return false;
      if (posId != null && r.posId != posId) return false;
      return true;
    }).toList();

    return RequestStatusSummaryEntity(
      total: filtered.length,
      pending: filtered.where((r) => r.isPending).length,
      approved: filtered.where((r) => r.isApproved).length,
      rejected: filtered.where((r) => r.isRejected).length,
      cancelled: filtered.where((r) => r.isCancelled).length,
    );
  }

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    lastRequestedNetworkId = networkId;
    if (shouldThrow) {
      throw const AppException('فشل الاتصال بالخادم', code: '500');
    }

    final filtered = items.where((r) {
      if (networkId != null && r.networkId != networkId) return false;
      if (posId != null && r.posId != posId) return false;
      if (status != null && status.isNotEmpty && r.statusRaw != status) {
        return false;
      }
      return true;
    }).toList();

    return PaginatedList<RequestEntity>(
      items: filtered,
      nextCursor: cursor == null && filtered.isNotEmpty
          ? 'cursor_page_2'
          : null,
    );
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    return items.firstWhere((r) => r.requestId == requestId);
  }

  @override
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    final req = RequestEntity(
      requestId: items.length + 1,
      networkId: data['network_id'] as int,
      posId: data['pos_id'] as int,
      saleTypeRaw: data['sale_type'] as String? ?? 'CASH',
      requestTotalAmount: 2000.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
    );
    items.insert(0, req);
    return req;
  }

  @override
  Future<RequestEntity> cancelRequest(int requestId) async {
    final index = items.indexWhere((r) => r.requestId == requestId);
    final existing = items[index];
    final updated = RequestEntity(
      requestId: existing.requestId,
      networkId: existing.networkId,
      posId: existing.posId,
      saleTypeRaw: existing.saleTypeRaw,
      requestTotalAmount: existing.requestTotalAmount,
      statusRaw: 'CANCELLED',
      statusLabel: 'ملغي',
    );
    items[index] = updated;
    return updated;
  }

  @override
  Future<RequestModificationPreviewEntity> previewRequestModification(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) async {
    throw UnimplementedError(
      'This test mock does not configure request modification previews.',
    );
  }

  @override
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) async {
    final index = this.items.indexWhere((r) => r.requestId == requestId);
    final existing = this.items[index];
    final updated = RequestEntity(
      requestId: existing.requestId,
      networkId: existing.networkId,
      posId: existing.posId,
      saleTypeRaw: existing.saleTypeRaw,
      requestTotalAmount: existing.requestTotalAmount,
      statusRaw: 'APPROVED',
      statusLabel: 'تمت الموافقة',
      invoiceId: 777,
    );
    this.items[index] = updated;
    return RequestApprovalResultEntity(
      request: updated,
      invoice: InvoiceEntity(
        invoiceId: 777,
        networkId: updated.networkId,
        posId: updated.posId,
        requestId: updated.requestId,
        invoiceTotalAmount: updated.requestTotalAmount,
        paidAmount: updated.requestTotalAmount,
        remainingAmount: 0,
        paymentStatusRaw: 'PAID',
        isFullyPaid: true,
      ),
    );
  }

  @override
  Future<ProcurementQuoteEntity> getQuote(Map<String, dynamic> payload) async {
    return const ProcurementQuoteEntity(
      networkId: 1,
      posId: 1,
      saleType: SaleType.cash,
      saleTypeLabel: 'نقدي',
      grossTotal: 1000.0,
      discountTotal: 100.0,
      netTotal: 900.0,
      currency: 'YER',
      pricingToken: 'mock_quote_token_123',
      items: [],
    );
  }

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async {
    final index = items.indexWhere((r) => r.requestId == requestId);
    final existing = items[index];
    final updated = RequestEntity(
      requestId: existing.requestId,
      networkId: existing.networkId,
      posId: existing.posId,
      saleTypeRaw: existing.saleTypeRaw,
      requestTotalAmount: existing.requestTotalAmount,
      statusRaw: 'REJECTED',
      statusLabel: 'مرفوض',
      requestNote: rejectionReason,
    );
    items[index] = updated;
    return updated;
  }

  @override
  Future<RequestEntity> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    final index = items.indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      final existing = items[index];
      final updated = RequestEntity(
        requestId: existing.requestId,
        networkId: existing.networkId,
        posId: existing.posId,
        requestUuid: existing.requestUuid,
        saleTypeRaw: data['sale_type'] as String? ?? existing.saleTypeRaw,
        requestTotalAmount: existing.requestTotalAmount,
        statusRaw: existing.statusRaw,
        statusLabel: existing.statusLabel,
        requestNote: data['request_note'] as String? ?? existing.requestNote,
      );
      items[index] = updated;
      return updated;
    }
    throw const AppException('Request not found', code: '404');
  }

  @override
  Future<bool> deleteRequest(int requestId) async {
    items.removeWhere((r) => r.requestId == requestId);
    return true;
  }
}

class MockCommercialRepository implements CommercialRepository {
  final List<PosEntity> posList;
  final List<NetworkPosLinkEntity> links;
  final List<NetworkEntity> networks;

  MockCommercialRepository({
    this.posList = const [],
    this.links = const [],
    this.networks = const [],
  });

  @override
  Future<List<PosEntity>> getMyPos() async => posList;

  @override
  Future<List<NetworkEntity>> getMyNetworks() async => networks;

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    return PaginatedList<NetworkPosLinkEntity>(items: links);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPackageCatalogRepository implements PackageCatalogRepository {
  final List<PackageEntity> packages;
  String? lastSearch;

  MockPackageCatalogRepository(this.packages);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  }) async {
    lastSearch = search;
    final scopedPackages = packageIds == null
        ? packages
        : packages
              .where((package) => packageIds.contains(package.packageId))
              .toList();
    final filtered = search == null || search.isEmpty
        ? scopedPackages
        : scopedPackages
              .where((package) => package.packageName.contains(search))
              .toList(growable: false);
    return PaginatedList<PackageEntity>(items: filtered);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleRequest1 = const RequestEntity(
    requestId: 1,
    networkId: 10,
    posId: 20,
    saleTypeRaw: 'CASH',
    requestTotalAmount: 5000.0,
    statusRaw: 'PENDING',
    statusLabel: 'قيد الانتظار',
  );

  final sampleRequest2 = const RequestEntity(
    requestId: 2,
    networkId: 10,
    posId: 20,
    saleTypeRaw: 'CREDIT',
    requestTotalAmount: 8000.0,
    statusRaw: 'APPROVED',
    statusLabel: 'تمت الموافقة',
  );

  final samplePos = const PosEntity(
    posId: 20,
    ownerId: 1,
    posUuid: 'pos-uuid-999',
    posName: 'نقطة الأمانة',
    posPhoneNumber: '777111222',
  );

  final sampleNetwork = const NetworkEntity(
    networkId: 10,
    ownerId: 2,
    networkName: 'شبكة يمن نت',
    networkPhoneNumber: '777333444',
  );

  final sampleLink = NetworkPosLinkEntity(
    networkPosId: 1,
    networkId: 10,
    posId: 20,
    status: true,
    network: sampleNetwork,
  );

  final samplePackage = const PackageEntity(
    packageId: 5,
    networkId: 10,
    packageName: 'باقة الذهب 10G',
    packageBalance: 10.0,
    packageVoucherCount: 100,
    packageVoucherPrice: 1500.0,
    packageDefaultCashDiscount: 5.0,
    packageDefaultCreditDiscount: 2.0,
    cashDiscountAmount: 75.0,
    creditDiscountAmount: 30.0,
    effectiveCashPrice: 1425.0,
    effectiveCreditPrice: 1470.0,
    status: true,
  );

  group('POS Procurement Collection and Form Controller Tests (M6.1)', () {
    late MockRequestRepository mockRequestRepo;
    late MockCommercialRepository mockCommercialRepo;
    late MockPackageCatalogRepository mockPackageRepo;
    late PosNewProcurementOrderController controller;
    late PosProcurementOrdersController ordersController;

    setUp(() {
      mockRequestRepo = MockRequestRepository([sampleRequest1, sampleRequest2]);
      mockCommercialRepo = MockCommercialRepository(
        posList: [samplePos],
        links: [sampleLink],
      );
      mockPackageRepo = MockPackageCatalogRepository([samplePackage]);

      ordersController = PosProcurementOrdersController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        deleteRequestUseCase: DeleteRequestUseCase(mockRequestRepo),
      );
      ordersController.onInit();

      controller = PosNewProcurementOrderController(
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );
      controller.onInit();
    });

    test('Initializes state and loads requests with cursor', () async {
      await ordersController.loadInitialData();
      expect(ordersController.requests.length, 2);
      expect(ordersController.nextCursor.value, 'cursor_page_2');
      expect(ordersController.hasMore, true);
      expect(ordersController.selectedPosId.value, 20);
    });

    test('setStatusFilter reloads requests filtered by status', () async {
      ordersController.setStatusFilter('PENDING');
      await ordersController.loadRequests();

      expect(ordersController.requests.length, 1);
      expect(ordersController.requests.first.requestId, 1);
    });

    test(
      'cancelRequest updates request status to CANCELLED in-place',
      () async {
        await ordersController.cancelRequest(1);
        expect(ordersController.requests.first.isCancelled, true);
      },
    );

    test(
      'loads the catalogue without silently selecting or adding a package',
      () async {
        await controller.loadLinkedNetworks(20);
        expect(controller.linkedNetworks.length, 1);
        expect(controller.selectedNetworkId.value, 10);

        await controller.loadNetworkPackages(10);
        expect(controller.availablePackages.length, 1);
        expect(controller.selectedPackage.value, isNull);
        expect(controller.requestedVoucherCount, 0);
        expect(controller.procurementCart, isEmpty);
      },
    );

    test(
      'package search never clears quantities already stored in the cart',
      () async {
        await controller.loadLinkedNetworks(20);
        controller.adjustPackageQuantity(samplePackage, 175);

        controller.onPackageSearchChanged('غير موجودة');
        // Search is intentionally debounced and independent from cart pricing refresh.
        await Future<void>.delayed(const Duration(milliseconds: 500));

        expect(mockPackageRepo.lastSearch, 'غير موجودة');
        expect(controller.availablePackages, isEmpty);
        expect(controller.cartQuantityForPackage(5), 175);
        expect(controller.procurementCart.single.package.packageId, 5);
      },
    );

    test(
      'catalogue quantity controls maintain independent package quantities',
      () async {
        await controller.loadLinkedNetworks(20);
        const secondPackage = PackageEntity(
          packageId: 6,
          networkId: 10,
          packageName: 'باقة الفضة',
          packageBalance: 5.0,
          packageVoucherCount: 60,
          packageVoucherPrice: 900.0,
          packageDefaultCashDiscount: 0,
          packageDefaultCreditDiscount: 0,
          cashDiscountAmount: 0,
          creditDiscountAmount: 0,
          effectiveCashPrice: 900,
          effectiveCreditPrice: 900,
          status: true,
        );

        controller.adjustPackageQuantity(samplePackage, 1);
        controller.adjustPackageQuantity(secondPackage, 1);
        controller.adjustPackageQuantity(samplePackage, 1);

        expect(controller.cartQuantityForPackage(5), 2);
        expect(controller.cartQuantityForPackage(6), 1);
        expect(controller.procurementCart.length, 2);

        controller.adjustPackageQuantity(samplePackage, -2);
        expect(controller.cartQuantityForPackage(5), 0);
        expect(controller.cartQuantityForPackage(6), 1);
        expect(controller.procurementCart.length, 1);
      },
    );

    test(
      'manual quantities accept non-sheet multiples and zero removes the line',
      () async {
        await controller.loadLinkedNetworks(20);
        controller.setPackageVoucherCount(samplePackage, 175);
        expect(controller.cartQuantityForPackage(5), 175);
        expect(controller.procurementCart.single.voucherCount, 175);
        expect(controller.procurementCart.single.sheets, 1.75);

        controller.setPackageVoucherCount(samplePackage, 0);
        expect(controller.procurementCart, isEmpty);
      },
    );
  });

  group('NetworkProcurementReviewController Tests (M6.2)', () {
    late MockRequestRepository mockRequestRepo;
    late MockCommercialRepository mockCommercialRepo;
    late NetworkProcurementReviewController controller;

    setUp(() {
      mockRequestRepo = MockRequestRepository([sampleRequest1, sampleRequest2]);
      mockCommercialRepo = MockCommercialRepository(networks: [sampleNetwork]);

      controller = NetworkProcurementReviewController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        approveRequestUseCase: ApproveRequestUseCase(mockRequestRepo),
        rejectRequestUseCase: RejectRequestUseCase(mockRequestRepo),
        previewRequestModificationUseCase: PreviewRequestModificationUseCase(
          mockRequestRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(
          MockPackageCatalogRepository([samplePackage]),
        ),
        getRequestDetailsUseCase: GetRequestDetailsUseCase(mockRequestRepo),
        getMyNetworksUseCase: GetMyNetworksUseCase(mockCommercialRepo),
      );
      controller.onInit();
    });

    test(
      'Initializes incoming review queue and auto-selects network',
      () async {
        await controller.loadNetworksAndRequests();
        expect(controller.requests.length, 2);
        expect(controller.selectedNetworkId.value, 10);
        expect(controller.nextCursor.value, 'cursor_page_2');
      },
    );

    test(
      'network filter reloads after CustomDropdown pre-updates its listenable',
      () async {
        controller.selectedNetworkId.value = 30;
        await controller.onNetworkFilterChanged(30);

        expect(mockRequestRepo.lastRequestedNetworkId, 30);
        expect(controller.requests, isEmpty);
      },
    );

    test('approveRequest approves pending request and updates list', () async {
      await controller.approveRequest(1, requestNote: 'تم الفحص');
      expect(controller.requests.first.isApproved, true);
    });

    test('rejectRequest rejects request with mandatory reason', () async {
      await controller.rejectRequest(1, 'الكمية المطلوبة غير متوفرة حالياً');
      expect(controller.requests.first.isRejected, true);
      expect(
        controller.requests.first.requestNote,
        'الكمية المطلوبة غير متوفرة حالياً',
      );
    });

    test(
      'rejectRequest with empty reason prevents mutation',
      () async {
        await controller.rejectRequest(1, '');
        expect(controller.requests.first.isPending, true);
      },
    );
  });
}
