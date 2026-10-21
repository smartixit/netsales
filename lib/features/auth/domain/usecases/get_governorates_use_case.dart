import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام جلب قائمة المحافظات المتاحة في النظام (GetGovernoratesUseCase)
class GetGovernoratesUseCase {
  const GetGovernoratesUseCase(this._repository);

  final AuthRepository _repository;

  Future<List<GovernorateEntity>> execute() {
    return _repository.getGovernorates();
  }
}
