import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام استرجاع الشبكات المرتبطة بنقطة بيع محددة
class GetPosNetworksListUseCase {
  const GetPosNetworksListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosLinkEntity>> call({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _repository.getPosNetworksList(
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
