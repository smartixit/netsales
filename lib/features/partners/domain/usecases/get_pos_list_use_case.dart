import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة نقاط البيع والوكلاء (GetPosListUseCase)
/// ============================================================================
class GetPosListUseCase {
  final PartnersRepository _repository;

  const GetPosListUseCase(this._repository);

  Future<List<PosEntity>> call({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) {
    return _repository.getPosList(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      governorateId: governorateId,
      directorateId: directorateId,
    );
  }
}
