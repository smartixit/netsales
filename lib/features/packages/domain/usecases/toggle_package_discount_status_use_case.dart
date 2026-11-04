import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class TogglePackageDiscountStatusUseCase {
  final PackagesRepository _repository;

  const TogglePackageDiscountStatusUseCase(this._repository);

  Future<VoucherPackageDiscountEntity> call(int discountId) {
    return _repository.togglePackageDiscountStatus(discountId);
  }
}

