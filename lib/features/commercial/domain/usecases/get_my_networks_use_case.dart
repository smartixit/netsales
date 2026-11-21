import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب الشبكات المتاحة للمستخدم الحالي
class GetMyNetworksUseCase {
  const GetMyNetworksUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<NetworkEntity>> call() => _repository.getMyNetworks();
}
