import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  const ExpenseRepositoryImpl({required this.remoteDataSource});

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
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل المصروفات التشغيلية.',
        code: 'EXPENSE_LIST_REQUEST_FAILED',
        details: response.errors,
      );
    }
    return PaginatedList<ExpenseEntity>(
      items: response.data!,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
  }
}
