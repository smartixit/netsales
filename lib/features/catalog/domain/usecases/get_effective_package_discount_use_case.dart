import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام استرجاع الخصم الفعلي المعتمد لنقطة بيع على باقة من الخادم
class GetEffectivePackageDiscountUseCase {
  final PackageCatalogRepository repository;

  const GetEffectivePackageDiscountUseCase(this.repository);

  Future<EffectivePackageDiscountEntity> call({
    required int networkId,
    required int posId,
    required int packageId,
  }) {
    return repository.getEffectiveDiscount(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
    );
  }
}

