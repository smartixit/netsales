import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/repositories/repayment_document_repository.dart';

/// Coordinates export, sharing, and printing for an official repayment.
class RepaymentDocumentUseCase {
  const RepaymentDocumentUseCase(this.repository);

  final RepaymentDocumentRepository repository;

  Future<bool> exportAndSave(PosRepaymentEntity repayment) {
    return repository.exportAndSave(repayment);
  }

  Future<bool> share(PosRepaymentEntity repayment) {
    return repository.share(repayment);
  }

  Future<bool> print(PosRepaymentEntity repayment) {
    return repository.print(repayment);
  }
}
