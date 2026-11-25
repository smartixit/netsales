import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';

class RestorePackagePosDiscountUseCase {
  const RestorePackagePosDiscountUseCase(this._repository);
  final PackagePosDiscountRepository _repository;

  Future<void> call(int discountId) => _repository.restore(discountId);
}
