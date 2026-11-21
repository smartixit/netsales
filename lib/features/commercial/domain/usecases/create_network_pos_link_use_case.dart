import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام إنشاء ارتباط تجاري مباشر
class CreateNetworkPosLinkUseCase {
  const CreateNetworkPosLinkUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> call({
    required int networkId,
    required int posId,
  }) {
    return _repository.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
    );
  }
}
