import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_sale_invoice_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_kpi_summary_strip.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_search_and_filter_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_segmented_header.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoice_ledger_tile.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoices_feed.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_requests_feed.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/invoice_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/pos_agent_selector_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/request_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_request_ledger_tile.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';

class FakeOperationsRepository implements OperationsRepository {
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
  Future<SaleInvoiceEntity> getSaleInvoiceDetails(int id) =>
      throw UnimplementedError();

  @override
  Future<List<VoucherRequestEntity>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async => [];

  @override
  Future<VoucherRequestEntity> getVoucherRequestDetails(int id) =>
      throw UnimplementedError();

  @override
  Future<VoucherRequestEntity> approveVoucherRequest(int id, {String? notes}) =>
      throw UnimplementedError();

  @override
  Future<VoucherRequestEntity> rejectVoucherRequest(
    int id, {
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<VoucherRequestEntity> cancelVoucherRequest(int id) =>
      throw UnimplementedError();

  @override
  Future<VoucherRequestEntity> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  }) => throw UnimplementedError();

  @override
  Future<SaleInvoiceEntity> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  }) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyInvoice = SaleInvoiceEntity(
    invoiceId: 101,
    networkId: 1,
    posId: 202,
    invoiceUuid: 'INV-2026-X99201',
    saleType: 'CREDIT',
    saleTypeLabel: 'آجل',
    invoiceTotalAmount: 185000.0,
    paidAmount: 50000.0,
    remainingAmount: 135000.0,
    paymentStatus: 'PARTIAL',
    paymentStatusLabel: 'مسددة جزئياً',
    isFullyPaid: false,
    createdBy: 1,
    posName: 'مركز الأمل للاتصالات ونقاط البيع السريعة',
    posCode: 'POS-042',
    networkName: 'شبكة النورس',
    createdAt: '2026-10-27 14:30:00',
    items: [
      SaleInvoiceItemEntity(
        itemId: 1,
        invoiceId: 101,
        packageId: 1,
        voucherCount: 50,
        voucherPrice: 1000.0,
        itemDiscount: 10.0,
        itemTotalAmount: 45000.0,
      ),
    ],
  );

  const dummyRequest = VoucherRequestEntity(
    requestId: 301,
    networkId: 1,
    posId: 202,
    requestUuid: 'REQ-2026-T77102',
    saleType: 'CASH',
    saleTypeLabel: 'نقدي',
    requestTotalAmount: 125000.0,
    status: 'PENDING',
    statusLabel: 'قيد المراجعة',
    createdBy: 1,
    posName: 'نقطة بيع الصقر الذهبي لخدمات الإنترنت المحدودة',
    posCode: 'POS-089',
    networkName: 'شبكة النورس',
    createdAt: '2026-10-27 12:15:00',
    items: [
      VoucherRequestItemEntity(
        itemId: 1,
        requestId: 301,
        packageId: 1,
        voucherCount: 100,
        voucherPrice: 500.0,
        itemDiscount: 5.0,
        itemTotalAmount: 47500.0,
      ),
    ],
  );

  const dummyPackage = VoucherPackageEntity(
    packageId: 1,
    networkId: 1,
    packageName: 'باقة الفرسان الذهبية 15 جيجا غير محدودة',
    packageVoucherPrice: 1500.0,
    packageDefaultCashDiscount: 15.0,
    packageDefaultCreditDiscount: 8.0,
    status: true,
  );

  late OperationsController controller;

  setUp(() {
    Get.reset();
    final repo = FakeOperationsRepository();
    controller = OperationsController(
      getSaleInvoicesUseCase: GetSaleInvoicesUseCase(repo),
      getVoucherRequestsUseCase: GetVoucherRequestsUseCase(repo),
      getSaleInvoiceDetailsUseCase: GetSaleInvoiceDetailsUseCase(repo),
      getVoucherRequestDetailsUseCase: GetVoucherRequestDetailsUseCase(repo),
      approveVoucherRequestUseCase: ApproveVoucherRequestUseCase(repo),
      rejectVoucherRequestUseCase: RejectVoucherRequestUseCase(repo),
      cancelVoucherRequestUseCase: CancelVoucherRequestUseCase(repo),
      createVoucherRequestUseCase: CreateVoucherRequestUseCase(repo),
      createSaleInvoiceUseCase: CreateSaleInvoiceUseCase(repo),
    );
    controller.invoices.assignAll([dummyInvoice]);
    controller.requests.assignAll([dummyRequest]);
    Get.put<OperationsController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createHarness({
    required Widget child,
    required Size screenSize,
    ThemeData? theme,
  }) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => GetMaterialApp(
          theme: theme ?? AppThemes.light,
          home: Scaffold(
            body: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('Operations Tab - Responsive & Multi-Screen Cross Validation', () {
    final screenSizes = <String, Size>{
      'Compact Mobile (320px)': const Size(320, 568),
      'Standard Mobile (375px)': const Size(375, 812),
      'Large Mobile (412px)': const Size(412, 915),
      'Tablet Device (768px)': const Size(768, 1024),
    };

    for (final entry in screenSizes.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets(
        'OperationsSegmentedHeader renders with zero overflow on $name',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createHarness(
              screenSize: size,
              child: OperationsSegmentedHeader(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('فواتير المبيعات'), findsOneWidget);
          expect(find.text('طلبات التوريد'), findsOneWidget);
        },
      );

      testWidgets(
        'OperationsKpiSummaryStrip renders cleanly on $name without clipping',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createHarness(
              screenSize: size,
              child: OperationsKpiSummaryStrip(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'SaleInvoiceLedgerTile renders long texts & large amounts on $name',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createHarness(
              screenSize: size,
              child: SaleInvoiceLedgerTile(invoice: dummyInvoice, onTap: () {}),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text(dummyInvoice.posName!), findsOneWidget);
        },
      );

      testWidgets(
        'VoucherRequestLedgerTile renders status badges & action controls on $name',
        (tester) async {
          tester.view.physicalSize = Size(size.width * 2, size.height * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createHarness(
              screenSize: size,
              child: VoucherRequestLedgerTile(
                request: dummyRequest,
                onTap: () {},
                onApprove: () {},
                onReject: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text(dummyRequest.posName!), findsOneWidget);
        },
      );
    }
  });

  group('Operations Bottom Sheets Components - Stress & Multi-Screen Tests', () {
    testWidgets(
      'PackageSelectionCard handles rapid increment and preset additions',
      (tester) async {
        tester.view.physicalSize = const Size(720, 1400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        int qty = 0;
        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(360, 700),
            child: StatefulBuilder(
              builder: (context, setState) {
                return PackageSelectionCard(
                  package: dummyPackage,
                  quantity: qty,
                  discountPercent: 10,
                  onIncrement: () => setState(() => qty++),
                  onDecrement: () =>
                      setState(() => qty = qty > 0 ? qty - 1 : 0),
                  onAddPreset: (p) => setState(() => qty += p),
                  onSetQuantity: (q) => setState(() => qty = q),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Tap 'تحديد كمية' to activate selection
        await tester.tap(find.text('تحديد كمية'));
        await tester.pumpAndSettle();
        expect(qty, equals(1));

        // Tap preset chip 'ورقة (51)'
        await tester.tap(find.text('ورقة (51)'));
        await tester.pumpAndSettle();
        expect(qty, equals(51));
        expect(find.text('51'), findsOneWidget);
      },
    );

    testWidgets(
      'InvoiceFinancialSummaryCard renders without overflow on 320px',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1200);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(320, 600),
            child: const InvoiceFinancialSummaryCard(
              voucherCount: 250,
              grossAmount: 375000.0,
              discountAmount: 37500.0,
              netAmount: 337500.0,
              paidAmount: 100000.0,
              remainingDebt: 237500.0,
              saleType: 'CREDIT',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'RequestFinancialSummaryCard renders without overflow on 320px',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1200);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(320, 600),
            child: const RequestFinancialSummaryCard(
              voucherCount: 150,
              grossAmount: 225000.0,
              discountAmount: 22500.0,
              netAmount: 202500.0,
              saleType: 'CASH',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('SheetActionDock renders without overflow on 320px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 1200);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        createHarness(
          screenSize: const Size(320, 600),
          child: SheetActionDock(
            totalCount: 250,
            netAmount: 337500.0,
            actionLabel: 'إصدار الفاتورة والتسوية',
            actionIcon: Icons.check_circle_rounded,
            onAction: () {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'OperationsSaleTypeBar toggles between CASH and CREDIT cleanly',
      (tester) async {
        String selectedType = 'CASH';

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(320, 500),
            child: StatefulBuilder(
              builder: (context, setState) {
                return OperationsSaleTypeBar(
                  selectedSaleType: selectedType,
                  onChanged: (newType) =>
                      setState(() => selectedType = newType),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('بيع نقدي'), findsOneWidget);

        await tester.tap(find.text('بيع آجل'));
        await tester.pumpAndSettle();
        expect(selectedType, equals('CREDIT'));
      },
    );

    testWidgets(
      'PosAgentSelectorCard in preselected and dropdown modes on 320px',
      (tester) async {
        final notifier = ValueNotifier<int?>(null);

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(320, 500),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Preselected Mode
                  PosAgentSelectorCard(
                    posIdNotifier: ValueNotifier<int?>(202),
                    selectedPosName: 'وكالة النصر لخدمات التقنية',
                    linkedPosList: const [],
                    isPreselected: true,
                    onPosSelected: (_) {},
                  ),
                  const SizedBox(height: 16),
                  // Dropdown Selection Mode
                  PosAgentSelectorCard(
                    posIdNotifier: notifier,
                    selectedPosName: null,
                    linkedPosList: const [
                      NetworkPosEntity(
                        networkPosId: 1,
                        networkId: 1,
                        posId: 202,
                        posName: 'وكالة النصر لخدمات التقنية',
                        status: true,
                      ),
                    ],
                    isPreselected: false,
                    onPosSelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('الوكيل / نقطة البيع المحددة'), findsOneWidget);
        expect(find.text('سياق مثبت'), findsOneWidget);
      },
    );

    testWidgets(
      'OperationsSearchAndFilterBar renders compact without overflow on 320px',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(320, 500),
            child: OperationsSearchAndFilterBar(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('ابحث برقم الفاتورة، نقطة البيع، أو المرجع...'),
          findsOneWidget,
        );
        expect(find.text('مبيعات نقدية'), findsOneWidget);
      },
    );

    testWidgets(
      'SaleInvoicesFeed displays CustomSkeletonFeed when isLoadingInvoices is true',
      (tester) async {
        controller.isLoadingInvoices.value = true;

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(375, 600),
            child: SaleInvoicesFeed(controller: controller),
          ),
        );
        await tester.pump();

        expect(find.byType(CustomSkeletonFeed), findsOneWidget);
        expect(tester.takeException(), isNull);

        controller.isLoadingInvoices.value = false;
      },
    );

    testWidgets(
      'VoucherRequestsFeed displays CustomSkeletonFeed when isLoadingRequests is true',
      (tester) async {
        controller.isLoadingRequests.value = true;

        await tester.pumpWidget(
          createHarness(
            screenSize: const Size(375, 600),
            child: const VoucherRequestsFeed(),
          ),
        );
        await tester.pump();

        expect(find.byType(CustomSkeletonFeed), findsOneWidget);
        expect(tester.takeException(), isNull);

        controller.isLoadingRequests.value = false;
      },
    );
  });
}
