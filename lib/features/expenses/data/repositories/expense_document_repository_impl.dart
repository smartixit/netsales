import 'package:netsales/features/expenses/data/services/expense_document_service.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// تطبيق مستودع طباعة وتصدير مستندات المصروفات (ExpenseDocumentRepositoryImpl)
class ExpenseDocumentRepositoryImpl implements ExpenseDocumentRepository {
  const ExpenseDocumentRepositoryImpl({
    this.documentService = const ExpenseDocumentService(),
  });

  final ExpenseDocumentService documentService;

  @override
  Future<bool> printExpense(ExpenseEntity expense) {
    return documentService.printExpense(expense);
  }

  @override
  Future<bool> shareExpense(ExpenseEntity expense) {
    return documentService.shareExpense(expense);
  }

  @override
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) {
    return documentService.exportAndSaveExpense(expense);
  }
}
