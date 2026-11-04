import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class CreatePackageDiscountUseCase {
  final PackagesRepository _repository;

  const CreatePackageDiscountUseCase(this._repository);

  Future<VoucherPackageDiscountEntity> call(Map<String, dynamic> data) {
    return _repository.createPackageDiscount(data);
  }
}

