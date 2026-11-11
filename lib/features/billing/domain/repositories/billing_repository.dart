import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';

abstract interface class BillingRepository {
  Future<List<BillingCurrencyEntity>> getCurrencies();
  Future<List<BillingAccountEntity>> getAccounts(int networkId);
  Future<BillingAccountEntity> createAccount(int networkId, int currencyId);
  Future<PaginatedList<BillingSubscriptionEntity>> getSubscriptions(int accountId);
  Future<PaginatedList<BillingInvoiceEntity>> getInvoices(int accountId);
  Future<PaginatedList<BillingPaymentEntity>> getPayments(int accountId);
  Future<PaginatedList<BillingCreditNoteEntity>> getCreditNotes(int accountId);
  Future<PaginatedList<BillingRefundEntity>> getRefunds(int accountId);
}
