import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

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

  group('ProcurementOrderCard & Executive Architecture Tests', () {
    testWidgets('renders party name, UUID, status, and metrics correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCard(
            request: sampleRequest,
            onDetails: () {},
            isNetworkView: true,
            isExpanded: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Displays POS party name in network view
      expect(find.text('نقطة الأمانة للاتصالات'), findsOneWidget);
      expect(find.text('REQ-2026-000010'), findsOneWidget);
      expect(find.byType(CustomStatusBadge), findsWidgets);

      // Verify metrics
      expect(find.text('الباقات'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('عدد الكروت'), findsOneWidget);
      expect(find.text('200 كرت'), findsOneWidget);
      expect(find.text('إجمالي الطلب'), findsOneWidget);
    });

    testWidgets('renders accordion and toggles expansion smoothly', (
      tester,
    ) async {
      bool toggled = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ProcurementOrderCard(
            request: sampleRequest,
            onDetails: () {},
            isExpanded: true,
            onToggleExpand: () => toggled = true,
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

    testWidgets(
      'renders complete ProcurementOrderCard composite using CustomExecutiveTransactionCard',
      (tester) async {
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

        expect(find.byType(CustomExecutiveTransactionCard), findsOneWidget);
      },
    );
  });
}
