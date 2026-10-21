import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام جلب مديريات محافظة معينة (GetDirectoratesUseCase)
class GetDirectoratesUseCase {
  const GetDirectoratesUseCase(this._repository);

  final AuthRepository _repository;

  Future<List<DirectorateEntity>> execute(int governorateId) {
    return _repository.getDirectorates(governorateId);
  }
}
