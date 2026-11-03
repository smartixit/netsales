import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب نقاط البيع المرتبطة بشبكة
class GetNetworkPosListUseCase {
  const GetNetworkPosListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<NetworkPosLinkEntity>> execute(
    int networkId, {
    Map<String, dynamic>? query,
  }) {
    return _repository.getNetworkPosList(networkId, query: query);
  }

  Future<List<NetworkPosLinkEntity>> call(
    int networkId, {
    Map<String, dynamic>? query,
  }) =>
      execute(networkId, query: query);
}
