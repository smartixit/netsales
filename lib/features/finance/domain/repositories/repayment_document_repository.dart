import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';

/// Output boundary for official repayment receipts.
abstract interface class RepaymentDocumentRepository {
  Future<bool> exportAndSave(
    PosRepaymentEntity repayment);

  Future<bool> share(
    PosRepaymentEntity repayment);

  Future<bool> print(
    PosRepaymentEntity repayment);
}
