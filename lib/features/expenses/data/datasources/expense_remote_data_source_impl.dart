import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  const ExpenseRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<ExpenseModel>>(
      ApiConstants.expenses,
      queryParameters: query,
      fromJson: (data) => data is List
          ? data
              .whereType<Map<String, dynamic>>()
              .map(ExpenseModel.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}
