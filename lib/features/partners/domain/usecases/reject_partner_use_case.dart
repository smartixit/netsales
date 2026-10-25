import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';
import 'package:netsales/features/partners/domain/usecases/approve_partner_use_case.dart';

/// ============================================================================
/// حالة استخدام رفض طلب الشريك (شبكة أو نقطة بيع) (RejectPartnerUseCase)
/// ============================================================================
class RejectPartnerUseCase {
  final PartnersRepository _repository;

  const RejectPartnerUseCase(this._repository);

  Future<bool> call({
    required int id,
    required PartnerType type,
    required String reason,
  }) {
    switch (type) {
      case PartnerType.network:
        return _repository.rejectNetwork(id, reason);
      case PartnerType.pos:
        return _repository.rejectPos(id, reason);
    }
  }
}
