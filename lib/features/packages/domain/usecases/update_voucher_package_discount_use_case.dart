import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام تحديث خصم مخصص لنقطة بيع (UpdateVoucherPackageDiscountUseCase)
/// ============================================================================
class UpdateVoucherPackageDiscountUseCase {
  final PackagesRepository repository;

  const UpdateVoucherPackageDiscountUseCase(this.repository);

  Future<VoucherPackageDiscountEntity> call({
    required int discountId,
    double? discountCash,
    double? discountCredit,
    bool? status,
  }) {
    return repository.updateVoucherPackageDiscount(
      discountId: discountId,
      discountCash: discountCash,
      discountCredit: discountCredit,
      status: status,
    );
  }
}
