import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام حذف باقة كروت (DeleteVoucherPackageUseCase)
/// ============================================================================
class DeleteVoucherPackageUseCase {
  final PackagesRepository repository;

  const DeleteVoucherPackageUseCase(this.repository);

  Future<bool> call(int packageId) {
    return repository.deleteVoucherPackage(packageId);
  }
}
