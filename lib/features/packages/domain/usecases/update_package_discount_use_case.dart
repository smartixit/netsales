import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class UpdatePackageDiscountUseCase {
  final PackagesRepository _repository;

  const UpdatePackageDiscountUseCase(this._repository);

  Future<VoucherPackageDiscountEntity> call(
    int discountId,
    Map<String, dynamic> data,
  ) {
    return _repository.updatePackageDiscount(discountId, data);
  }
}

