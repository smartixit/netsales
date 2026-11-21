import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// واجهة تصدير وطباعة المستندات والمحررات الرسمية للمصروفات التشغيلية
abstract interface class ExpenseDocumentRepository {
  /// طباعة سند المصروف مباشرة عبر الطابعة المتصلة
  Future<bool> printExpense(ExpenseEntity expense);

  /// مشاركة ملف PDF الخاص بسند المصروف عبر تطبيقات التواصل
  Future<bool> shareExpense(ExpenseEntity expense);

  /// تصدير وحفظ ملف PDF لسند المصروف في ذاكرة الجهاز
  Future<bool> exportAndSaveExpense(ExpenseEntity expense);
}
