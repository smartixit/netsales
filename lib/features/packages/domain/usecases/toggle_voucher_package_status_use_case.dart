import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام تبديل حالة تفعيل باقة الكروت (ToggleVoucherPackageStatusUseCase)
/// ============================================================================
class ToggleVoucherPackageStatusUseCase {
  final PackagesRepository repository;

  const ToggleVoucherPackageStatusUseCase(this.repository);

  Future<VoucherPackageEntity> call(int packageId) {
    return repository.toggleVoucherPackageStatus(packageId);
  }
}
