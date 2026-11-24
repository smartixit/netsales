import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/data/models/request_modification_preview_model.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// تطبيق مستودع دورة حياة طلبات الكروت والتوريد
class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource _remoteDataSource;

  const RequestRepositoryImpl(this._remoteDataSource);

  @override
  Future<RequestStatusSummaryEntity> getRequestStatusSummary({
    int? networkId,
    int? posId,
  }) async {
    final query = <String, dynamic>{'network_id': ?networkId, 'pos_id': ?posId};
    final response = await _remoteDataSource.getRequestStatusSummary(
      query: query.isNotEmpty ? query : null,
    );
    return response.data ?? RequestStatusSummaryEntity.empty;
  }

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

    if (!response.success) {
      throw AppException(response.message);
    }

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
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }

  @override
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    final response = await _remoteDataSource.createRequest(
      data,
      idempotencyKey: idempotencyKey,
    );
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }

  @override
  Future<RequestEntity> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateRequest(requestId, data);
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }

  @override
  Future<RequestEntity> cancelRequest(int requestId) async {
    final response = await _remoteDataSource.cancelRequest(requestId);
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }

  @override
  Future<bool> deleteRequest(int requestId) async {
    final response = await _remoteDataSource.deleteRequest(requestId);
    if (!response.success) {
      throw AppException(response.message);
    }
    return response.success;
  }

  @override
  Future<RequestModificationPreviewEntity> previewRequestModification(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) async {
    final payload = <String, dynamic>{'items': _mapModificationItems(items)};
    final response = await _remoteDataSource.previewRequestModification(
      requestId,
      payload,
    );
    if (!response.success) {
      throw AppException(response.message);
    }
    final data = response.data;
    if (data == null) {
      throw const FormatException(
        'The server returned an empty request modification preview.',
      );
    }
    return RequestModificationPreviewModel.fromJson(data);
  }

  @override
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
    double? paidAmount,
  }) async {
    final data = <String, dynamic>{
      if (requestNote != null && requestNote.isNotEmpty)
        'request_note': requestNote,
      if (items != null) 'items': _mapModificationItems(items),
      if (paidAmount != null && paidAmount > 0) 'paid_amount': paidAmount,
    };

    final response = await _remoteDataSource.approveRequest(
      requestId,
      data: data.isNotEmpty ? data : null,
    );
    if (!response.success) {
      throw AppException(response.message);
    }
    final result = response.data;
    if (result == null) {
      throw const FormatException(
        'الخادم لم يُرجع نتيجة الاعتماد والفاتورة المرتبطة.',
      );
    }
    return result;
  }

  List<Map<String, dynamic>> _mapModificationItems(
    List<RequestModificationLineEntity> items,
  ) {
    return items
        .map(
          (item) => <String, dynamic>{
            'package_id': item.packageId,
            'voucher_count': item.voucherCount,
            if (item.pricingToken != null) 'pricing_token': item.pricingToken,
          },
        )
        .toList(growable: false);
  }

  @override
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async {
    final response = await _remoteDataSource.rejectRequest(requestId, {
      'rejection_reason': rejectionReason,
    });
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }
}
