import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام حذف مرفق من مصروف تشغيلي
class DeleteExpenseAttachmentUseCase {
  const DeleteExpenseAttachmentUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call({
    required int expenseId,
    required int attachmentId,
  }) {
    return _repository.deleteExpenseAttachment(
      expenseId: expenseId,
      attachmentId: attachmentId,
    );
  }
}
