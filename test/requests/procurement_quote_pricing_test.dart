import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/data/models/procurement_quote_model.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_financial_quote_card.dart';

class FakeQuoteRequestRepository implements RequestRepository {
  ProcurementQuoteEntity? nextQuote;
  bool throwOnQuote = false;
  bool throwPricingOnCreate = false;
  bool throwOnceOnCreate = false;
  Map<String, dynamic>? lastCreatePayload;
  final List<String?> createIdempotencyKeys = [];
  Map<String, dynamic>? lastQuotePayload;

  @override
  Future<ProcurementQuoteEntity> getQuote(Map<String, dynamic> payload) async {
    lastQuotePayload = payload;
    if (throwOnQuote) {
      throw const AppException('تعذر الاتصال بخدمة التسعير', code: '500');
    }
    return nextQuote ??
        const ProcurementQuoteEntity(
          networkId: 10,
          posId: 20,
          saleType: SaleType.cash,
          saleTypeLabel: 'نقدي',
          grossTotal: 50000.0,
          discountTotal: 5000.0,
          netTotal: 45000.0,
          currency: 'YER',
          pricingToken: 'fake_valid_hmac_token',
          items: [
            ProcurementQuoteLineEntity(
              packageId: 101,
              packageName: 'باقة الفخامة',
              packageVoucherCount: 100,
              voucherCount: 500,
              unitPrice: 100.0,
              discountRate: 10.0,
              effectivePrice: 90.0,
              lineGrossTotal: 50000.0,
              lineDiscountAmount: 5000.0,
              lineNetTotal: 45000.0,
              isCustomDiscount: true,
              pricingToken: 'item_token_101',
            ),
          ],
        );
  }

  @override
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    lastCreatePayload = data;
    createIdempotencyKeys.add(idempotencyKey);
    if (throwOnceOnCreate) {
      throwOnceOnCreate = false;
      throw const AppException('تعذر الاتصال بالخادم', code: '500');
    }
    if (throwPricingOnCreate) {
      throw const AppException(
        'تم تحديث أسعار الباقات أو شروط الخصم المعتمدة لدى الشبكة. يرجى مراجعة وتحديث عرض الأسعار قبل الإرسال.',
        code: '422',
      );
    }
    return const RequestEntity(
      requestId: 55,
      requestUuid: 'REQ-UUID-55',
      networkId: 10,
      posId: 20,
      saleTypeRaw: 'CASH',
      requestTotalAmount: 45000.0,
      statusRaw: 'PENDING',
      statusLabel: 'قيد الانتظار',
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
  }) async =>
      const PaginatedList(items: [], nextCursor: null);

  @override
  Future<RequestEntity> cancelRequest(int requestId) async =>
      throw UnimplementedError();

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async =>
      throw UnimplementedError();

  @override
  Future<RequestModificationPreviewEntity> previewRequestModification(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) async =>
      throw UnimplementedError();

  @override
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) async =>
      throw UnimplementedError();

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async =>
      throw UnimplementedError();

  @override
  Future<RequestEntity> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async =>
      throw UnimplementedError();

  @override
  Future<bool> deleteRequest(int requestId) async => true;
}

const testPos = PosEntity(
  posId: 20,
  ownerId: 1,
  posUuid: 'pos-uuid-20',
  posName: 'نقطة الأمل النموذجية',
  posPhoneNumber: '777000000',
  status: 'ACTIVE',
);

const testNetwork = NetworkEntity(
  networkId: 10,
  ownerId: 1,
  networkName: 'شبكة يمن فايبر',
  networkPhoneNumber: '770000010',
  status: 'ACTIVE',
);

final testLink = NetworkPosLinkEntity(
  networkPosId: 1,
  networkId: 10,
  posId: 20,
  status: true,
  network: testNetwork,
  pos: testPos,
);

final testPackage = PackageEntity(
  packageId: 101,
  networkId: 10,
  packageName: 'باقة الفخامة',
  packageBalance: 1000.0,
  packageVoucherPrice: 100.0,
  packageVoucherCount: 100,
  packageDefaultCashDiscount: 10.0,
  packageDefaultCreditDiscount: 5.0,
  cashDiscountAmount: 10.0,
  creditDiscountAmount: 5.0,
  effectiveCashPrice: 90.0,
  effectiveCreditPrice: 95.0,
  status: true,
  packageColor: '#00AAFF',
  procurementBaseUnitPriceMinor: 10000,
  procurementCashUnitPriceMinor: 9000,
  procurementCreditUnitPriceMinor: 9500,
  procurementCashDiscountBasisPoints: 1000,
  procurementCreditDiscountBasisPoints: 500,
  procurementPricingSnapshotToken: 'signed_snapshot_token_for_package_101',
  procurementPricingSnapshotExpiresAt: DateTime(2099),
);

class FakeCommercialRepository implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<PosEntity>> getMyPos() async => [testPos];

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async =>
      PaginatedList(
        items: [testLink],
        nextCursor: null,
      );
}

class FakePackageCatalogRepository implements PackageCatalogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async =>
      PaginatedList(
        items: [testPackage],
        nextCursor: null,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeQuoteRequestRepository mockRepo;
  late FakeCommercialRepository commercialRepo;
  late FakePackageCatalogRepository packageRepo;
  late PosProcurementController controller;

  setUp(() {
    Get.reset();
    mockRepo = FakeQuoteRequestRepository();
    commercialRepo = FakeCommercialRepository();
    packageRepo = FakePackageCatalogRepository();

    controller = PosProcurementController(
      getRequestsUseCase: GetRequestsUseCase(mockRepo),
      createRequestUseCase: CreateRequestUseCase(mockRepo),
      cancelRequestUseCase: CancelRequestUseCase(mockRepo),
      getMyPosUseCase: GetMyPosUseCase(commercialRepo),
      getPosNetworksListUseCase: GetPosNetworksListUseCase(commercialRepo),
      getPackagesUseCase: GetPackagesUseCase(packageRepo),
      getProcurementQuoteUseCase: GetProcurementQuoteUseCase(mockRepo),
    );
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 3.1: Procurement Quote Entity & Model Serialization', () {
    test('ProcurementQuoteModel parses JSON and calculates discount percentage accurately', () {
      final json = {
        'network_id': 10,
        'pos_id': 20,
        'sale_type': 'CASH',
        'sale_type_label': 'دفع نقدي',
        'gross_total': 20000.0,
        'discount_total': 2000.0,
        'net_total': 18000.0,
        'currency': 'YER',
        'pricing_token': 'hmac_sha256_valid_token',
        'expires_at': '2026-11-10T21:00:00.000Z',
        'items': [
          {
            'package_id': 101,
            'package_name': 'باقة النخبة',
            'package_color': '#FF5500',
            'package_voucher_count': 50,
            'voucher_count': 200,
            'unit_price': 100.0,
            'discount_rate': 10.0,
            'effective_price': 90.0,
            'line_gross_total': 20000.0,
            'line_discount_amount': 2000.0,
            'line_net_total': 18000.0,
            'is_custom_discount': true,
            'pricing_token': 'item_token_101',
          }
        ],
      };

      final model = ProcurementQuoteModel.fromJson(json);

      expect(model.networkId, 10);
      expect(model.posId, 20);
      expect(model.saleType, SaleType.cash);
      expect(model.grossTotal, 20000.0);
      expect(model.discountTotal, 2000.0);
      expect(model.netTotal, 18000.0);
      expect(model.pricingToken, 'hmac_sha256_valid_token');
      expect(model.totalDiscountPercentage, 10.0);
      expect(model.items.length, 1);

      final line = model.findLine(101);
      expect(line, isNotNull);
      expect(line!.packageId, 101);
      expect(line.effectivePrice, 90.0);
      expect(line.lineNetTotal, 18000.0);
      expect(line.isCustomDiscount, isTrue);

      final outJson = model.toJson();
      expect(outJson['gross_total'], 20000.0);
      expect(outJson['pricing_token'], 'hmac_sha256_valid_token');
    });

    test('GetProcurementQuoteUseCase delegates directly to RequestRepository without alteration', () async {
      final useCase = GetProcurementQuoteUseCase(mockRepo);
      final payload = {'network_id': 10, 'pos_id': 20, 'items': <dynamic>[]};

      final result = await useCase(payload);

      expect(mockRepo.lastQuotePayload, payload);
      expect(result.netTotal, 45000.0);
      expect(result.pricingToken, 'fake_valid_hmac_token');
    });
  });

  group('Phase 3.1: PosProcurementController Server Authoritative Quote Integration', () {
    test('Local estimate uses signed minor-unit price and rounds discount on the line gross', () {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      controller.procurementCart.add(
        ProcurementCartLineEntity(package: testPackage, sheets: 1, voucherCount: 101),
      );

      expect(controller.estimatedLineTotalMinor(testPackage, 101), 909000);
      expect(controller.estimatedProcurementTotalsMinor, (1010000, 101000, 909000));
    });

    test('Changing a cart quantity updates local state without requesting a server quote', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;

      controller.setPackageVoucherCount(testPackage, 500);

      await pumpEventQueue();

      expect(controller.cartQuantityForPackage(testPackage.packageId), 500);
      expect(controller.serverQuote.value, isNull);
      expect(mockRepo.lastQuotePayload, isNull);
    });

    test('Toggling payment method changes local selection without a quote request', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );

      // Change from CASH to CREDIT
      controller.selectedSaleType.value = SaleType.credit;
      await pumpEventQueue();

      expect(controller.selectedSaleType.value, SaleType.credit);
      expect(mockRepo.lastQuotePayload, isNull);
    });

    test('Clearing procurement cart clears serverQuote and quoteError', () async {
      controller.serverQuote.value = const ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 1000,
        discountTotal: 0,
        netTotal: 1000,
        currency: 'YER',
        pricingToken: 'tok',
        items: [],
      );

      controller.clearProcurementCart();

      expect(controller.serverQuote.value, isNull);
      expect(controller.quoteError.value, isNull);
    });

    test('Submission creates the request directly without fetching a quote', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      controller.myPosList.assignAll([testPos]);
      controller.linkedNetworks.assignAll([testLink]);
      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );

      expect(controller.canSubmitOrder, isTrue);
      final submitted = await controller.submitOrder();

      expect(submitted, isTrue);
      expect(mockRepo.lastQuotePayload, isNull);
      expect(mockRepo.lastCreatePayload?['pricing_token'], isNull);
      expect(
        mockRepo.lastCreatePayload?['items']?[0]['pricing_snapshot_token'],
        'signed_snapshot_token_for_package_101',
      );
    });

    test('Submitting order ignores retired quote token and sends each signed snapshot', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      controller.myPosList.assignAll([testPos]);
      controller.linkedNetworks.assignAll([testLink]);

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );

      controller.serverQuote.value = const ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 10000,
        discountTotal: 1000,
        netTotal: 9000,
        currency: 'YER',
        pricingToken: 'retired_quote_token_must_not_be_sent',
        items: [],
      );

      final success = await controller.submitOrder();

      expect(success, isTrue);
      expect(mockRepo.lastQuotePayload, isNull);
      expect(mockRepo.lastCreatePayload!['pricing_token'], isNull);
      expect(mockRepo.lastCreatePayload!['items'][0]['pricing_snapshot_token'], 'signed_snapshot_token_for_package_101');
      expect(mockRepo.createIdempotencyKeys.single, isNotEmpty);
    });

    test('retries reuse the same idempotency key for an unchanged submission', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      controller.myPosList.assignAll([testPos]);
      controller.linkedNetworks.assignAll([testLink]);
      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );
      controller.serverQuote.value = const ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 10000,
        discountTotal: 1000,
        netTotal: 9000,
        currency: 'YER',
        pricingToken: 'stable_retry_token',
        items: [],
      );
      mockRepo.throwOnceOnCreate = true;

      expect(await controller.submitOrder(), isFalse);
      expect(await controller.submitOrder(), isTrue);
      expect(mockRepo.createIdempotencyKeys, hasLength(2));
      expect(
        mockRepo.createIdempotencyKeys[0],
        mockRepo.createIdempotencyKeys[1],
      );
    });

    test('Server price change rejection does not trigger an automatic background quote request', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      controller.myPosList.assignAll([testPos]);
      controller.linkedNetworks.assignAll([testLink]);

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );
      controller.serverQuote.value = const ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 10000,
        discountTotal: 1000,
        netTotal: 9000,
        currency: 'YER',
        pricingToken: 'expired_or_changed_server_token',
        items: [],
      );

      mockRepo.throwPricingOnCreate = true;
      mockRepo.lastQuotePayload = null;

      final success = await controller.submitOrder();

      expect(success, isFalse);
      await pumpEventQueue();

      expect(mockRepo.lastQuotePayload, isNull);
      expect(controller.packageErrorMessage.value, isNotNull);
    });
  });

  group('Phase 3.1: ProcurementFinancialQuoteCard Presentation Widget Tests', () {
    Widget buildTestableWidget(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: AppThemes.light,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('Renders gross total, discount with savings badge, and net total directly from quote', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      controller.serverQuote.value = null;
      controller.quoteError.value = null;
      controller.isLoadingQuote.value = false;

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 5,
          voucherCount: 500,
        ),
      );

      controller.serverQuote.value = const ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 50000.0,
        discountTotal: 5000.0,
        netTotal: 45000.0,
        currency: 'YER',
        pricingToken: 'fake_valid_hmac_token',
        items: [],
      );

      await tester.pumpWidget(buildTestableWidget(const ProcurementFinancialQuoteCard()));
      await tester.pumpAndSettle();

      expect(find.text('عرض الأسعار المعتمد'), findsOneWidget);
      expect(find.text('المجموع الأساسي:'), findsOneWidget);
      expect(find.text('50,000.00 YER'), findsOneWidget);
      expect(find.text('إجمالي الخصم المعتمد:'), findsOneWidget);
      expect(find.text('- 5,000.00 YER'), findsOneWidget);
      expect(find.text('وفر 10.0%'), findsOneWidget);
      expect(find.text('صافي قيمة الطلب:'), findsOneWidget);
      expect(find.text('45,000.00 YER'), findsOneWidget);
    });

    testWidgets('Shows expired quote state and explicit refresh action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      controller.quoteError.value = null;
      controller.isLoadingQuote.value = false;
      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );
      controller.serverQuote.value = ProcurementQuoteEntity(
        networkId: 10,
        posId: 20,
        saleType: SaleType.cash,
        saleTypeLabel: 'نقدي',
        grossTotal: 10000,
        discountTotal: 1000,
        netTotal: 9000,
        currency: 'YER',
        pricingToken: 'expired_quote_token',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        items: const [],
      );

      await tester.pumpWidget(
        buildTestableWidget(const ProcurementFinancialQuoteCard()),
      );
      await tester.pumpAndSettle();

      expect(find.text('انتهت صلاحية عرض السعر'), findsOneWidget);
      expect(find.text('إعادة احتساب السعر'), findsOneWidget);
    });

    testWidgets('Renders loading shimmer/indicator while fetching server quote', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      controller.serverQuote.value = null;
      controller.quoteError.value = null;

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );

      controller.isLoadingQuote.value = true;

      await tester.pumpWidget(buildTestableWidget(const ProcurementFinancialQuoteCard()));
      await tester.pump();

      expect(find.text('جاري احتساب السعر والخصم الفعليين المعتمدين...'), findsOneWidget);
    });

    testWidgets('Renders error state with retry button when quote calculation fails', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      controller.serverQuote.value = null;
      controller.isLoadingQuote.value = false;

      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: testPackage,
          sheets: 1,
          voucherCount: 100,
        ),
      );

      controller.quoteError.value = 'تعذر الاتصال بخدمة التسعير';

      await tester.pumpWidget(buildTestableWidget(const ProcurementFinancialQuoteCard()));
      await tester.pumpAndSettle();

      expect(find.text('تعذر الحصول على عرض الأسعار المعتمد'), findsOneWidget);
      expect(find.text('تعذر الاتصال بخدمة التسعير'), findsOneWidget);
      expect(find.text('إعادة احتساب الأسعار'), findsOneWidget);
    });
  });
}
