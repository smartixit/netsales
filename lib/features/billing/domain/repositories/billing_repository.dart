import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';

abstract interface class BillingRepository {
  Future<List<BillingCurrencyEntity>> getCurrencies();
  Future<List<BillingAccountEntity>> getAccounts(int networkId);
  Future<PaginatedList<BillingPlanEntity>> getPlans(int accountId);
  Future<BillingPurchaseResultEntity> purchaseSubscription(int accountId, int priceId);
  Future<List<BillingPaymentMethodEntity>> getPaymentMethods(int accountId);
  Future<BillingPaymentEntity> submitInvoicePayment({required int invoiceId, required int paymentMethodId, required int amountMinor, required String idempotencyKey, String? externalReference, String? proofPath});
  Future<BillingAccountEntity> createAccount(int networkId, int currencyId);
  Future<PaginatedList<BillingSubscriptionEntity>> getSubscriptions(int accountId, {String? cursor});
  Future<PaginatedList<BillingInvoiceEntity>> getInvoices(int accountId, {String? cursor});
  Future<PaginatedList<BillingPaymentEntity>> getPayments(int accountId, {String? cursor});
  Future<PaginatedList<BillingCreditNoteEntity>> getCreditNotes(int accountId, {String? cursor});
  Future<PaginatedList<BillingRefundEntity>> getRefunds(int accountId, {String? cursor});
  Future<BillingStatementEntity> getStatement(int accountId, {String? from, String? to, int? currencyId});
}
