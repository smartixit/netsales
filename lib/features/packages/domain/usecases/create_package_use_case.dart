import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class CreatePackageUseCase {
  final PackagesRepository _repository;

  const CreatePackageUseCase(this._repository);

  Future<VoucherPackageEntity> call(Map<String, dynamic> data) {
    return _repository.createPackage(data);
  }
}

