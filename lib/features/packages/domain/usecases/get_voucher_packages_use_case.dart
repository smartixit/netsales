import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة باقات الكروت (GetVoucherPackagesUseCase)
/// ============================================================================
class GetVoucherPackagesUseCase {
  final PackagesRepository repository;

  const GetVoucherPackagesUseCase(this.repository);

  Future<List<VoucherPackageEntity>> call({
    int? networkId,
    bool? status,
    String? search,
  }) {
    return repository.getVoucherPackages(
      networkId: networkId,
      status: status,
      search: search,
    );
  }
}
