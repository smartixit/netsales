import 'package:flutter_test/flutter_test.dart';
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
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';

class MockRequestRepository implements RequestRepository {
  List<RequestEntity> items;
  bool shouldThrow = false;

  MockRequestRepository(this.items);

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
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
      nextCursor: cursor == null && filtered.isNotEmpty ? 'cursor_page_2' : null,
    );
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    return items.firstWhere((r) => r.requestId == requestId);
  }

  @override
  Future<RequestEntity> createRequest(Map<String, dynamic> data) async {
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
  Future<RequestEntity> approveRequest(
    int requestId, {
    String? requestNote,
  }) async {
    final index = items.indexWhere((r) => r.requestId == requestId);
    final existing = items[index];
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
    items[index] = updated;
    return updated;
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

  MockPackageCatalogRepository(this.packages);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    return PaginatedList<PackageEntity>(items: packages);
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

  group('PosProcurementController Tests (M6.1)', () {
    late MockRequestRepository mockRequestRepo;
    late MockCommercialRepository mockCommercialRepo;
    late MockPackageCatalogRepository mockPackageRepo;
    late PosProcurementController controller;

    setUp(() {
      mockRequestRepo =
          MockRequestRepository([sampleRequest1, sampleRequest2]);
      mockCommercialRepo = MockCommercialRepository(
        posList: [samplePos],
        links: [sampleLink],
      );
      mockPackageRepo = MockPackageCatalogRepository([samplePackage]);

      controller = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase:
            GetPosNetworksListUseCase(mockCommercialRepo),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );
      controller.onInit();
    });

    test('Initializes state and loads requests with cursor', () async {
      await controller.loadInitialData();
      expect(controller.requests.length, 2);
      expect(controller.nextCursor.value, 'cursor_page_2');
      expect(controller.hasMore, true);
      expect(controller.selectedPosId.value, 20);
    });

    test('setStatusFilter reloads requests filtered by status', () async {
      controller.setStatusFilter('PENDING');
      await controller.loadRequests();

      expect(controller.requests.length, 1);
      expect(controller.requests.first.requestId, 1);
    });

    test('cancelRequest updates request status to CANCELLED in-place', () async {
      final success = await controller.cancelRequest(1);
      expect(success, true);
      expect(controller.requests.first.isCancelled, true);
    });

    test('loadLinkedNetworks and loadNetworkPackages populates wizard form',
        () async {
      await controller.loadLinkedNetworks(20);
      expect(controller.linkedNetworks.length, 1);
      expect(controller.selectedNetworkId.value, 10);

      await controller.loadNetworkPackages(10);
      expect(controller.availablePackages.length, 1);
      expect(controller.selectedPackage.value?.packageId, 5);
    });
  });

  group('NetworkProcurementReviewController Tests (M6.2)', () {
    late MockRequestRepository mockRequestRepo;
    late MockCommercialRepository mockCommercialRepo;
    late NetworkProcurementReviewController controller;

    setUp(() {
      mockRequestRepo =
          MockRequestRepository([sampleRequest1, sampleRequest2]);
      mockCommercialRepo = MockCommercialRepository(
        networks: [sampleNetwork],
      );

      controller = NetworkProcurementReviewController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        approveRequestUseCase: ApproveRequestUseCase(mockRequestRepo),
        rejectRequestUseCase: RejectRequestUseCase(mockRequestRepo),
        getMyNetworksUseCase: GetMyNetworksUseCase(mockCommercialRepo),
      );
      controller.onInit();
    });

    test('Initializes incoming review queue and auto-selects network', () async {
      await controller.loadNetworksAndRequests();
      expect(controller.requests.length, 2);
      expect(controller.selectedNetworkId.value, 10);
      expect(controller.nextCursor.value, 'cursor_page_2');
    });

    test('approveRequest approves pending request and updates list', () async {
      final success = await controller.approveRequest(1, requestNote: 'تم الفحص');
      expect(success, true);
      expect(controller.requests.first.isApproved, true);
    });

    test('rejectRequest rejects request with mandatory reason', () async {
      final success =
          await controller.rejectRequest(1, 'الكمية المطلوبة غير متوفرة حالياً');
      expect(success, true);
      expect(controller.requests.first.isRejected, true);
      expect(controller.requests.first.requestNote,
          'الكمية المطلوبة غير متوفرة حالياً');
    });

    test('rejectRequest with empty reason returns false and prevents mutation',
        () async {
      final success = await controller.rejectRequest(1, '');
      expect(success, false);
      expect(controller.requests.first.isPending, true);
    });
  });
}
