import 'dart:io';

import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  const ExpenseRemoteDataSourceImpl();

  Future<FormData> _buildFormData({
    required Map<String, dynamic> payload,
    required List<AppPickedFileModel> attachments,
  }) async {
    final fields = <String, dynamic>{};
    if (payload.containsKey('network_id')) {
      fields['network_id'] = payload['network_id'];
    }
    if (payload.containsKey('expense_date')) {
      fields['expense_date'] = payload['expense_date'];
    }

    final rawItems = payload['items'];
    if (rawItems is List<Map<String, dynamic>>) {
      for (var index = 0; index < rawItems.length; index++) {
        fields['items[$index][item_statement]'] =
            rawItems[index]['item_statement'];
        fields['items[$index][item_amount]'] = rawItems[index]['item_amount'];
      }
    }

    for (var index = 0; index < attachments.length; index++) {
      final pickedFile = attachments[index];
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        throw FileSystemException(
          'تعذر العثور على المرفق المحدد',
          pickedFile.path,
        );
      }
      fields['attachments[$index]'] = await MultipartFile.fromFile(
        pickedFile.path,
        filename: pickedFile.name,
      );
    }

    return FormData.fromMap(fields);
  }

  ExpenseModel _parseExpense(dynamic data) {
    if (data is! Map<dynamic, dynamic>) {
      throw const FormatException('تنسيق استجابة المصروف غير صالح.');
    }
    return ExpenseModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<ExpenseModel>>(
      ApiConstants.expenses,
      queryParameters: query,
      fromJson: (data) {
        if (data is! List) return const <ExpenseModel>[];
        return data
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      },
    );
  }

  @override
  Future<ApiResponse<ExpenseModel>> getExpense(int expenseId) {
    return ApiService.instance.get<ExpenseModel>(
      ApiConstants.expense(expenseId),
      fromJson: _parseExpense,
    );
  }

  @override
  Future<ApiResponse<ExpenseModel>> createExpense({
    required Map<String, dynamic> payload,
    required List<AppPickedFileModel> attachments,
  }) async {
    final formData = await _buildFormData(
      payload: payload,
      attachments: attachments,
    );
    return ApiService.instance.post<ExpenseModel>(
      ApiConstants.expenses,
      data: formData,
      fromJson: _parseExpense,
    );
  }

  @override
  Future<ApiResponse<ExpenseModel>> updateExpense({
    required int expenseId,
    required Map<String, dynamic> payload,
    required List<AppPickedFileModel> attachments,
  }) async {
    final formData = await _buildFormData(
      payload: payload,
      attachments: attachments,
    );
    formData.fields.add(const MapEntry('_method', 'PUT'));
    return ApiService.instance.post<ExpenseModel>(
      ApiConstants.expense(expenseId),
      data: formData,
      fromJson: _parseExpense,
    );
  }

  @override
  Future<ApiResponse<bool>> deleteAttachment({
    required int expenseId,
    required int attachmentId,
  }) {
    return ApiService.instance.delete<bool>(
      ApiConstants.expenseDeleteAttachment(expenseId, attachmentId),
      fromJson: (data) => data is bool ? data : true,
    );
  }

  @override
  Future<ApiResponse<bool>> deleteExpense(int expenseId) {
    return ApiService.instance.delete<bool>(
      ApiConstants.expense(expenseId),
      fromJson: (data) => data is bool ? data : true,
    );
  }
}
