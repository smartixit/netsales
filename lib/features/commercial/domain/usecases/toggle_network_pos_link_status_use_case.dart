import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام تبديل حالة الارتباط التجاري (تفعيل / تجميد)
class ToggleNetworkPosLinkStatusUseCase {
  const ToggleNetworkPosLinkStatusUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> call(int networkPosId) {
    return _repository.toggleNetworkPosLinkStatus(networkPosId);
  }
}
