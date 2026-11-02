import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';

class GetOutstandingInvoicesUseCase {
  final DebtsRepository repository;

  const GetOutstandingInvoicesUseCase(this.repository);

  Future<ApiResponse<List<PosOutstandingInvoiceEntity>>> call({
    required int networkId,
    required int posId,
  }) {
    return repository.getOutstandingInvoices(networkId: networkId, posId: posId);
  }
}

