import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة الخصومات المخصصة لنقاط البيع (GetVoucherPackageDiscountsUseCase)
/// ============================================================================
class GetVoucherPackageDiscountsUseCase {
  final PackagesRepository repository;

  const GetVoucherPackageDiscountsUseCase(this.repository);

  Future<List<VoucherPackageDiscountEntity>> call({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
  }) {
    return repository.getVoucherPackageDiscounts(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
      status: status,
      search: search,
    );
  }
}
