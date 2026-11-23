import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام جلب الخصومات الفعالة المخصصة لنقطة بيع وشبكة
class GetEffectivePackageDiscountsForPosUseCase {
  final PackageCatalogRepository _repository;

  const GetEffectivePackageDiscountsForPosUseCase(this._repository);

  Future<List<EffectivePackageDiscountEntity>> call({
    required int networkId,
    required int posId,
  }) {
    return _repository.getEffectiveDiscountsForPos(
      networkId: networkId,
      posId: posId,
    );
  }
}
