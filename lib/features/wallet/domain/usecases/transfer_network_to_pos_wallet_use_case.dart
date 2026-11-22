import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// حالة استخدام تحويل وتغذية رصيد من محفظة الشبكة إلى محفظة نقطة البيع
class TransferNetworkToPosWalletUseCase {
  final PosWalletRepository _repository;

  const TransferNetworkToPosWalletUseCase(this._repository);

  Future<PosWalletEntity> call({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) {
    return _repository.transferFromNetwork(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
    );
  }
}
