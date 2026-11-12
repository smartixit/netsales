import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/repositories/repayment_document_repository.dart';

/// Coordinates export, sharing, and printing for an official repayment.
class RepaymentDocumentUseCase {
  const RepaymentDocumentUseCase(this.repository);

  final RepaymentDocumentRepository repository;

  Future<bool> exportAndSave(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) {
    return repository.exportAndSave(
      repayment,
      isNetworkView: isNetworkView,
    );
  }

  Future<bool> share(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) {
    return repository.share(repayment, isNetworkView: isNetworkView);
  }

  Future<bool> print(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) {
    return repository.print(repayment, isNetworkView: isNetworkView);
  }
}
