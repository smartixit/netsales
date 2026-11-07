import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// تطبيق مستودع دورة حياة طلبات الكروت والتوريد
class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource _remoteDataSource;

  const RequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': ?perPage,
    };

    final response = await _remoteDataSource.getRequests(
      query: query.isNotEmpty ? query : null,
    );

    final items = response.data ?? [];

    return PaginatedList<RequestEntity>(
      items: items,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }

  @override
  Future<RequestEntity> getRequestDetails(int requestId) async {
    final response = await _remoteDataSource.getRequestDetails(requestId);
    return response.data!;
  }

  @override
  Future<RequestEntity> createRequest(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createRequest(data);
    return response.data!;
  }

  @override
  Future<RequestEntity> cancelRequest(int requestId) async {
    final response = await _remoteDataSource.cancelRequest(requestId);
    return response.data!;
  }

  @override
  Future<RequestEntity> approveRequest(
    int requestId, {
    String? requestNote,
  }) async {
    final data = <String, dynamic>{
      if (requestNote != null && requestNote.isNotEmpty)
        'request_note': requestNote,
    };

    final response = await _remoteDataSource.approveRequest(
      requestId,
      data: data.isNotEmpty ? data : null,
    );

    if (response.data is RequestEntity) {
      return response.data as RequestEntity;
    }

    // إذا أعاد الخادم تفاصيل الطلب داخل كائن مركب
    return await getRequestDetails(requestId);
  }

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async {
    final response = await _remoteDataSource.rejectRequest(
      requestId,
      {'rejection_reason': rejectionReason},
    );
    return response.data!;
  }
}
