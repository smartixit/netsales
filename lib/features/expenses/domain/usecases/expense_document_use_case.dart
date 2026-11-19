import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// حالات استخدام مستندات وطباعة ومشاركة سندات صرف المصروفات
class ExpenseDocumentUseCase {
  const ExpenseDocumentUseCase(this._repository);

  final ExpenseDocumentRepository _repository;

  Future<bool> exportAndSave(ExpenseEntity expense) {
    return _repository.exportAndSaveExpense(expense);
  }

  Future<bool> share(ExpenseEntity expense) {
    return _repository.shareExpense(expense);
  }

  Future<bool> print(ExpenseEntity expense) {
    return _repository.printExpense(expense);
  }
}
