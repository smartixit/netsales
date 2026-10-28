import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام استرجاع محفظة نقطة البيع المشتركة مع الشبكة (GetPosWalletUseCase)
/// ============================================================================
class GetPosWalletUseCase {
  final PartnersRepository _repository;

  const GetPosWalletUseCase(this._repository);

  Future<PosWalletEntity?> call({
    required int networkId,
    required int posId,
  }) {
    return _repository.getPosWallet(
      networkId: networkId,
      posId: posId,
    );
  }
}
