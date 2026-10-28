import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام التحويل المالي المشترك لمحفظة نقطة البيع (TransferPosWalletBalanceUseCase)
/// ============================================================================
class TransferPosWalletBalanceUseCase {
  final PartnersRepository _repository;

  const TransferPosWalletBalanceUseCase(this._repository);

  /// تحويل من الشبكة إلى نقطة البيع (تغذية رصيد)
  Future<bool> transferFromNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) {
    return _repository.transferNetworkToPos(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
    );
  }

  /// تحويل / توريد من نقطة البيع إلى الشبكة
  Future<bool> transferToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) {
    return _repository.transferPosToNetwork(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
    );
  }
}
