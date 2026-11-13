import 'package:netsales/features/expenses/data/services/expense_document_service.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';

/// Infrastructure adapter for generating and delivering expense vouchers.
class ExpenseDocumentRepositoryImpl implements ExpenseDocumentRepository {
  const ExpenseDocumentRepositoryImpl({required this.documentService});

  final ExpenseDocumentService documentService;

  @override
  Future<bool> exportAndSave(ExpenseEntity expense) async {
    final result = await documentService.exportAndSave(expense);
    return result.isSuccess;
  }

  @override
  Future<bool> share(ExpenseEntity expense) {
    return documentService.share(expense);
  }

  @override
  Future<bool> print(ExpenseEntity expense) {
    return documentService.print(expense);
  }
}
