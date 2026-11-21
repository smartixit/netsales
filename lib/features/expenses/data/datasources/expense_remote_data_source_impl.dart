import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';
import 'package:netsales/features/expenses/data/models/expense_summary_model.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';

/// التنفيذ الفعلي لمصدر البيانات الشبكي للمصروفات (ExpenseRemoteDataSourceImpl)
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;
  String? _nextCursor;

  @override
  String? get nextCursor => _nextCursor;

  @override
  Future<List<ExpenseModel>> getExpenses({
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
    };

    final response = await _apiService.getList<ExpenseModel>(
      ApiConstants.expenses,
      queryParameters: queryParams,
      cursor: cursor,
      perPage: perPage ?? 15,
      fromJson: (dynamic json) =>
          ExpenseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة المصروفات التشغيلية',
      );
    }

    _nextCursor = response.nextCursor;
    return response.data ?? [];
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

    final response = await _apiService.get<ExpenseSummaryModel>(
      ApiConstants.expensesSummary,
      queryParameters: queryParams,
      fromJson: (dynamic json) =>
          ExpenseSummaryModel.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب ملخص وإحصائيات المصروفات',
      );
    }

    return response.data ?? const ExpenseSummaryModel();
  }

  @override
  Future<ExpenseModel> getExpenseDetails(int expenseId) async {
    final response = await _apiService.get<ExpenseModel>(
      ApiConstants.expense(expenseId),
      fromJson: (dynamic json) =>
          ExpenseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر عرض بيانات المصروف المحدد',
      );
    }

    return response.data!;
  }

  @override
  Future<ExpenseModel> createExpense({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('network_id', networkId.toString()));

    if (expenseDate != null) {
      formData.fields.add(
        MapEntry('expense_date', DateFormatter.iso(expenseDate)),
      );
    }

    for (int i = 0; i < items.length; i++) {
      formData.fields.add(
        MapEntry('items[$i][item_statement]', items[i].itemStatement),
      );
      formData.fields.add(
        MapEntry('items[$i][item_amount]', items[i].itemAmount.toString()),
      );
    }

    if (attachments != null && attachments.isNotEmpty) {
      for (final file in attachments) {
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              MultipartFile.fromBytes(file.bytes!, filename: file.name),
            ),
          );
        } else if (file.path.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              await MultipartFile.fromFile(file.path, filename: file.name),
            ),
          );
        }
      }
    }

    final response = await _apiService.post<ExpenseModel>(
      ApiConstants.expenses,
      data: formData,
      idempotencyKey: idempotencyKey,
      fromJson: (dynamic json) =>
          ExpenseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تسجيل المصروف وخصمه من محفظة الشبكة',
      );
    }

    return response.data!;
  }

  @override
  Future<ExpenseModel> updateExpense({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
  }) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('_method', 'PUT'));

    if (expenseDate != null) {
      formData.fields.add(
        MapEntry('expense_date', DateFormatter.iso(expenseDate)),
      );
    }

    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        formData.fields.add(
          MapEntry('items[$i][item_statement]', items[i].itemStatement),
        );
        formData.fields.add(
          MapEntry('items[$i][item_amount]', items[i].itemAmount.toString()),
        );
      }
    }

    if (attachments != null && attachments.isNotEmpty) {
      for (final file in attachments) {
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              MultipartFile.fromBytes(file.bytes!, filename: file.name),
            ),
          );
        } else if (file.path.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              await MultipartFile.fromFile(file.path, filename: file.name),
            ),
          );
        }
      }
    }

    final response = await _apiService.post<ExpenseModel>(
      ApiConstants.expense(expenseId),
      data: formData,
      fromJson: (dynamic json) =>
          ExpenseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحديث بيانات المصروف وتسوية المحفظة',
      );
    }

    return response.data!;
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    final response = await _apiService.delete<void>(
      ApiConstants.expense(expenseId),
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر حذف المصروف واسترجاع المبلغ لمحفظة الشبكة',
      );
    }
  }
}
