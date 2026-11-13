import 'package:netsales/core/models/api_response.dart';

abstract interface class BillingRemoteDataSource {
  Future<ApiResponse<Map<String, dynamic>>> getCurrencies();
  Future<ApiResponse<Map<String, dynamic>>> getNetworkAccounts(int networkId);
  Future<ApiResponse<Map<String, dynamic>>> createNetworkAccount(int networkId, int currencyId);
  Future<ApiResponse<Map<String, dynamic>>> getAccount(int accountId);
  Future<ApiResponse<Map<String, dynamic>>> updateAccount(int accountId, Map<String, dynamic> data);
  Future<ApiResponse<Map<String, dynamic>>> createContact(int accountId, Map<String, dynamic> data);
  Future<ApiResponse<Map<String, dynamic>>> updateContact(int accountId, int contactId, Map<String, dynamic> data);
  Future<ApiResponse<Map<String, dynamic>>> deleteContact(int accountId, int contactId);
  Future<ApiResponse<Map<String, dynamic>>> getPlans(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getEntitlements(int accountId);
  Future<ApiResponse<Map<String, dynamic>>> getReportsCatalog(int networkId);
  Future<ApiResponse<Map<String, dynamic>>> getBillingReport(int networkId, String type, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getBillingReportSummary(int networkId, String type, Map<String, dynamic> query);
  Future<Uint8List> exportBillingReport(int networkId, String type, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getTrialEligibility(int accountId, int priceId);
  Future<ApiResponse<Map<String, dynamic>>> purchase(int accountId, int priceId);
  Future<ApiResponse<Map<String, dynamic>>> getSubscriptions(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getSubscription(int subscriptionId);
  Future<ApiResponse<Map<String, dynamic>>> getSubscriptionEvents(int subscriptionId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getUsage(int subscriptionId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> cancelSubscription(int subscriptionId, bool atPeriodEnd);
  Future<ApiResponse<Map<String, dynamic>>> getInvoices(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getPayments(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getCreditNotes(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getRefunds(int accountId, Map<String, dynamic> query);
  Future<ApiResponse<Map<String, dynamic>>> getPaymentMethods(int accountId);
  Future<ApiResponse<Map<String, dynamic>>> recordPayment(int invoiceId, int paymentMethodId, int amountMinor, String idempotencyKey, String? externalReference, String? proofPath);
}
