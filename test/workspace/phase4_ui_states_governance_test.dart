import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockResilientRequestRepo implements RequestRepository {
  List<RequestEntity> items;
  bool failNextPage = false;

  MockResilientRequestRepo(this.items);

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (cursor != null && failNextPage) {
      throw const AppException('تعذر تحميل الصفحة التالية؛ يرجى التحقق من الاتصال');
    }

    final filtered = items.where((r) {
      if (networkId != null && r.networkId != networkId) return false;
      if (posId != null && r.posId != posId) return false;
      if (status != null && status.isNotEmpty && r.statusRaw != status) return false;
      return true;
    }).toList();

    return PaginatedList<RequestEntity>(
      items: cursor == null ? filtered.take(1).toList() : filtered.skip(1).toList(),
      nextCursor: cursor == null && filtered.length > 1 ? 'cursor_page_2' : null,
    );
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    return items.firstWhere((r) => r.requestId == requestId);
  }

  @override
  Future<RequestEntity> createRequest(Map<String, dynamic> data) async => items.first;

  @override
  Future<RequestEntity> cancelRequest(int requestId) async => items.first;

  @override
  Future<RequestEntity> approveRequest(int requestId, {String? requestNote, List<RequestModificationLineEntity>? items}) async => this.items.first;

  @override
  Future<RequestEntity> rejectRequest(int requestId, String reason) async => items.first;

  @override
  Future<RequestModificationPreviewEntity> previewRequestModification(int requestId, List<RequestModificationLineEntity> items) async => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DummyPackageCatalogRepo implements PackageCatalogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PermissionService permissionService;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    permissionService = PermissionService.instance;
    Get.put<PermissionService>(permissionService);
    Get.put<WorkspaceService>(WorkspaceService.instance);
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 4.4: UI States & Resilience Governance Matrix', () {
    final sampleReq1 = RequestEntity(
      requestId: 101,
      networkId: 10,
      posId: 20,
      saleTypeRaw: 'CASH',
      requestTotalAmount: 1500.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
    );
    final sampleReq2 = RequestEntity(
      requestId: 102,
      networkId: 10,
      posId: 20,
      saleTypeRaw: 'CASH',
      requestTotalAmount: 2500.0,
      statusRaw: 'APPROVED',
      statusLabel: 'معتمد',
    );

    test('Partial Results Resilience: failing loadMore retains already loaded records', () async {
      final mockRepo = MockResilientRequestRepo([sampleReq1, sampleReq2]);
      final dummyPkgRepo = DummyPackageCatalogRepo();

      final controller = NetworkProcurementReviewController(
        getRequestsUseCase: GetRequestsUseCase(mockRepo),
        approveRequestUseCase: ApproveRequestUseCase(mockRepo),
        rejectRequestUseCase: RejectRequestUseCase(mockRepo),
        previewRequestModificationUseCase: PreviewRequestModificationUseCase(mockRepo),
        getPackagesUseCase: GetPackagesUseCase(dummyPkgRepo),
        getRequestDetailsUseCase: GetRequestDetailsUseCase(mockRepo),
      );

      controller.selectedNetworkId.value = 10;
      await controller.loadRequests();

      // First page loaded with 1 item and has a nextCursor
      expect(controller.requests.length, equals(1));
      expect(controller.requests.first.requestId, equals(101));
      expect(controller.hasMore, isTrue);

      // Simulate a network failure on loadMore
      mockRepo.failNextPage = true;
      await controller.loadMoreRequests();

      // Invariant: The already loaded first page must NOT be cleared or lost
      expect(controller.requests.length, equals(1));
      expect(controller.requests.first.requestId, equals(101));
      expect(controller.isLoadingMore.value, isFalse);
    });

    test('AppException sanitizer filters internal technical errors into user-friendly messages', () {
      // 1. Technical Dart errors are caught and sanitized
      final nullPointer = AppException.sanitizeMessage('Null check operator used on a null value');
      expect(nullPointer, equals('حدث خطأ غير متوقع'));

      final noElement = AppException.sanitizeMessage('Bad state: No element');
      expect(noElement, equals('حدث خطأ غير متوقع'));

      // 2. Legitimate user-facing messages are kept intact
      final networkError = AppException.sanitizeMessage('تعذر الاتصال بالخادم، يرجى التحقق من الشبكة');
      expect(networkError, equals('تعذر الاتصال بالخادم، يرجى التحقق من الشبكة'));

      // 3. AppException instance clean message extraction
      const appEx = AppException('الرصيد غير كافٍ لإتمام العملية');
      expect(AppException.sanitizeMessage(appEx), equals('الرصيد غير كافٍ لإتمام العملية'));
    });

    test('UI State: Permission denied prohibits sensitive action triggers in controller', () {
      final mockRepo = MockResilientRequestRepo([sampleReq1]);

      // Configure permissions without cancel rights
      permissionService.updateAccess(
        roleKey: 'POS_STAFF',
        permissions: [AppPermissions.requestsView],
      );

      final posController = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRepo),
        createRequestUseCase: CreateRequestUseCase(mockRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRepo),
      );

      // canCancelOrder and canCreateOrder must strictly reflect user permissions
      expect(posController.canCancelOrder, isFalse);
      expect(posController.canCreateOrder, isFalse);

      // Granting create permission updates state reactively
      permissionService.updateAccess(
        roleKey: 'POS_STAFF',
        permissions: [AppPermissions.requestsView, AppPermissions.requestsCreate],
      );
      expect(posController.canCreateOrder, isTrue);
      expect(posController.canCancelOrder, isFalse);
    });
  });
}
