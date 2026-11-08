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

  Future<FormData> _formData(Map<String, dynamic> payload, List<AppPickedFileModel> files) async {
    final fields = <String, dynamic>{
      'network_id': payload['network_id'],
      'expense_date': payload['expense_date'],
    };
    final items = payload['items'] as List<Map<String, dynamic>>;
    for (var i = 0; i < items.length; i++) {
      fields['items[$i][item_statement]'] = items[i]['item_statement'];
      fields['items[$i][item_amount]'] = items[i]['item_amount'];
    }
    for (var i = 0; i < files.length; i++) {
      final file = File(files[i].path);
      if (!await file.exists()) throw FileSystemException('المرفق غير موجود', file.path);
      fields['attachments[$i]'] = await MultipartFile.fromFile(file.path, filename: files[i].name);
    }
    return FormData.fromMap(fields);
  }

  ExpenseModel _parse(dynamic data) => ExpenseModel.fromJson(Map<String, dynamic>.from(data as Map));

  @override
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({Map<String, dynamic>? query}) =>
      ApiService.instance.get<List<ExpenseModel>>(
        ApiConstants.expenses,
        queryParameters: query,
        fromJson: (data) => data is List
            ? data.whereType<Map>().map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e))).toList(growable: false)
            : const [],
      );

  @override
  Future<ApiResponse<ExpenseModel>> getExpense(int id) =>
      ApiService.instance.get<ExpenseModel>(ApiConstants.expense(id), fromJson: _parse);

  @override
  Future<ApiResponse<ExpenseModel>> createExpense({required Map<String, dynamic> payload, required List<AppPickedFileModel> attachments}) async =>
      ApiService.instance.post<ExpenseModel>(
        ApiConstants.expenses,
        data: await _formData(payload, attachments),
        fromJson: _parse,
      );

  @override
  Future<ApiResponse<ExpenseModel>> updateExpense({required int expenseId, required Map<String, dynamic> payload, required List<AppPickedFileModel> attachments}) async =>
      ApiService.instance.put<ExpenseModel>(
        ApiConstants.expense(expenseId),
        data: await _formData(payload, attachments),
        fromJson: _parse,
      );

  @override
  Future<ApiResponse<void>> deleteAttachment({required int expenseId, required int attachmentId}) =>
      ApiService.instance.delete<void>(ApiConstants.expenseDeleteAttachment(expenseId, attachmentId));
}
