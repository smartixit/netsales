import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب الشبكات المرتبطة بنقطة بيع مع دعم الترقيم بالمؤشر والبحث الخادمي
class GetPosNetworksListUseCase {
  const GetPosNetworksListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosLinkEntity>> execute(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
  }) {
    return _repository.getPosNetworksList(
      posId,
      cursor: cursor,
      search: search,
      status: status,
      perPage: perPage,
    );
  }

  Future<PaginatedList<NetworkPosLinkEntity>> call(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
  }) => execute(
    posId,
    cursor: cursor,
    search: search,
    status: status,
    perPage: perPage,
  );
}
