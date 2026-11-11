import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/billing/data/models/billing_models.dart';

abstract interface class BillingRemoteDataSource {
  Future<ApiResponse<List<BillingCurrencyModel>>> getCurrencies();
  Future<ApiResponse<List<BillingAccountModel>>> getAccounts(int networkId);
  Future<ApiResponse<List<BillingPlanModel>>> getPlans(int accountId);
  Future<ApiResponse<BillingPurchaseResultModel>> purchaseSubscription(int accountId, int priceId);
  Future<ApiResponse<List<BillingPaymentMethodModel>>> getPaymentMethods(int accountId);
  Future<ApiResponse<BillingPaymentModel>> submitInvoicePayment({required int invoiceId, required int paymentMethodId, required int amountMinor, required String idempotencyKey, String? externalReference, String? proofPath});
  Future<ApiResponse<BillingAccountModel>> createAccount(
    int networkId,
    int currencyId,
  );
  Future<ApiResponse<List<BillingSubscriptionModel>>> getSubscriptions(int accountId, {String? cursor});
  Future<ApiResponse<List<BillingInvoiceModel>>> getInvoices(int accountId, {String? cursor});
  Future<ApiResponse<List<BillingPaymentModel>>> getPayments(int accountId, {String? cursor});
  Future<ApiResponse<List<BillingCreditNoteModel>>> getCreditNotes(int accountId, {String? cursor});
  Future<ApiResponse<List<BillingRefundModel>>> getRefunds(int accountId, {String? cursor});
  Future<ApiResponse<BillingStatementModel>> getStatement(int accountId, {String? from, String? to, int? currencyId});
}
