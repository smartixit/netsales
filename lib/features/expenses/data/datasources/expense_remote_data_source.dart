import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<ExpenseModel>> getExpense(int expenseId);

  Future<ApiResponse<ExpenseModel>> createExpense({
    required Map<String, dynamic> payload,
    required List<AppPickedFileModel> attachments,
  });

  Future<ApiResponse<ExpenseModel>> updateExpense({
    required int expenseId,
    required Map<String, dynamic> payload,
    required List<AppPickedFileModel> attachments,
  });

  Future<ApiResponse<bool>> deleteAttachment({
    required int expenseId,
    required int attachmentId,
  });

  Future<ApiResponse<bool>> deleteExpense(int expenseId);
}
