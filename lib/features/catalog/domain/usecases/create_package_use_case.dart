import 'package:netsales/features/catalog/domain/entities/create_package_input.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام إنشاء باقة كروت إنترنت جديدة عبر كائن النطاق المحدد النوع
class CreatePackageUseCase {
  final PackageCatalogRepository _repository;

  const CreatePackageUseCase(this._repository);

  Future<PackageEntity> call(CreatePackageInput input) {
    return _repository.createPackage(input);
  }
}
