import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;
  const GetExpensesUseCase(this.repository);

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
  final ExpenseRepository repository;
  const GetExpenseDetailsUseCase(this.repository);
  Future<ExpenseEntity> call(int expenseId) => repository.getExpense(expenseId);
}

class CreateExpenseUseCase {
  final ExpenseRepository repository;
  const CreateExpenseUseCase(this.repository);

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
  final ExpenseRepository repository;
  const UpdateExpenseUseCase(this.repository);

  Future<ExpenseEntity> call({
    required int expenseId,
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) => repository.updateExpense(
    expenseId: expenseId,
    networkId: networkId,
    expenseDate: expenseDate,
    items: items,
    attachments: attachments,
  );
}

class DeleteExpenseAttachmentUseCase {
  final ExpenseRepository repository;
  const DeleteExpenseAttachmentUseCase(this.repository);
  Future<void> call({
    required int expenseId,
    required int attachmentId,
  }) => repository.deleteAttachment(
    expenseId: expenseId,
    attachmentId: attachmentId,
  );
}
