import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/billing/data/models/billing_models.dart';

abstract interface class BillingRemoteDataSource {
  Future<ApiResponse<List<BillingCurrencyModel>>> getCurrencies();
  Future<ApiResponse<List<BillingAccountModel>>> getAccounts(int networkId);
  Future<ApiResponse<BillingAccountModel>> createAccount(
    int networkId,
    int currencyId,
  );
  Future<ApiResponse<List<BillingSubscriptionModel>>> getSubscriptions(int accountId);
  Future<ApiResponse<List<BillingInvoiceModel>>> getInvoices(int accountId);
  Future<ApiResponse<List<BillingPaymentModel>>> getPayments(int accountId);
  Future<ApiResponse<List<BillingCreditNoteModel>>> getCreditNotes(int accountId);
  Future<ApiResponse<List<BillingRefundModel>>> getRefunds(int accountId);
}
