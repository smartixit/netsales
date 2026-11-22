import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام تحديث السقف الائتماني لمحفظة نقطة البيع من قبل مزود الشبكة
class UpdatePosCreditLimitUseCase {
  final PosWalletRepository _repository;

  const UpdatePosCreditLimitUseCase(this._repository);

  Future<PosWalletEntity> call({
    required int walletId,
    required double? creditLimit,
  }) {
    return _repository.updateCreditLimit(
      walletId: walletId,
      creditLimit: creditLimit,
    );
  }
}
