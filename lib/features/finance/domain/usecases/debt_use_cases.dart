import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

class GetDebtSummaryUseCase {
  final FinanceRepository repository;

  const GetDebtSummaryUseCase(this.repository);

  Future<DebtSummaryEntity> call({int? networkId, int? posId}) {
    return repository.getDebtSummary(networkId: networkId, posId: posId);
  }
}

class GetOutstandingInvoicesUseCase {
  final FinanceRepository repository;

  const GetOutstandingInvoicesUseCase(this.repository);

  Future<PaginatedList<InvoiceEntity>> call({
    int? networkId,
    int? posId,
    String? bucket,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getOutstandingInvoices(
      networkId: networkId,
      posId: posId,
      bucket: bucket,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

