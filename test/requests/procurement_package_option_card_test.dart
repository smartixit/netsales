import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';

PackageEntity createPackage({bool hasPosCustomDiscount = false}) {
  return PackageEntity(
    packageId: 101,
    networkId: 10,
    packageName: 'باقة الاختبار',
    packageBalance: 2048,
    packageUptime: 120,
    packageValidity: 24,
    packageVoucherCount: 100,
    packageVoucherPrice: 100,
    packageDefaultCashDiscount: 10,
    packageDefaultCreditDiscount: 5,
    cashDiscountAmount: 10,
    creditDiscountAmount: 5,
    effectiveCashPrice: 90,
    effectiveCreditPrice: 95,
    status: true,
    procurementBaseUnitPriceMinor: 10000,
    procurementCashUnitPriceMinor: 9000,
    procurementCreditUnitPriceMinor: 9500,
    procurementCashDiscountBasisPoints: 1000,
    procurementCreditDiscountBasisPoints: 500,
    procurementPricingSnapshotToken: 'signed-snapshot-token',
    procurementPricingSnapshotExpiresAt: DateTime(2099),
    procurementIsCustomDiscount: hasPosCustomDiscount,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TextEditingController quantityController;

  setUp(() {
    quantityController = TextEditingController();
  });

  tearDown(() {
    quantityController.dispose();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    bool isDark = false,
    bool hasPosCustomDiscount = false,
    EffectivePackageDiscountEntity? customDiscount,
    Size viewport = const Size(360, 780),
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ProcurementPackageOptionCard(
                  package: createPackage(
                    hasPosCustomDiscount: hasPosCustomDiscount,
                  ),
                  quantity: 0,
                  onSetQuantity: (_) {},
                  isCashSale: true,
                  quantityController: quantityController,
                  customDiscount: customDiscount,
                  estimatedLineTotalMinor: 900000,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows balance with validity and duration, and sheet capacity under title',
    (tester) async {
      await pumpCard(tester);

      expect(find.text('الرصيد'), findsOneWidget);
      expect(find.text('2 جيجابايت'), findsOneWidget);
      expect(find.text('الصلاحية'), findsOneWidget);
      expect(find.text('المدة'), findsOneWidget);
      expect(find.text('السعة'), findsNothing);
      expect(find.text('سعة الورقة: 100 كرت'), findsOneWidget);
      expect(find.text('الكمية المطلوبة'), findsOneWidget);
      expect(find.text('ورقة'), findsOneWidget);
      expect(find.text('نصف'), findsOneWidget);
      expect(find.text('تصفير'), findsOneWidget);

      final basePriceTop = tester
          .getTopLeft(find.text('السعر الأساسي قبل الخصم'))
          .dy;
      final cashPriceTop = tester.getTopLeft(find.text('السعر النقدي')).dy;
      expect(basePriceTop, lessThan(cashPriceTop));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('marks a custom pricing snapshot as a POS-specific discount', (
    tester,
  ) async {
    await pumpCard(tester, hasPosCustomDiscount: true);

    expect(find.text('خصم خاص'), findsOneWidget);
    expect(find.text('خصم افتراضي'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not infer POS badge from a separate discount response', (
    tester,
  ) async {
    final separateDiscount = EffectivePackageDiscountEntity(
      discountCash: 10,
      discountCredit: 5,
      isCustom: true,
      originalPackagePrice: 100,
      effectiveCashPrice: 90,
      effectiveCreditPrice: 95,
      cashSavings: 10,
      creditSavings: 5,
    );

    await pumpCard(tester, customDiscount: separateDiscount);

    expect(find.text('خصم افتراضي'), findsOneWidget);
    expect(find.text('خصم خاص'), findsNothing);
  });

  testWidgets('keeps the card valid in dark mode on a narrow phone viewport', (
    tester,
  ) async {
    await pumpCard(
      tester,
      isDark: true,
      hasPosCustomDiscount: true,
      viewport: const Size(320, 760),
    );

    expect(find.text('الرصيد'), findsOneWidget);
    expect(find.text('سعة الورقة: 100 كرت'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the card valid on a tablet-width viewport', (
    tester,
  ) async {
    await pumpCard(tester, viewport: const Size(820, 1180));

    expect(find.text('السعر الأساسي قبل الخصم'), findsOneWidget);
    expect(find.text('السعر النقدي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
