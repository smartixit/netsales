import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    Map<String, dynamic>? query,
  });
}
