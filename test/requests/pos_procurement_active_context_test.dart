import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockRequestRepo implements RequestRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final List<Map<String, dynamic>> createdPayloads = [];

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    return const PaginatedList(items: [], nextCursor: null);
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    throw UnimplementedError();
  }

  @override
  Future<RequestEntity> createRequest(Map<String, dynamic> data) async {
    createdPayloads.add(Map<String, dynamic>.from(data));
    return RequestEntity(
      requestId: 999,
      networkId: data['network_id'] as int,
      posId: data['pos_id'] as int,
      saleTypeRaw: data['sale_type'] as String? ?? 'CASH',
      requestTotalAmount: 5000.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
    );
  }

  @override
  Future<RequestEntity> cancelRequest(int requestId) async {
    throw UnimplementedError();
  }

  Future<RequestModificationPreviewEntity> previewModification({
    required int requestId,
    required List<RequestModificationLineEntity> lines,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  Future<RequestEntity> approveModification({
    required int requestId,
    required List<RequestModificationLineEntity> lines,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  Future<RequestEntity> rejectModification({
    required int requestId,
    String? reason,
  }) async {
    throw UnimplementedError();
  }
}

class MockCommercialRepo implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  List<PosEntity> posItems;
  final Map<int, List<NetworkPosLinkEntity>> linksByPos;

  MockCommercialRepo({required this.posItems, required this.linksByPos});

  @override
  Future<List<PosEntity>> getMyPos() async => posItems;

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    return PaginatedList(
      items: linksByPos[posId] ?? const [],
      nextCursor: null,
    );
  }

  @override
  Future<List<NetworkEntity>> getMyNetworks() async => const [];
}

class MockPackageRepo implements PackageCatalogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final List<PackageEntity> packages;
  MockPackageRepo(this.packages);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    return PaginatedList(items: packages, nextCursor: null);
  }
}

class MockFinanceRepo implements FinanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pos1 = PosEntity(
    posId: 101,
    ownerId: 10,
    posUuid: 'pos-uuid-1',
    posName: 'نقطة بيع صنعاء الأولى',
    posPhoneNumber: '771000101',
    posAddress: 'شارع الزبيري',
  );

  const pos2 = PosEntity(
    posId: 202,
    ownerId: 10,
    posUuid: 'pos-uuid-2',
    posName: 'نقطة بيع عدن الثانية',
    posPhoneNumber: '772000202',
    posAddress: 'المعلا',
  );

  const pos3 = PosEntity(
    posId: 303,
    ownerId: 10,
    posUuid: 'pos-uuid-3',
    posName: 'نقطة بيع تعز الثالثة',
    posPhoneNumber: '773000303',
    posAddress: 'شارع جمال',
  );

  const network1 = NetworkEntity(
    networkId: 10,
    ownerId: 20,
    networkName: 'شبكة يمن نت',
    networkPhoneNumber: '770000010',
  );

  const network2 = NetworkEntity(
    networkId: 20,
    ownerId: 20,
    networkName: 'شبكة عدن نت',
    networkPhoneNumber: '770000020',
  );

  final linkForPos1 = NetworkPosLinkEntity(
    networkPosId: 1,
    networkId: 10,
    posId: 101,
    status: true,
    network: network1,
  );

  final linkForPos2 = NetworkPosLinkEntity(
    networkPosId: 2,
    networkId: 20,
    posId: 202,
    status: true,
    network: network2,
  );

  const package1 = PackageEntity(
    packageId: 50,
    networkId: 10,
    packageName: 'باقة الفجر 100 كرت',
    packageBalance: 1000.0,
    packageVoucherPrice: 1000.0,
    packageVoucherCount: 100,
    packageDefaultCashDiscount: 0.0,
    packageDefaultCreditDiscount: 0.0,
    cashDiscountAmount: 0.0,
    creditDiscountAmount: 0.0,
    effectiveCashPrice: 1000.0,
    effectiveCreditPrice: 1000.0,
    status: true,
  );

  const package2 = PackageEntity(
    packageId: 60,
    networkId: 20,
    packageName: 'باقة البحر 200 كرت',
    packageBalance: 2000.0,
    packageVoucherPrice: 2000.0,
    packageVoucherCount: 200,
    packageDefaultCashDiscount: 0.0,
    packageDefaultCreditDiscount: 0.0,
    cashDiscountAmount: 0.0,
    creditDiscountAmount: 0.0,
    effectiveCashPrice: 2000.0,
    effectiveCreditPrice: 2000.0,
    status: true,
  );

  late MockRequestRepo mockRequestRepo;
  late MockCommercialRepo mockCommercialRepo;
  late MockPackageRepo mockPackageRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<SessionService>(SessionService.instance);

    // Initial user setup
    final user = UserModel(
      userId: 555,
      userFullName: 'مشغل نقاط البيع',
      userPhoneNumber: '775555555',
      workspaceMemberships: const [
        WorkspaceMembershipModel(
          scope: RoleScope.pos,
          tenantId: 101,
          roleKey: 'POS_AGENT',
          roleName: 'وكيل معتمد',
        ),
        WorkspaceMembershipModel(
          scope: RoleScope.pos,
          tenantId: 202,
          roleKey: 'POS_AGENT',
          roleName: 'وكيل معتمد',
        ),
      ],
    );

    await SessionService.instance.syncSessionProfile(
      user: user,
      permissions: ['procurement.create', 'procurement.view'],
    );

    mockRequestRepo = MockRequestRepo();
    mockCommercialRepo = MockCommercialRepo(
      posItems: [pos1, pos2],
      linksByPos: {
        101: [linkForPos1],
        202: [linkForPos2],
      },
    );
    mockPackageRepo = MockPackageRepo([package1, package2]);
  });

  tearDown(() {
    Get.reset();
  });

  group('P0-2: Mandatory Acceptance Criteria for POS Procurement Context', () {
    // 1. مستخدم لديه نقطة بيع واحدة -> اختيار تلقائي دون إجبار يدوي
    test(
      'Acceptance 1: مستخدم لديه نقطة بيع واحدة يتم تحديدها تلقائياً',
      () async {
        mockCommercialRepo.posItems = [pos1];

        final controller = PosProcurementController(
          getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
          createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
          cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
          getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
          getPosNetworksListUseCase: GetPosNetworksListUseCase(
            mockCommercialRepo,
          ),
          getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
        );

        await controller.loadMyPos();

        // Determined automatically
        expect(controller.selectedPosId.value, equals(101));
        expect(controller.activePos?.posName, equals('نقطة بيع صنعاء الأولى'));
        expect(controller.linkedNetworks.length, equals(1));
      },
    );

    // 2. مستخدم لديه عدة نقاط بيع ويختار الثانية من الشاشة الرئيسية -> ينعكس فوراً في شاشة التوريد
    test('Acceptance 2: مستخدم يختار النقطة الثانية من مساحة العمل فتنعكس تلقائياً في التوريد', () async {
      mockCommercialRepo.posItems = [pos1, pos2];

      final workspaceCtrl = PosWorkspaceController(
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPosWalletByNetworkAndPosUseCase: GetPosWalletByNetworkAndPosUseCase(
          MockFinanceRepo(),
        ),
      );

      // User selects POS #202 in workspace
      await workspaceCtrl.selectPos(pos2);
      expect(workspaceCtrl.activePos.value?.posId, equals(202));
      expect(WorkspaceService.instance.savedActivePosId, equals(202));

      // Now POS Procurement controller loads
      final procurementCtrl = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );

      await procurementCtrl.loadMyPos();

      // Must strictly restore pos2 (202), NOT pos1 (first)!
      expect(procurementCtrl.selectedPosId.value, equals(202));
      expect(
        procurementCtrl.activePos?.posName,
        equals('نقطة بيع عدن الثانية'),
      );
      expect(procurementCtrl.linkedNetworks.first.networkId, equals(20));
    });

    // 3. إغلاق التطبيق واستعادته مع الاحتفاظ بالنقطة المختارة (Cold Reboot)
    test(
      'Acceptance 3: إغلاق التطبيق واستعادته يحتفظ بالنقطة المختارة',
      () async {
        // 1. Save active POS as #202
        await WorkspaceService.instance.saveActivePosId(202);
        expect(WorkspaceService.instance.savedActivePosId, equals(202));

        // 2. Simulate complete cold reboot of GetX and services
        Get.reset();
        Get.put<StorageService>(StorageService.instance);
        Get.put<PermissionService>(PermissionService.instance);
        Get.put<WorkspaceService>(WorkspaceService.instance);
        Get.put<SessionService>(SessionService.instance);

        await SessionService.instance.init();
        await WorkspaceService.instance.init();

        final procurementCtrl = PosProcurementController(
          getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
          createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
          cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
          getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
          getPosNetworksListUseCase: GetPosNetworksListUseCase(
            mockCommercialRepo,
          ),
          getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
        );

        await procurementCtrl.loadMyPos();

        // Must be restored from persistent storage
        expect(procurementCtrl.selectedPosId.value, equals(202));
      },
    );

    // 4. تبديل نقطة البيع ثم إنشاء طلب جديد -> تصفير السياق وإرسال الطلب لـ pos_id الفعلي
    test('Acceptance 4: تبديل نقطة البيع يصفر السلة ويرسل الطلب لـ pos_id المحدد فعلياً', () async {
      mockCommercialRepo.posItems = [pos1, pos2];

      final controller = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );

      // Initialize POS list
      await controller.loadMyPos();

      // Start with POS 101
      await controller.onPosSelected(101);
      expect(controller.selectedPosId.value, equals(101));

      // Select network and package, add to cart
      controller.onNetworkSelected(10);
      await controller.loadNetworkPackages(10);
      controller.onPackageSelected(package1);
      controller.addOrUpdateCartLine();
      expect(controller.procurementCart.length, equals(1));

      // Switch to POS 202
      await controller.onPosSelected(202);

      // Previous cart and network must be cleanly purged!
      expect(controller.selectedPosId.value, equals(202));
      expect(controller.procurementCart, isEmpty);
      expect(
        controller.selectedNetworkId.value,
        equals(20),
      ); // auto-selected since only 1 network for pos2
      expect(WorkspaceService.instance.savedActivePosId, equals(202));

      // Add package from network 2
      await controller.loadNetworkPackages(20);
      controller.onPackageSelected(package2);
      controller.addOrUpdateCartLine();

      // Submit order
      final success = await controller.submitOrder();
      expect(success, isTrue);

      // Verify payload pos_id strictly matches the newly selected POS #202
      expect(mockRequestRepo.createdPayloads.length, equals(1));
      final payload = mockRequestRepo.createdPayloads.first;
      expect(payload['pos_id'], equals(202));
      expect(payload['network_id'], equals(20));
    });

    // 5. إلغاء صلاحية نقطة البيع النشطة أثناء الجلسة -> منع الإرسال ورفض السياق
    test('Acceptance 5: إلغاء صلاحية نقطة البيع النشطة يمنع الإرسال ويتجاهل المعرف الملغى', () async {
      // User had saved POS #999, which is now revoked and NOT in authorized myPosList
      await WorkspaceService.instance.saveActivePosId(999);

      mockCommercialRepo.posItems = [
        pos1,
        pos2,
      ]; // only 101 and 202 are authorized

      final controller = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );

      await controller.loadMyPos();

      // Revoked ID #999 was discarded, multiple points exist without valid saved ID -> must be null, never first!
      expect(controller.selectedPosId.value, isNull);

      // Attempting to submit without valid POS fails safely
      final submitSuccess = await controller.submitOrder();
      expect(submitSuccess, isFalse);
      expect(mockRequestRepo.createdPayloads, isEmpty);
    });

    // 6. وصول قائمة نقاط البيع بترتيب مختلف من API -> حتمية الاختيار دون التأثر بترتيب السيرفر
    test('Acceptance 6: وصول القائمة بترتيب معكوس أو مختلف من API لا يغير نقطة البيع النشطة المحفوظة', () async {
      // Saved active POS is #202
      await WorkspaceService.instance.saveActivePosId(202);

      // API returns [pos3, pos2, pos1] or [pos1, pos3, pos2]
      mockCommercialRepo.posItems = [pos3, pos1, pos2];

      final controller = PosProcurementController(
        getRequestsUseCase: GetRequestsUseCase(mockRequestRepo),
        createRequestUseCase: CreateRequestUseCase(mockRequestRepo),
        cancelRequestUseCase: CancelRequestUseCase(mockRequestRepo),
        getMyPosUseCase: GetMyPosUseCase(mockCommercialRepo),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          mockCommercialRepo,
        ),
        getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      );

      await controller.loadMyPos();

      // Must resolutely select #202 regardless of where it appears in the API list!
      expect(controller.selectedPosId.value, equals(202));
      expect(controller.selectedPosId.value, isNot(equals(pos3.posId)));
    });
  });
}
