import 'package:netsales/features/expenses/data/services/expense_document_service.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// تطبيق مستودع مستندات المصروفات التشغيلية
class ExpenseDocumentRepositoryImpl implements ExpenseDocumentRepository {
  const ExpenseDocumentRepositoryImpl();

  @override
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) {
    return ExpenseDocumentService.instance.exportAndSaveExpense(expense);
  }

  @override
  Future<bool> shareExpense(ExpenseEntity expense) {
    return ExpenseDocumentService.instance.shareExpense(expense);
  }

  @override
  Future<bool> printExpense(ExpenseEntity expense) {
    return ExpenseDocumentService.instance.printExpense(expense);
  }
}
