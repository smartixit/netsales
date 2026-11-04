import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class GetPackageDetailsUseCase {
  final PackagesRepository _repository;

  const GetPackageDetailsUseCase(this._repository);

  Future<VoucherPackageEntity> call(int packageId) {
    return _repository.getPackageDetails(packageId);
  }
}

