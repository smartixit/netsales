import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';

class UpdatePackagePosDiscountUseCase {
  const UpdatePackagePosDiscountUseCase(this._repository);

  final PackagePosDiscountRepository _repository;

  Future<PackagePosDiscountEntity> call(int discountId, Map<String, dynamic> payload) => _repository.update(discountId, payload);
}
