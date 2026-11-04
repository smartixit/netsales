import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class TogglePackageStatusUseCase {
  final PackagesRepository _repository;

  const TogglePackageStatusUseCase(this._repository);

  Future<VoucherPackageEntity> call(int packageId) {
    return _repository.togglePackageStatus(packageId);
  }
}

