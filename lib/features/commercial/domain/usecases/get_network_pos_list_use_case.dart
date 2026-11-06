import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب نقاط البيع المرتبطة بشبكة مع دعم الترقيم بالمؤشر والبحث الخادمي
class GetNetworkPosListUseCase {
  const GetNetworkPosListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosLinkEntity>> execute(
    int networkId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
  }) {
    return _repository.getNetworkPosList(
      networkId,
      cursor: cursor,
      search: search,
      status: status,
      perPage: perPage,
    );
  }

  Future<PaginatedList<NetworkPosLinkEntity>> call(
    int networkId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
  }) => execute(
    networkId,
    cursor: cursor,
    search: search,
    status: status,
    perPage: perPage,
  );
}
