import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';

/// Output boundary for official repayment receipts.
abstract interface class RepaymentDocumentRepository {
  Future<bool> exportAndSave(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  });

  Future<bool> share(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  });

  Future<bool> print(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  });
}
