import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام جلب سجل دفتر الأستاذ لمحفظة نقطة البيع (GetPosWalletLogsUseCase)
/// ============================================================================
class GetPosWalletLogsUseCase {
  final PartnersRepository _repository;

  const GetPosWalletLogsUseCase(this._repository);

  Future<List<PosWalletLogEntity>> call({
    required int networkId,
    required int posId,
    int page = 1,
    int perPage = 20,
  }) {
    return _repository.getPosWalletLogs(
      networkId: networkId,
      posId: posId,
      page: page,
      perPage: perPage,
    );
  }
}
