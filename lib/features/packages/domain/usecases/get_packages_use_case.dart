import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class GetPackagesUseCase {
  final PackagesRepository _repository;

  const GetPackagesUseCase(this._repository);

  Future<List<VoucherPackageEntity>> call({
    int? networkId,
    bool? status,
    String? search,
    int? perPage,
  }) {
    return _repository.getPackages(
      networkId: networkId,
      status: status,
      search: search,
      perPage: perPage,
    );
  }
}

