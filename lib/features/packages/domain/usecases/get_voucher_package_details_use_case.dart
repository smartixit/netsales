import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام جلب تفاصيل باقة كروت (GetVoucherPackageDetailsUseCase)
/// ============================================================================
class GetVoucherPackageDetailsUseCase {
  final PackagesRepository repository;

  const GetVoucherPackageDetailsUseCase(this.repository);

  Future<VoucherPackageEntity> call(int packageId) {
    return repository.getVoucherPackageDetails(packageId);
  }
}
