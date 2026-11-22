import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام جلب محفظة نقطة البيع بواسطة معرف الشبكة ونقطة البيع
class GetPosWalletByNetworkAndPosUseCase {
  final PosWalletRepository _repository;

  const GetPosWalletByNetworkAndPosUseCase(this._repository);

  Future<PosWalletEntity> call({required int networkId, required int posId}) {
    return _repository.getWalletByNetworkAndPos(
      networkId: networkId,
      posId: posId,
    );
  }
}
