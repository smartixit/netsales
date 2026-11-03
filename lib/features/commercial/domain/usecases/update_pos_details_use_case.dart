import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام تحديث بيانات نقطة بيع محددة
class UpdatePosDetailsUseCase {
  const UpdatePosDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PosEntity> execute(int posId, Map<String, dynamic> data) {
    return _repository.updatePosDetails(posId, data);
  }

  Future<PosEntity> call(int posId, Map<String, dynamic> data) =>
      execute(posId, data);
}
