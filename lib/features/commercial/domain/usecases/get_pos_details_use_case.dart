import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب تفاصيل نقطة بيع محددة
class GetPosDetailsUseCase {
  const GetPosDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PosEntity> execute(int posId) {
    return _repository.getPosDetails(posId);
  }

  Future<PosEntity> call(int posId) => execute(posId);
}
