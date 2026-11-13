import 'package:netsales/features/billing/domain/entities/billing_payload.dart';

abstract interface class BillingRepository {
  Future<BillingPayload> getCurrencies();
  Future<BillingPayload> getNetworkAccounts(int networkId);
  Future<BillingPayload> createNetworkAccount(int networkId, int currencyId);
  Future<BillingPayload> getAccount(int accountId);
  Future<BillingPayload> updateAccount(int accountId, Map<String, dynamic> data);
  Future<BillingPayload> getPlans(int accountId, Map<String, dynamic> query);
  Future<BillingPayload> getEntitlements(int accountId);
  Future<BillingPayload> getReportsCatalog(int networkId);
  Future<BillingPayload> getBillingReport(int networkId, String type, Map<String, dynamic> query);
  Future<BillingPayload> getBillingReportSummary(int networkId, String type, Map<String, dynamic> query);
  Future<BillingPayload> getTrialEligibility(int accountId, int priceId);
  Future<BillingPayload> purchase(int accountId, int priceId);
  Future<BillingPayload> getSubscriptions(int accountId, Map<String, dynamic> query);
  Future<BillingPayload> getSubscription(int subscriptionId);
  Future<BillingPayload> getSubscriptionEvents(int subscriptionId, Map<String, dynamic> query);
  Future<BillingPayload> getUsage(int subscriptionId, Map<String, dynamic> query);
  Future<BillingPayload> cancelSubscription(int subscriptionId, bool atPeriodEnd);
  Future<BillingPayload> getInvoices(int accountId, Map<String, dynamic> query);
  Future<BillingPayload> getPayments(int accountId, Map<String, dynamic> query);
}
