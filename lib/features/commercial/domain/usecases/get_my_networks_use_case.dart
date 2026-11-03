import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب قائمة الشبكات التابعة للمستخدم الحالي
class GetMyNetworksUseCase {
  const GetMyNetworksUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<NetworkEntity>> execute() {
    return _repository.getMyNetworks();
  }

  Future<List<NetworkEntity>> call() => execute();
}
