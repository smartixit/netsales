import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  const ExpenseRepositoryImpl({required this.remoteDataSource});

  AppException _failure<T>(
    ApiResponse<T> response,
    String fallback,
    String code,
  ) {
    return AppException(
      response.message.isNotEmpty ? response.message : fallback,
      code: code,
      details: response.errors,
    );
  }

  @override
  Future<PaginatedList<ExpenseEntity>> getExpenses({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 20,
  }) async {
    final query = <String, dynamic>{
      'network_id': networkId,
      'per_page': perPage,
      'cursor': ?cursor,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      if (fromDate?.isNotEmpty ?? false) 'from_date': fromDate,
      if (toDate?.isNotEmpty ?? false) 'to_date': toDate,
    };
    final response = await remoteDataSource.getExpenses(query: query);
    if (!response.success || response.data == null) {
      throw _failure(
        response,
        'تعذر تحميل المصروفات التشغيلية.',
        'EXPENSE_LIST_REQUEST_FAILED',
      );
    }
    return PaginatedList<ExpenseEntity>(
      items: response.data!,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
  }

  @override
  Future<ExpenseEntity> getExpense(int expenseId) async {
    final response = await remoteDataSource.getExpense(expenseId);
    if (!response.success || response.data == null) {
      throw _failure(
        response,
        'تعذر تحميل تفاصيل المصروف.',
        'EXPENSE_DETAILS_REQUEST_FAILED',
      );
    }
    return response.data!;
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) async {
    final response = await remoteDataSource.createExpense(
      payload: {
        'network_id': networkId,
        'expense_date': expenseDate,
        'items': items,
      },
      attachments: attachments,
    );
    if (!response.success || response.data == null) {
      throw _failure(
        response,
        'تعذر تسجيل المصروف التشغيلي.',
        'EXPENSE_CREATE_FAILED',
      );
    }
    return response.data!;
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) async {
    final response = await remoteDataSource.updateExpense(
      expenseId: expenseId,
      payload: {'expense_date': expenseDate, 'items': items},
      attachments: attachments,
    );
    if (!response.success || response.data == null) {
      throw _failure(response, 'تعذر تحديث المصروف.', 'EXPENSE_UPDATE_FAILED');
    }
    return response.data!;
  }

  @override
  Future<void> deleteAttachment({
    required int expenseId,
    required int attachmentId,
  }) async {
    final response = await remoteDataSource.deleteAttachment(
      expenseId: expenseId,
      attachmentId: attachmentId,
    );
    if (!response.success) {
      throw _failure(
        response,
        'تعذر حذف المرفق.',
        'EXPENSE_ATTACHMENT_DELETE_FAILED',
      );
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    final response = await remoteDataSource.deleteExpense(expenseId);
    if (!response.success) {
      throw _failure(
        response,
        'تعذر حذف المصروف.',
        'EXPENSE_DELETE_FAILED',
      );
    }
  }
}
