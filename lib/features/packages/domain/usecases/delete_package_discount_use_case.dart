import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class DeletePackageDiscountUseCase {
  final PackagesRepository _repository;

  const DeletePackageDiscountUseCase(this._repository);

  Future<bool> call(int discountId) {
    return _repository.deletePackageDiscount(discountId);
  }
}

