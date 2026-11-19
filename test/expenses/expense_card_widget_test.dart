import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card.dart';

void main() {
  const sampleItem = ExpenseItemEntity(
    itemId: 1,
    expenseId: 101,
    itemStatement: 'صيانة كابلات ألياف بصرية',
    itemAmount: 12500.0,
  );

  const sampleAttachment = ExpenseAttachmentEntity(
    attachmentId: 1,
    expenseId: 101,
    attachmentName: 'سند_قبض_فني.pdf',
    attachmentPath: 'expenses/101/doc.pdf',
    attachmentSize: 204800,
    attachmentMime: 'application/pdf',
    fileUrl: 'https://example.com/doc.pdf',
  );

  final sampleExpense = ExpenseEntity(
    expenseId: 101,
    networkId: 1,
    expenseUuid: 'exp-uuid-101',
    expenseTotalAmount: 12500.0,
    expenseDate: DateTime(2026, 11, 20),
    creatorName: 'أحمد علي',
    networkName: 'شبكة السرعة',
    items: const [sampleItem],
    attachments: const [sampleAttachment],
  );

  Widget createTestWidget({
    required bool isExpanded,
    VoidCallback? onToggleExpansion,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpenseCard(
              expense: sampleExpense,
              isExpanded: isExpanded,
              onToggleExpansion: onToggleExpansion,
              onTap: onTap ?? () {},
              onDelete: onDelete,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('ExpenseCard renders header, metrics, accordion and actions correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(isExpanded: false));

    expect(find.text('exp-uuid-101'), findsOneWidget);
    expect(find.text('شبكة السرعة'), findsOneWidget);
    expect(find.text('بنود المصروف (1)'), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
  });

  testWidgets('ExpenseCard expands accordion when isExpanded is true', (tester) async {
    await tester.pumpWidget(createTestWidget(isExpanded: true));

    expect(find.text('صيانة كابلات ألياف بصرية'), findsOneWidget);
  });
}
