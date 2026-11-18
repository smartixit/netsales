import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_accordion.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_header.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_metrics_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_strip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  Widget wrapWithTheme(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => GetMaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  const samplePackage = PackageEntity(
    packageId: 101,
    networkId: 1,
    packageName: 'باقة الفخامة الذهبية',
    packageColor: '#087F68',
    packageBalance: 1024,
    packageValidity: 30,
    packageUptime: 24,
    packageVoucherCount: 100,
    packageVoucherPrice: 500.0,
    packageDefaultCashDiscount: 10.0,
    packageDefaultCreditDiscount: 5.0,
    cashDiscountAmount: 50.0,
    creditDiscountAmount: 25.0,
    effectiveCashPrice: 450.0,
    effectiveCreditPrice: 475.0,
    status: true,
  );

  const sampleItem = RequestItemEntity(
    itemId: 1,
    requestId: 10,
    packageId: 101,
    voucherPrice: 500.0,
    voucherCount: 200,
    itemDiscount: 50.0,
    itemTotalAmount: 95000.0,
    voucherPackage: samplePackage,
  );

  final sampleRequest = RequestEntity(
    requestId: 10,
    networkId: 1,
    posId: 2,
    requestUuid: 'REQ-2026-000010',
    saleTypeRaw: 'CASH',
    saleTypeLabel: 'نقدي',
    requestTotalAmount: 95000.0,
    requestDate: '2026-11-18 12:00:00',
    statusRaw: 'PENDING',
    statusLabel: 'قيد الانتظار',
    networkName: 'شبكة النخبة الرقمية',
    networkLogo: 'https://example.com/network.png',
    posName: 'نقطة الأمانة للاتصالات',
    posLogo: null,
    createdByName: 'أحمد التاجر',
    reviewedByName: 'محمد المشرف',
    items: [sampleItem],
  );

  group('ProcurementOrdersSummaryStrip Tests', () {
    testWidgets('renders all 5 status summary cards with counts', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? tappedStatus;

      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrdersSummaryStrip(
            totalCount: 45,
            pendingCount: 12,
            approvedCount: 25,
            rejectedCount: 5,
            cancelledCount: 3,
            selectedStatus: 'PENDING',
            onStatusTap: (status) => tappedStatus = status,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إجمالي الطلبات'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('قيد المراجعة'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('معتمدة'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('مرفوضة'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('ملغية'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Tap on 'معتمدة' card
      await tester.ensureVisible(find.text('معتمدة'));
      await tester.tap(find.text('معتمدة'));
      await tester.pumpAndSettle();
      expect(tappedStatus, equals('APPROVED'));
    });
  });

  group('ProcurementOrderCard & Sub-widgets Tests', () {
    testWidgets('renders header with avatar badge, UUID, and date', (
      tester,
    ) async {
      final status = EnumPresentationRegistry.resolveRequestStatus(
        sampleRequest.status,
      );
      final saleType = EnumPresentationRegistry.resolveSaleType(
        sampleRequest.saleType,
      );

      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCardHeader(
            request: sampleRequest,
            status: status,
            saleType: saleType,
            isNetworkView: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Displays POS party name in network view
      expect(find.text('نقطة الأمانة للاتصالات'), findsOneWidget);
      expect(find.byType(CustomAvatarBadge), findsOneWidget);
      expect(find.text('REQ-2026-000010'), findsOneWidget);
      expect(find.byType(CustomStatusBadge), findsWidgets);
    });

    testWidgets('renders metrics bar with 3 columns and FittedBox', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProcurementOrderCardMetricsBar(
            itemCount: 2,
            totalQuantity: 350,
            totalAmount: 145000.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الباقات'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('عدد الكروت'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('إجمالي الطلب'), findsOneWidget);
    });

    testWidgets('renders accordion and toggles expansion smoothly', (
      tester,
    ) async {
      bool toggled = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCardAccordion(
            request: sampleRequest,
            packages: [samplePackage],
            isExpanded: true,
            onToggle: () => toggled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('باقة الفخامة الذهبية'), findsWidgets);
      expect(find.text('إخفاء البنود'), findsOneWidget);

      await tester.tap(find.text('إخفاء البنود'));
      expect(toggled, isTrue);
    });

    testWidgets('renders actions bar with POS buttons and triggers details', (
      tester,
    ) async {
      bool detailsCalled = false;
      bool editCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCardActions(
            request: sampleRequest,
            isNetworkView: false,
            onDetails: () => detailsCalled = true,
            onEdit: () => editCalled = true,
            onCancel: () => cancelCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('عرض التفاصيل'), findsOneWidget);
      await tester.tap(find.text('عرض التفاصيل'));
      expect(detailsCalled, isTrue);

      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit_note_rounded));
      expect(editCalled, isTrue);

      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.cancel_outlined));
      expect(cancelCalled, isTrue);
    });

    testWidgets('renders complete ProcurementOrderCard composite', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCard(
            request: sampleRequest,
            onDetails: () {},
            isExpanded: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProcurementOrderCardHeader), findsOneWidget);
      expect(find.byType(ProcurementOrderCardAccordion), findsOneWidget);
      expect(find.byType(ProcurementOrderCardMetricsBar), findsOneWidget);
      expect(find.byType(ProcurementOrderCardActions), findsOneWidget);
    });
  });
}
