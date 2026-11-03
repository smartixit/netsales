import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب الشبكات المرتبطة بنقطة بيع
class GetPosNetworksListUseCase {
  const GetPosNetworksListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<NetworkPosLinkEntity>> execute(
    int posId, {
    Map<String, dynamic>? query,
  }) {
    return _repository.getPosNetworksList(posId, query: query);
  }

  Future<List<NetworkPosLinkEntity>> call(
    int posId, {
    Map<String, dynamic>? query,
  }) => execute(posId, query: query);
}
