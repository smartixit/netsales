import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام تبديل حالة تفعيل خصم مخصص (ToggleVoucherPackageDiscountStatusUseCase)
/// ============================================================================
class ToggleVoucherPackageDiscountStatusUseCase {
  final PackagesRepository repository;

  const ToggleVoucherPackageDiscountStatusUseCase(this.repository);

  Future<VoucherPackageDiscountEntity> call(int discountId) {
    return repository.toggleVoucherPackageDiscountStatus(discountId);
  }
}
