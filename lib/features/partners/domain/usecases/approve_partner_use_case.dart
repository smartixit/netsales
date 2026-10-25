import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// نوع الشريك للاعتماد
enum PartnerType {
  network,
  pos,
}

/// ============================================================================
/// حالة استخدام اعتماد الشريك (شبكة أو نقطة بيع) (ApprovePartnerUseCase)
/// ============================================================================
class ApprovePartnerUseCase {
  final PartnersRepository _repository;

  const ApprovePartnerUseCase(this._repository);

  Future<bool> call({
    required int id,
    required PartnerType type,
  }) {
    switch (type) {
      case PartnerType.network:
        return _repository.approveNetwork(id);
      case PartnerType.pos:
        return _repository.approvePos(id);
    }
  }
}
