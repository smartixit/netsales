import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseAttachmentUseCase {
  const DeleteExpenseAttachmentUseCase(this.repository);

  final ExpenseRepository repository;

  Future<void> call({
    required int expenseId,
    required int attachmentId,
  }) {
    return repository.deleteAttachment(
      expenseId: expenseId,
      attachmentId: attachmentId,
    );
  }
}
