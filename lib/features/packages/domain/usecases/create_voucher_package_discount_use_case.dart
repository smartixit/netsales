import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء خصم مخصص لنقطة بيع (CreateVoucherPackageDiscountUseCase)
/// ============================================================================
class CreateVoucherPackageDiscountUseCase {
  final PackagesRepository repository;

  const CreateVoucherPackageDiscountUseCase(this.repository);

  Future<VoucherPackageDiscountEntity> call({
    required int networkId,
    required int posId,
    required int packageId,
    required double discountCash,
    required double discountCredit,
    bool? status,
  }) {
    return repository.createVoucherPackageDiscount(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
      discountCash: discountCash,
      discountCredit: discountCredit,
      status: status,
    );
  }
}
