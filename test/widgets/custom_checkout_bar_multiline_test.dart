import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/forms/custom_checkout_bar.dart';

void main() {
  Widget testHarness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) =>
          MaterialApp(home: Scaffold(bottomNavigationBar: child)),
    );
  }

  group('CustomCheckoutBar Responsive Rows & Metrics Tests', () {
    testWidgets('renders 3 metrics in a single row without wrapping', (
      tester,
    ) async {
      await tester.pumpWidget(
        testHarness(
          const CustomCheckoutBar(
            metrics: [
              CheckoutMetricData(label: 'الإجمالي', value: '100,000'),
              CheckoutMetricData(
                label: 'الخصم',
                value: '5,000',
                isDiscount: true,
              ),
              CheckoutMetricData(label: 'الصافي', value: '95,000', isNet: true),
            ],
            actionLabel: 'تأكيد',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الإجمالي'), findsOneWidget);
      expect(find.text('الخصم'), findsOneWidget);
      expect(find.text('الصافي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders 5 metrics across 2 rows (3 in first, 2 in second) without overflow',
      (tester) async {
        await tester.pumpWidget(
          testHarness(
            const CustomCheckoutBar(
              metrics: [
                CheckoutMetricData(label: 'الإجمالي', value: '200,000'),
                CheckoutMetricData(
                  label: 'الخصم',
                  value: '10,000',
                  isDiscount: true,
                ),
                CheckoutMetricData(label: 'الصافي التقديري', value: '190,000'),
                CheckoutMetricData(label: 'المقبوض كاش', value: '50,000'),
                CheckoutMetricData(
                  label: 'المتبقي الآجل',
                  value: '140,000',
                  isNet: true,
                ),
              ],
              actionLabel: 'إصدار الفاتورة',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('الإجمالي'), findsOneWidget);
        expect(find.text('الخصم'), findsOneWidget);
        expect(find.text('الصافي التقديري'), findsOneWidget);
        expect(find.text('المقبوض كاش'), findsOneWidget);
        expect(find.text('المتبقي الآجل'), findsOneWidget);

        // Verify zero rendering exceptions or overflow errors
        expect(tester.takeException(), isNull);
      },
    );
  });
}
