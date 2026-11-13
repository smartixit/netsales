import 'package:netsales/features/finance/data/services/repayment_document_service.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/repositories/repayment_document_repository.dart';

/// Infrastructure adapter for generating and delivering repayment receipts.
class RepaymentDocumentRepositoryImpl implements RepaymentDocumentRepository {
  const RepaymentDocumentRepositoryImpl({required this.documentService});

  final RepaymentDocumentService documentService;

  @override
  Future<bool> exportAndSave(
    PosRepaymentEntity repayment,
  ) async {
    final result = await documentService.exportAndSave(repayment);
    return result.isSuccess;
  }

  @override
  Future<bool> share(PosRepaymentEntity repayment) {
    return documentService.share(repayment);
  }

  @override
  Future<bool> print(PosRepaymentEntity repayment) {
    return documentService.print(repayment);
  }
}
