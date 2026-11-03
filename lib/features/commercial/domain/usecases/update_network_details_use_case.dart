import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام تحديث بيانات شبكة محددة
class UpdateNetworkDetailsUseCase {
  const UpdateNetworkDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkEntity> execute(int networkId, Map<String, dynamic> data) {
    return _repository.updateNetworkDetails(networkId, data);
  }

  Future<NetworkEntity> call(int networkId, Map<String, dynamic> data) =>
      execute(networkId, data);
}

