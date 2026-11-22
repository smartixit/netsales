import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/network_wallet_repository.dart';

/// حالة استخدام جلب بيانات محفظة مزود الشبكة بواسطة معرف الشبكة
class GetNetworkWalletUseCase {
  final NetworkWalletRepository _repository;

  const GetNetworkWalletUseCase(this._repository);

  Future<NetworkWalletEntity> call(int networkId) {
    return _repository.getWalletByNetworkId(networkId);
  }
}
