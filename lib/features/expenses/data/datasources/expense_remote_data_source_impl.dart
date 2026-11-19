import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';
import 'package:netsales/features/expenses/data/models/expense_summary_model.dart';

/// تطبيق مصدر البيانات البعيد للمصروفات عبر ApiService
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  const ExpenseRemoteDataSourceImpl();

  @override
  Future<PaginatedList<ExpenseModel>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{
      'network_id': ?networkId,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': perPage ?? 15,
    };

    final response = await ApiService.instance.get<List<ExpenseModel>>(
      ApiConstants.expenses,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(ExpenseModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );

    return PaginatedList<ExpenseModel>(
      items: response.data ?? const [],
      nextCursor: response.meta?['next_cursor'] as String?,
      prevCursor: response.meta?['prev_cursor'] as String?,
      perPage: response.meta?['per_page'] as int? ?? perPage ?? 15,
    );
  }

  @override
  Future<ExpenseModel> getExpenseDetails(int expenseId) async {
    final response = await ApiService.instance.get<ExpenseModel>(
      ApiConstants.expense(expenseId),
      fromJson: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('لم يتم استرجاع بيانات المصروف من الخادم.');
    }
    return result;
  }

  @override
  Future<ExpenseSummaryModel> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'network_id': ?networkId,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    };

    final response = await ApiService.instance.get<ExpenseSummaryModel>(
      ApiConstants.expensesSummary,
      queryParameters: queryParams,
      fromJson: (data) =>
          ExpenseSummaryModel.fromJson(data as Map<String, dynamic>),
    );

    return response.data ??
        const ExpenseSummaryModel(
          totalCount: 0,
          totalAmount: 0.0,
          thisMonthAmount: 0.0,
          todayAmount: 0.0,
        );
  }

  @override
  Future<ExpenseModel> createExpense({
    required int networkId,
    String? expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  }) async {
    dynamic requestBody;

    if (attachmentPaths.isNotEmpty) {
      final formData = FormData();
      formData.fields.add(MapEntry('network_id', networkId.toString()));
      if (expenseDate != null) {
        formData.fields.add(MapEntry('expense_date', expenseDate));
      }

      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        formData.fields.add(
          MapEntry('items[$i][item_statement]', it['item_statement'].toString()),
        );
        formData.fields.add(
          MapEntry('items[$i][item_amount]', it['item_amount'].toString()),
        );
      }

      for (final path in attachmentPaths) {
        formData.files.add(
          MapEntry('attachments[]', await MultipartFile.fromFile(path)),
        );
      }
      requestBody = formData;
    } else {
      requestBody = {
        'network_id': networkId,
        'expense_date': ?expenseDate,
        'items': items,
      };
    }

    final response = await ApiService.instance.post<ExpenseModel>(
      ApiConstants.expenses,
      data: requestBody,
      fromJson: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('تعذر حفظ المصروف التشغيلي.');
    }
    return result;
  }

  @override
  Future<ExpenseModel> updateExpense({
    required int expenseId,
    String? expenseDate,
    List<Map<String, dynamic>>? items,
    List<String> attachmentPaths = const [],
  }) async {
    dynamic requestBody;

    if (attachmentPaths.isNotEmpty) {
      final formData = FormData();
      formData.fields.add(const MapEntry('_method', 'PUT'));
      if (expenseDate != null) {
        formData.fields.add(MapEntry('expense_date', expenseDate));
      }

      if (items != null) {
        for (var i = 0; i < items.length; i++) {
          final it = items[i];
          formData.fields.add(
            MapEntry('items[$i][item_statement]', it['item_statement'].toString()),
          );
          formData.fields.add(
            MapEntry('items[$i][item_amount]', it['item_amount'].toString()),
          );
        }
      }

      for (final path in attachmentPaths) {
        formData.files.add(
          MapEntry('attachments[]', await MultipartFile.fromFile(path)),
        );
      }
      requestBody = formData;

      final response = await ApiService.instance.post<ExpenseModel>(
        ApiConstants.expense(expenseId),
        data: requestBody,
        fromJson: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
      );

      final result = response.data;
      if (result == null) {
        throw Exception('تعذر تحديث بيانات المصروف.');
      }
      return result;
    } else {
      requestBody = {
        'expense_date': ?expenseDate,
        'items': ?items,
      };

      final response = await ApiService.instance.put<ExpenseModel>(
        ApiConstants.expense(expenseId),
        data: requestBody,
        fromJson: (data) => ExpenseModel.fromJson(data as Map<String, dynamic>),
      );

      final result = response.data;
      if (result == null) {
        throw Exception('تعذر تحديث بيانات المصروف.');
      }
      return result;
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    final response = await ApiService.instance.delete<dynamic>(
      ApiConstants.expense(expenseId),
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> deleteExpenseAttachment({
    required int expenseId,
    required int attachmentId,
  }) async {
    final response = await ApiService.instance.delete<dynamic>(
      ApiConstants.expenseDeleteAttachment(expenseId, attachmentId),
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
