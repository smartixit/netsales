import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/operations/domain/entities/request_pricing_preview_entity.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/sales_trend_point_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_sale_invoice_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/delete_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/update_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/request_modifications_comparison_card.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';

class MockOperationsRepo implements OperationsRepository {
  List<Map<String, dynamic>>? lastApproveItems;
  String? lastApproveSaleType;

  @override
  Future<List<SaleInvoiceEntity>> getSaleInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async => [];

  @override
  Future<VoucherRequestEntity> approveVoucherRequest(
    int id, {
    String? notes,
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? idempotencyKey,
  }) async {
    lastApproveItems = items;
    lastApproveSaleType = saleType;
    return VoucherRequestEntity(
      requestId: id,
      networkId: 1,
      posId: 2,
      requestUuid: 'REQ-APPROVED-100',
      saleType: saleType ?? 'CASH',
      saleTypeLabel: saleType == 'CREDIT' ? 'آجل' : 'نقدي',
      requestTotalAmount: 25000.0,
      status: 'APPROVED',
      statusLabel: 'معتمد',
      createdBy: 5,
      invoiceId: 99,
      invoiceUuid: 'INV-99',
      modificationsSummary: {
        'has_modifications': true,
        'original_total': 20000.0,
        'approved_total': 25000.0,
        'original_items_count': 1,
        'approved_items_count': 2,
      },
    );
  }

  @override
  Future<RequestPricingPreviewEntity> previewRequestModification(
    int id, {
    required List<Map<String, dynamic>> items,
    String? saleType,
    String? requestNote,
  }) async {
    return RequestPricingPreviewEntity(
      requestId: id,
      requestUuid: 'REQ-PREVIEW-001',
      originalTotalAmount: 20000.0,
      previewTotalAmount: 25000.0,
      grossTotalAmount: 27000.0,
      totalDiscountAmount: 2000.0,
      saleType: saleType ?? 'CASH',
      saleTypeLabel: saleType == 'CREDIT' ? 'آجل' : 'نقدي',
      hasModifications: true,
      items: [
        const RequestPreviewItemEntity(
          packageId: 10,
          packageName: 'باقة الفرسان 1000',
          voucherCount: 20,
          voucherPrice: 1000.0,
          itemDiscount: 10.0,
          itemTotalAmount: 18000.0,
          grossTotalAmount: 20000.0,
          discountAmount: 2000.0,
          source: 'ORIGINAL',
          changeType: 'UNCHANGED',
          originalVoucherCount: 20,
        ),
        const RequestPreviewItemEntity(
          packageId: 12,
          packageName: 'باقة النجوم 500',
          voucherCount: 15,
          voucherPrice: 500.0,
          itemDiscount: 5.0,
          itemTotalAmount: 7125.0,
          grossTotalAmount: 7500.0,
          discountAmount: 375.0,
          source: 'REVIEW_CAPTURED',
          pricingToken: 'hmac_valid_token_xyz',
          changeType: 'ADDED',
          originalVoucherCount: null,
        ),
      ],
      removedItems: [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPackagesRepo implements PackagesRepository {
  @override
  Future<List<VoucherPackageEntity>> getVoucherPackages({
    int? networkId,
    String? search,
    bool? status,
    int perPage = 20,
    int page = 1,
  }) async {
    return [
      const VoucherPackageEntity(
        packageId: 10,
        networkId: 1,
        packageName: 'باقة الفرسان 1000',
        packageVoucherPrice: 1000.0,
        packageDefaultCashDiscount: 10.0,
        packageDefaultCreditDiscount: 8.0,
        status: true,
      ),
      const VoucherPackageEntity(
        packageId: 12,
        networkId: 1,
        packageName: 'باقة النجوم 500',
        packageVoucherPrice: 500.0,
        packageDefaultCashDiscount: 5.0,
        packageDefaultCreditDiscount: 4.0,
        status: true,
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockOperationsRepo mockOpsRepo;
  late MockPackagesRepo mockPkgRepo;
  late OperationsController controller;

  setUp(() {
    Get.reset();
    mockOpsRepo = MockOperationsRepo();
    mockPkgRepo = MockPackagesRepo();

    controller = OperationsController(
      getSaleInvoicesUseCase: GetSaleInvoicesUseCase(mockOpsRepo),
      getVoucherRequestsUseCase: GetVoucherRequestsUseCase(mockOpsRepo),
      getSaleInvoiceDetailsUseCase: GetSaleInvoiceDetailsUseCase(mockOpsRepo),
      getVoucherRequestDetailsUseCase: GetVoucherRequestDetailsUseCase(mockOpsRepo),
      approveVoucherRequestUseCase: ApproveVoucherRequestUseCase(mockOpsRepo),
      rejectVoucherRequestUseCase: RejectVoucherRequestUseCase(mockOpsRepo),
      cancelVoucherRequestUseCase: CancelVoucherRequestUseCase(mockOpsRepo),
      createVoucherRequestUseCase: CreateVoucherRequestUseCase(mockOpsRepo),
      createSaleInvoiceUseCase: CreateSaleInvoiceUseCase(mockOpsRepo),
      updateVoucherRequestUseCase: UpdateVoucherRequestUseCase(mockOpsRepo),
      deleteVoucherRequestUseCase: DeleteVoucherRequestUseCase(mockOpsRepo),
      previewRequestModificationUseCase:
          PreviewRequestModificationUseCase(mockOpsRepo),
      getVoucherPackagesUseCase: GetVoucherPackagesUseCase(mockPkgRepo),
    );
    Get.put<OperationsController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('OperationsController correctly initializes review flow and fetches preview', () async {
    const dummyReq = VoucherRequestEntity(
      requestId: 55,
      networkId: 1,
      posId: 2,
      requestUuid: 'REQ-UUID-55',
      saleType: 'CASH',
      saleTypeLabel: 'نقدي',
      requestTotalAmount: 20000.0,
      status: 'PENDING',
      statusLabel: 'قيد الانتظار',
      createdBy: 10,
      items: [
        VoucherRequestItemEntity(
          itemId: 1,
          requestId: 55,
          packageId: 10,
          packageName: 'باقة الفرسان 1000',
          voucherPrice: 1000.0,
          voucherCount: 20,
          itemDiscount: 10.0,
          itemTotalAmount: 18000.0,
        ),
      ],
    );

    await controller.initReviewFlow(dummyReq);

    expect(controller.reviewSaleType.value, equals('CASH'));
    expect(controller.pricingPreview.value, isNotNull);
    expect(controller.pricingPreview.value?.previewTotalAmount, equals(25000.0));
    expect(controller.pricingPreview.value?.items.length, equals(2));
    expect(controller.pricingPreview.value?.items.first.source, equals('ORIGINAL'));
    expect(controller.pricingPreview.value?.items.last.source, equals('REVIEW_CAPTURED'));
    expect(controller.pricingPreview.value?.items.last.pricingToken, equals('hmac_valid_token_xyz'));
  });

  test('Submitting approval passes items and HMAC token to approve use case', () async {
    const dummyReq = VoucherRequestEntity(
      requestId: 55,
      networkId: 1,
      posId: 2,
      requestUuid: 'REQ-UUID-55',
      saleType: 'CASH',
      saleTypeLabel: 'نقدي',
      requestTotalAmount: 20000.0,
      status: 'PENDING',
      statusLabel: 'قيد الانتظار',
      createdBy: 10,
      items: [
        VoucherRequestItemEntity(
          itemId: 1,
          requestId: 55,
          packageId: 10,
          packageName: 'باقة الفرسان 1000',
          voucherPrice: 1000.0,
          voucherCount: 20,
          itemDiscount: 10.0,
          itemTotalAmount: 18000.0,
        ),
      ],
    );

    await controller.initReviewFlow(dummyReq);
    final success = await controller.submitApprovalWithModifications(55);

    expect(success, isTrue);
    expect(mockOpsRepo.lastApproveSaleType, equals('CASH'));
    expect(mockOpsRepo.lastApproveItems, isNotNull);
    expect(mockOpsRepo.lastApproveItems?.length, equals(1));
  });

  testWidgets('RequestModificationsComparisonCard renders modified request differences accurately',
      (tester) async {
    final modifiedReq = const VoucherRequestEntity(
      requestId: 77,
      networkId: 1,
      posId: 2,
      requestUuid: 'REQ-MOD-77',
      saleType: 'CASH',
      saleTypeLabel: 'نقدي',
      requestTotalAmount: 20000.0,
      status: 'APPROVED',
      statusLabel: 'معتمد',
      createdBy: 5,
      invoiceId: 101,
      invoiceUuid: 'INV-101',
      modificationsSummary: {
        'has_modifications': true,
        'original_total': 20000.0,
        'approved_total': 24500.0,
        'original_items_count': 2,
        'approved_items_count': 3,
      },
      items: [
        VoucherRequestItemEntity(
          itemId: 1,
          requestId: 77,
          packageId: 10,
          packageName: 'باقة الفرسان 1000',
          voucherPrice: 1000.0,
          voucherCount: 20,
          itemDiscount: 10.0,
          itemTotalAmount: 18000.0,
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => GetMaterialApp(
          theme: AppThemes.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RequestModificationsComparisonCard(
                request: modifiedReq,
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مطابقة الطلب مع الفاتورة المعتمدة'), findsOneWidget);
    expect(find.text('تم التعديل عند الاعتماد'), findsOneWidget);
    expect(find.textContaining('الطلب الأصلي المقدم'), findsOneWidget);
    expect(find.textContaining('الفاتورة المعتمدة النهائية'), findsOneWidget);
    expect(find.textContaining('20,000'), findsOneWidget);
    expect(find.textContaining('24,500'), findsOneWidget);
  });
}
