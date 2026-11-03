import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام ربط نقطة بيع بشبكة
class CreateNetworkPosLinkUseCase {
  const CreateNetworkPosLinkUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> execute({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) {
    return _repository.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      status: status,
    );
  }

  Future<NetworkPosLinkEntity> call({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) =>
      execute(
        networkId: networkId,
        posId: posId,
        posUuid: posUuid,
        status: status,
      );
}
