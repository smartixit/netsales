import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class GetNetworkPackagesUseCase {
  final PackagesRepository _repository;

  const GetNetworkPackagesUseCase(this._repository);

  Future<List<VoucherPackageEntity>> call(int networkId, {bool? status}) {
    return _repository.getNetworkPackages(networkId, status: status);
  }
}

