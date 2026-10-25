import 'package:netsales/features/packages/domain/entities/effective_discount_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// حالة استخدام احتساب الخصم الفعلي لنقطة بيع على باقة (GetEffectiveDiscountUseCase)
/// ============================================================================
class GetEffectiveDiscountUseCase {
  final PackagesRepository repository;

  const GetEffectiveDiscountUseCase(this.repository);

  Future<EffectiveDiscountEntity> call({
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
