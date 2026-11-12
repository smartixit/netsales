import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// Coordinates export, sharing, and printing for an official expense voucher.
class ExpenseDocumentUseCase {
  const ExpenseDocumentUseCase(this.repository);

  final ExpenseDocumentRepository repository;

  Future<bool> exportAndSave(ExpenseEntity expense) {
    return repository.exportAndSave(expense);
  }

  Future<bool> share(ExpenseEntity expense) {
    return repository.share(expense);
  }

  Future<bool> print(ExpenseEntity expense) {
    return repository.print(expense);
  }
}
