import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام جلب قائمة طلبات الكروت مع الترقيم القائم على المؤشر
class GetRequestsUseCase {
  final RequestRepository _repository;

  const GetRequestsUseCase(this._repository);

  Future<PaginatedList<RequestEntity>> call({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _repository.getRequests(
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

