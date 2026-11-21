import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// حالة استخدام العمليات المستندية على سند المصروف (طباعة، مشاركة، تصدير وحفظ PDF)
class ExpenseDocumentUseCase {
  final ExpenseDocumentRepository _repository;

  const ExpenseDocumentUseCase(this._repository);

  /// طباعة سند المصروف
  Future<bool> printExpense(ExpenseEntity expense) {
    return _repository.printExpense(expense);
  }

  /// مشاركة سند المصروف
  Future<bool> shareExpense(ExpenseEntity expense) {
    return _repository.shareExpense(expense);
  }

  /// تصدير وحفظ سند المصروف في الجهاز
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) {
    return _repository.exportAndSaveExpense(expense);
  }

  /// الاسم البديل المعتمد لسهولة الاستدعاء
  Future<bool> saveExpense(ExpenseEntity expense) {
    return exportAndSaveExpense(expense);
  }
}
