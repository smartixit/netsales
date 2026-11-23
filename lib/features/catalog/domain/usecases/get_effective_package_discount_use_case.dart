import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام استرجاع الخصم الفعلي لباقة ونقطة بيع
class GetEffectivePackageDiscountUseCase {
  final PackageCatalogRepository _repository;

  const GetEffectivePackageDiscountUseCase(this._repository);

  Future<EffectivePackageDiscountEntity> call({
    required int networkId,
    required int posId,
    required int packageId,
  }) {
    return _repository.getEffectiveDiscount(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
    );
  }
}
