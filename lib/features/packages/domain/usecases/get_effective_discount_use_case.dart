import 'package:netsales/features/packages/domain/entities/effective_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

class GetEffectiveDiscountUseCase {
  final PackagesRepository _repository;

  const GetEffectiveDiscountUseCase(this._repository);

  Future<EffectiveDiscountEntity> call({
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

