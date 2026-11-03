import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب تفاصيل شبكة محددة
class GetNetworkDetailsUseCase {
  const GetNetworkDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkEntity> execute(int networkId) {
    return _repository.getNetworkDetails(networkId);
  }

  Future<NetworkEntity> call(int networkId) => execute(networkId);
}
