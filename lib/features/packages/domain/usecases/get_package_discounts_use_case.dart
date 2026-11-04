import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class GetPackageDiscountsUseCase {
  final PackagesRepository _repository;

  const GetPackageDiscountsUseCase(this._repository);

  Future<List<VoucherPackageDiscountEntity>> call({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
    int? perPage,
  }) {
    return _repository.getPackageDiscounts(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
      status: status,
      search: search,
      perPage: perPage,
    );
  }
}

