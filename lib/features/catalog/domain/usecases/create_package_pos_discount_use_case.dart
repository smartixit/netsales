import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';

class CreatePackagePosDiscountUseCase {
  const CreatePackagePosDiscountUseCase(this._repository);

  final PackagePosDiscountRepository _repository;

  Future<PackagePosDiscountEntity> call(Map<String, dynamic> payload) => _repository.create(payload);
}
