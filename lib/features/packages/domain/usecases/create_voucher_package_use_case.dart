import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء باقة كروت جديدة (CreateVoucherPackageUseCase)
/// ============================================================================
class CreateVoucherPackageUseCase {
  final PackagesRepository repository;

  const CreateVoucherPackageUseCase(this.repository);

  Future<VoucherPackageEntity> call({
    required int networkId,
    required String packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    required double packageVoucherPrice,
    required double packageDefaultCashDiscount,
    required double packageDefaultCreditDiscount,
    bool? status,
  }) {
    return repository.createVoucherPackage(
      networkId: networkId,
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
