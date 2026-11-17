import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// Loads the active custom discount snapshots for every package available to one POS.
class GetEffectivePackageDiscountsForPosUseCase {
  final PackageCatalogRepository repository;

  const GetEffectivePackageDiscountsForPosUseCase(this.repository);

  Future<List<EffectivePackageDiscountEntity>> call({
    required int networkId,
    required int posId,
  }) {
    return repository.getEffectiveDiscountsForPos(
      networkId: networkId,
      posId: posId,
    );
  }
}
