import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام جلب قائمة نقاط البيع التابعة للمستخدم الحالي
class GetMyPosUseCase {
  const GetMyPosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<PosEntity>> execute() {
    return _repository.getMyPos();
  }

  Future<List<PosEntity>> call() => execute();
}
