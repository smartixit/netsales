import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// العقد التجريدي لعمليات المستندات والطباعة والتصدير لسند صرف المصروفات
abstract class ExpenseDocumentRepository {
  /// تصدير وحفظ سند صرف المصروف كـ PDF
  Future<bool> exportAndSaveExpense(ExpenseEntity expense);

  /// مشاركة ملف سند الصرف
  Future<bool> shareExpense(ExpenseEntity expense);

  /// طباعة سند الصرف مباشرة
  Future<bool> printExpense(ExpenseEntity expense);
}
