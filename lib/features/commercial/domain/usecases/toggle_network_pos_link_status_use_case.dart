import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام تبديل حالة ارتباط نقطة بيع بشبكة
class ToggleNetworkPosLinkStatusUseCase {
  const ToggleNetworkPosLinkStatusUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> execute(int linkId) {
    return _repository.toggleNetworkPosLinkStatus(linkId);
  }

  Future<NetworkPosLinkEntity> call(int linkId) => execute(linkId);
}

