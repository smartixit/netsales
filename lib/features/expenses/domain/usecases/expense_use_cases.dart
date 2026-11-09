import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  const GetExpensesUseCase(this.repository);
  final ExpenseRepository repository;
  Future<PaginatedList<ExpenseEntity>> call({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
  }) => repository.getExpenses(
    networkId: networkId,
    search: search,
    fromDate: fromDate,
    toDate: toDate,
    cursor: cursor,
  );
}

class GetExpenseDetailsUseCase {
  const GetExpenseDetailsUseCase(this.repository);
  final ExpenseRepository repository;
  Future<ExpenseEntity> call(int id) => repository.getExpense(id);
}

class CreateExpenseUseCase {
  const CreateExpenseUseCase(this.repository);
  final ExpenseRepository repository;
  Future<ExpenseEntity> call({
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) => repository.createExpense(
    networkId: networkId,
    expenseDate: expenseDate,
    items: items,
    attachments: attachments,
  );
}

class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this.repository);
  final ExpenseRepository repository;
  Future<ExpenseEntity> call({
    required int expenseId,
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) => repository.updateExpense(
    expenseId: expenseId,
    expenseDate: expenseDate,
    items: items,
    attachments: attachments,
  );
}

class DeleteExpenseAttachmentUseCase {
  const DeleteExpenseAttachmentUseCase(this.repository);
  final ExpenseRepository repository;
  Future<void> call({required int expenseId, required int attachmentId}) =>
      repository.deleteAttachment(
        expenseId: expenseId,
        attachmentId: attachmentId,
      );
}
