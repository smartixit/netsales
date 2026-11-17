import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_order_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const package = PackageEntity(
    packageId: 10,
    networkId: 2,
    packageName: 'باقة 100 كرت',
    packageColor: '0xFF6A1B9A',
    packageBalance: 1,
    packageVoucherCount: 100,
    packageVoucherPrice: 1000,
    packageDefaultCashDiscount: 0,
    packageDefaultCreditDiscount: 0,
    cashDiscountAmount: 0,
    creditDiscountAmount: 0,
    effectiveCashPrice: 1000,
    effectiveCreditPrice: 1000,
    status: true,
  );

  const request = RequestEntity(
    requestId: 10582,
    requestUuid: 'REQ-10582',
    networkId: 2,
    posId: 4,
    saleTypeRaw: 'CASH',
    saleTypeLabel: 'نقدي',
    requestTotalAmount: 3000,
    requestDate: '2026-11-17 10:30:00',
    statusRaw: 'PENDING',
    statusLabel: 'قيد المراجعة',
    items: [
      RequestItemEntity(
        itemId: 1,
        requestId: 10582,
        packageId: 10,
        voucherPrice: 1000,
        voucherCount: 300,
        itemTotalAmount: 3000,
        voucherPackage: package,
      ),
    ],
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    bool isDark = false,
    Size viewport = const Size(375, 820),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: isDark ? AppThemes.dark : AppThemes.light,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: PosProcurementOrderCard(
                  request: request,
                  onDetails: () {},
                  onEdit: () {},
                  onCancel: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders reference hierarchy and authoritative request fields', (tester) async {
    await pumpCard(tester);

    expect(find.text('طلب توريد #10582'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(find.text('1 باقة'), findsOneWidget);
    expect(find.text('300 وحدة'), findsOneWidget);
    expect(find.text('عدد البنود'), findsOneWidget);
    expect(find.text('إجمالي الكمية'), findsOneWidget);
    expect(find.text('نوع السعر'), findsOneWidget);
    expect(find.text('نقدي'), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders package color accent and remains valid in dark narrow RTL', (tester) async {
    await pumpCard(
      tester,
      isDark: true,
      viewport: const Size(320, 760),
    );

    expect(find.byKey(const ValueKey('pos-order-package-color-accent')), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
