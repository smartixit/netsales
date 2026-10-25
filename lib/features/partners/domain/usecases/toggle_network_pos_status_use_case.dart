import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام تبديل حالة عقد ربط الشبكة بنقطة البيع (ToggleNetworkPosStatusUseCase)
/// ============================================================================
class ToggleNetworkPosStatusUseCase {
  final PartnersRepository _repository;

  const ToggleNetworkPosStatusUseCase(this._repository);

  Future<bool> call(int networkPosId) {
    return _repository.toggleNetworkPosStatus(networkPosId);
  }
}
