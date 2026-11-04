import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class DeletePackageUseCase {
  final PackagesRepository _repository;

  const DeletePackageUseCase(this._repository);

  Future<bool> call(int packageId) {
    return _repository.deletePackage(packageId);
  }
}

