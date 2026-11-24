import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';

class FakeInvoiceRepository implements InvoiceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRequestRepository implements RequestRepository {

  @override
  Future<RequestStatusSummaryEntity> getRequestStatusSummary({
    int? networkId,
    int? posId,
  }) async {
    return RequestStatusSummaryEntity.empty;
  }

  @override
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
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
    List<int>? packageIds,
  }) async => const PaginatedList(items: [], nextCursor: null);

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
  ) async => throw UnimplementedError();

  @override
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
    double? paidAmount,
  }) async => throw UnimplementedError();

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async => throw UnimplementedError();

  @override
  Future<RequestEntity> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async => throw UnimplementedError();

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
  packageBalance: 1000,
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
PackageEntity _expiredTestPackage() => PackageEntity(
  packageId: testPackage.packageId,
  networkId: testPackage.networkId,
  packageName: testPackage.packageName,
  packageBalance: testPackage.packageBalance,
  packageVoucherPrice: testPackage.packageVoucherPrice,
  packageVoucherCount: testPackage.packageVoucherCount,
  packageDefaultCashDiscount: testPackage.packageDefaultCashDiscount,
  packageDefaultCreditDiscount: testPackage.packageDefaultCreditDiscount,
  cashDiscountAmount: testPackage.cashDiscountAmount,
  creditDiscountAmount: testPackage.creditDiscountAmount,
  effectiveCashPrice: testPackage.effectiveCashPrice,
  effectiveCreditPrice: testPackage.effectiveCreditPrice,
  status: true,
  procurementBaseUnitPriceMinor: 10000,
  procurementCashUnitPriceMinor: 9000,
  procurementCreditUnitPriceMinor: 9500,
  procurementCashDiscountBasisPoints: 1000,
  procurementCreditDiscountBasisPoints: 500,
  procurementPricingSnapshotToken: 'expired_snapshot_token',
  procurementPricingSnapshotExpiresAt: DateTime(2020),
);

class FakeCommercialRepository implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<PosEntity>> getMyPos() async => [testPos];

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async => PaginatedList(items: [testLink], nextCursor: null);
}

class FakePackageCatalogRepository implements PackageCatalogRepository {
  List<PackageEntity>? refreshedPackages;
  List<int>? lastRequestedPackageIds;
  bool throwOnPackageRefresh = false;

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
    List<int>? packageIds,
  }) async {
    if (packageIds != null) {
      lastRequestedPackageIds = List<int>.of(packageIds);
      if (throwOnPackageRefresh) {
        throw const AppException('تعذر تحديث التعرفة', code: '500');
      }
      return PaginatedList(
        items: refreshedPackages ?? [testPackage],
        nextCursor: null,
      );
    }

    return PaginatedList(items: [testPackage], nextCursor: null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRequestRepository mockRepo;
  late FakeCommercialRepository commercialRepo;
  late FakePackageCatalogRepository packageRepo;
  late PosNewProcurementOrderController controller;

  setUp(() {
    Get.reset();
    mockRepo = FakeRequestRepository();
    commercialRepo = FakeCommercialRepository();
    packageRepo = FakePackageCatalogRepository();

    controller = PosNewProcurementOrderController(
      createRequestUseCase: CreateRequestUseCase(mockRepo),
      getMyPosUseCase: GetMyPosUseCase(commercialRepo),
      getPosNetworksListUseCase: GetPosNetworksListUseCase(commercialRepo),
      getPackagesUseCase: GetPackagesUseCase(packageRepo),
    );
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  test('Refreshing expired cart pricing replaces snapshots and preserves quantities', () async {
    controller.selectedNetworkId.value = 10;
    controller.selectedPosId.value = 20;
    controller.myPosList.assignAll([testPos]);
    controller.linkedNetworks.assignAll([testLink]);

    final expiredPackage = _expiredTestPackage();
    packageRepo.refreshedPackages = [testPackage];
    controller.procurementCart.add(
      ProcurementCartLineEntity(
        package: expiredPackage,
        sheets: 2.5,
        voucherCount: 250,
      ),
    );

    expect(controller.hasCurrentProcurementSnapshots, isFalse);
    expect(controller.needsPricingRefresh, isTrue);
    expect(controller.estimatedLineTotalMinor(expiredPackage, 250), 2250000);
    expect(controller.checkoutGrossAmount, 25000.0);
    expect(controller.checkoutDiscountAmount, 2500.0);
    expect(controller.checkoutNetAmount, 22500.0);

    await controller.refreshNetworkPackages();

    expect(packageRepo.lastRequestedPackageIds, [testPackage.packageId]);
    expect(controller.procurementCart, hasLength(1));
    expect(
      controller.procurementCart.single.package.procurementPricingSnapshotToken,
      testPackage.procurementPricingSnapshotToken,
    );
    expect(controller.procurementCart.single.voucherCount, 250);
    expect(controller.procurementCart.single.sheets, 2.5);
    expect(controller.hasCurrentProcurementSnapshots, isTrue);
    expect(controller.estimatedProcurementTotalsMinor, isNotNull);
    expect(controller.isRefreshingCartPricing.value, isFalse);
  });

  test('Continuing to review does not refresh or replace the local estimate', () {
    controller.selectedNetworkId.value = 10;
    controller.selectedPosId.value = 20;
    controller.procurementCart.add(
      ProcurementCartLineEntity(
        package: _expiredTestPackage(),
        sheets: 2.5,
        voucherCount: 250,
      ),
    );

    controller.continueToOrderReview();

    expect(controller.currentOrderStep.value, 1);
    expect(packageRepo.lastRequestedPackageIds, isNull);
    expect(controller.checkoutNetAmount, 22500.0);
  });

  test(
    'Incomplete cart tariff refresh keeps expired snapshots and quantities',
    () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;
      packageRepo.refreshedPackages = [];
      final expiredPackage = _expiredTestPackage();
      controller.procurementCart.add(
        ProcurementCartLineEntity(
          package: expiredPackage,
          sheets: 2.5,
          voucherCount: 250,
        ),
      );

      await controller.refreshNetworkPackages();

      expect(
        controller
            .procurementCart
            .single
            .package
            .procurementPricingSnapshotToken,
        expiredPackage.procurementPricingSnapshotToken,
      );
      expect(controller.procurementCart.single.voucherCount, 250);
      expect(controller.hasCurrentProcurementSnapshots, isFalse);
      expect(controller.estimatedProcurementTotalsMinor, (2500000, 250000, 2250000));
      expect(controller.checkoutGrossAmount, 25000.0);
      expect(controller.checkoutDiscountAmount, 2500.0);
      expect(controller.checkoutNetAmount, 22500.0);
      expect(controller.cartPricingRefreshError.value, isNotNull);
      expect(controller.isRefreshingCartPricing.value, isFalse);
    },
  );

  test('Direct invoice checkout calculates discounts locally and keeps the fixed currency', () {
    final invoiceController = NetworkDirectInvoiceController(
      createDirectSaleInvoiceUseCase: CreateDirectSaleInvoiceUseCase(
        FakeInvoiceRepository(),
      ),
    );

    invoiceController.setPackageVoucherCount(testPackage, 500);

    expect(invoiceController.checkoutCurrency, 'ر.ي');
    expect(invoiceController.checkoutGrossAmount, 50000.0);
    expect(invoiceController.checkoutDiscountAmount, 5000.0);
    expect(invoiceController.checkoutNetAmount, 45000.0);

    invoiceController.selectedSaleType.value = SaleType.credit;

    expect(invoiceController.checkoutCurrency, 'ر.ي');
    expect(invoiceController.checkoutGrossAmount, 50000.0);
    expect(invoiceController.checkoutDiscountAmount, 2500.0);
    expect(invoiceController.checkoutNetAmount, 47500.0);

    invoiceController.setPackageVoucherCount(testPackage, 250);
    expect(invoiceController.checkoutGrossAmount, 25000.0);
    expect(invoiceController.checkoutDiscountAmount, 1250.0);
    expect(invoiceController.checkoutNetAmount, 23750.0);

    invoiceController.paidAmount.value = 10000.0;
    expect(invoiceController.checkoutPaidAmount, 10000.0);
    expect(invoiceController.checkoutRemainingCreditAmount, 13750.0);

    invoiceController.setPackageVoucherCount(testPackage, 0);
    expect(invoiceController.directInvoiceCart, isEmpty);
    expect(invoiceController.checkoutNetAmount, 0.0);

    invoiceController.onClose();
  });

  group('Local checkout calculation', () {
    test('Checkout values are calculated locally and use the fixed Yemeni rial label', () async {
      controller.selectedNetworkId.value = 10;
      controller.selectedPosId.value = 20;

      controller.setPackageVoucherCount(testPackage, 500);
      expect(packageRepo.lastRequestedPackageIds, isNull);

      expect(controller.checkoutCurrency, 'ر.ي');
      expect(controller.checkoutGrossAmount, 50000.0);
      expect(controller.checkoutDiscountAmount, 5000.0);
      expect(controller.checkoutNetAmount, 45000.0);

      controller.setPackageVoucherCount(testPackage, 250);
      expect(controller.checkoutGrossAmount, 25000.0);
      expect(controller.checkoutDiscountAmount, 2500.0);
      expect(controller.checkoutNetAmount, 22500.0);

      controller.selectedSaleType.value = SaleType.credit;

      expect(controller.checkoutCurrency, 'ر.ي');
      expect(controller.checkoutGrossAmount, 25000.0);
      expect(controller.checkoutDiscountAmount, 1250.0);
      expect(controller.checkoutNetAmount, 23750.0);

      controller.setPackageVoucherCount(testPackage, 0);
      expect(controller.procurementCart, isEmpty);
      expect(controller.checkoutGrossAmount, 0.0);
      expect(controller.checkoutDiscountAmount, 0.0);
      expect(controller.checkoutNetAmount, 0.0);
    });
  });


}
