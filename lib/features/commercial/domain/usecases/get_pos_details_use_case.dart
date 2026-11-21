import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام استرجاع تفاصيل نقطة بيع محددة
class GetPosDetailsUseCase {
  const GetPosDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PosEntity> call(int posId) {
    return _repository.getPosDetails(posId);
  }
}
