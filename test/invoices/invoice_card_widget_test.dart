import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';

void main() {
  const sampleItem = InvoiceItemEntity(
    itemId: 1,
    invoiceId: 10,
    packageId: 5,
    packageName: 'باقة النخبة 10 جيجا',
    packageColor: '#10B981',
    voucherPrice: 500.0,
    voucherCount: 77,
    sheetSize: 51,
    itemTotalAmount: 38500.0,
  );

  const sampleInvoice = InvoiceEntity(
    invoiceId: 10,
    networkId: 1,
    posId: 2,
    invoiceUuid: 'inv-uuid-10',
    saleTypeRaw: 'WHOLESALE',
    saleTypeLabel: 'مبيعات جملة',
    invoiceTotalAmount: 38500.0,
    paidAmount: 38500.0,
    remainingAmount: 0.0,
    paymentStatusRaw: 'PAID',
    paymentStatusLabel: 'مسددة بالكامل',
    isFullyPaid: true,
    posName: 'نقطة بيع البركة',
    items: [sampleItem],
  );

  Widget createTestWidget({
    required bool isExpanded,
    VoidCallback? onToggleExpansion,
    VoidCallback? onTap,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: InvoiceCard(
              invoice: sampleInvoice,
              isExpanded: isExpanded,
              onToggleExpansion: onToggleExpansion,
              onTap: onTap ?? () {},
              isNetworkView: true,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('InvoiceCard renders header, status badge and party details correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(isExpanded: false));

    expect(find.text('inv-uuid-10'), findsOneWidget);
    expect(find.text('نقطة بيع البركة'), findsOneWidget);
    expect(find.text('مسددة بالكامل'), findsWidgets);
    expect(find.text('الباقات والكميات (1)'), findsOneWidget);
    expect(find.text('• 77 كرت'), findsOneWidget);
  });

  testWidgets('Tapping accordion toggle triggers onToggleExpansion callback', (tester) async {
    bool toggled = false;

    await tester.pumpWidget(
      createTestWidget(
        isExpanded: false,
        onToggleExpansion: () => toggled = true,
      ),
    );

    final toggleFinder = find.text('عرض التفاصيل');
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    expect(toggled, isTrue);
  });

  testWidgets('Expanded InvoiceCard displays unified quantity label and package details', (tester) async {
    await tester.pumpWidget(createTestWidget(isExpanded: true));

    // يجب أن تظهر الباقة وتوصيف الكمية الموحد ورقة ونصف • 77 كرت
    expect(find.text('باقة النخبة 10 جيجا'), findsOneWidget);
    expect(find.text('ورقة ونصف  •  77 كرت'), findsOneWidget);
    expect(find.text('إخفاء البنود'), findsOneWidget);
  });
}
