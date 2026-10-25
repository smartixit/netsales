import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام تحديث بيانات باقة كروت (UpdateVoucherPackageUseCase)
/// ============================================================================
class UpdateVoucherPackageUseCase {
  final PackagesRepository repository;

  const UpdateVoucherPackageUseCase(this.repository);

  Future<VoucherPackageEntity> call({
    required int packageId,
    String? packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    double? packageVoucherPrice,
    double? packageDefaultCashDiscount,
    double? packageDefaultCreditDiscount,
    bool? status,
  }) {
    return repository.updateVoucherPackage(
      packageId: packageId,
      packageName: packageName,
      packageColor: packageColor,
      packageBalance: packageBalance,
      packageUptime: packageUptime,
      packageValidity: packageValidity,
      packageVoucherCount: packageVoucherCount,
      packageVoucherPrice: packageVoucherPrice,
      packageDefaultCashDiscount: packageDefaultCashDiscount,
      packageDefaultCreditDiscount: packageDefaultCreditDiscount,
      status: status,
    );
  }
}
