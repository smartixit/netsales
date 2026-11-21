import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('ExpenseCard Widget Tests', () {
    testWidgets('Renders ExpenseCard with references, metrics, and items', (
      tester,
    ) async {
      bool detailsCalled = false;

      final expense = ExpenseEntity(
        expenseId: 77,
        expenseUuid: 'EXP-77-TEST',
        networkId: 1,
        expenseTotalAmount: 4200.0,
        networkName: 'شبكة الواحة الذكية',
        items: const [
          ExpenseItemEntity(
            itemId: 1,
            expenseId: 77,
            itemStatement: 'صيانة كوابل ألياف ضوئية',
            itemAmount: 4200.0,
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ExpenseCard(
            expense: expense,
            onDetails: () => detailsCalled = true,
            onToggleExpand: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EXP-77-TEST'), findsWidgets);
      expect(find.text('شبكة الواحة الذكية'), findsWidgets);
      expect(find.text('مصروف تشغيلي'), findsWidgets);
      expect(find.text('تفاصيل المصروف'), findsOneWidget);

      await tester.tap(find.text('تفاصيل المصروف'));
      await tester.pumpAndSettle();

      expect(detailsCalled, isTrue);
    });
  });
}
