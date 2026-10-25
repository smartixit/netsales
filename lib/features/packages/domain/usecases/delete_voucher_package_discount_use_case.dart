import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام حذف خصم مخصص لنقطة بيع (DeleteVoucherPackageDiscountUseCase)
/// ============================================================================
class DeleteVoucherPackageDiscountUseCase {
  final PackagesRepository repository;

  const DeleteVoucherPackageDiscountUseCase(this.repository);

  Future<bool> call(int discountId) {
    return repository.deleteVoucherPackageDiscount(discountId);
  }
}
