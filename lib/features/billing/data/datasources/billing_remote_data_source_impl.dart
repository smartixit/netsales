import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/data/models/billing_models.dart';

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  const BillingRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<BillingCurrencyModel>>> getCurrencies() =>
      ApiService.instance.getList<BillingCurrencyModel>(
        ApiConstants.billingCurrencies,
        fromJson: (json) => BillingCurrencyModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 100,
      );

  @override
  Future<ApiResponse<List<BillingAccountModel>>> getAccounts(int networkId) =>
      ApiService.instance.getList<BillingAccountModel>(
        ApiConstants.networkBillingAccounts(networkId),
        fromJson: (json) => BillingAccountModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 50,
      );

  @override
  Future<ApiResponse<BillingAccountModel>> createAccount(
    int networkId,
    int currencyId,
  ) =>
      ApiService.instance.post<BillingAccountModel>(
        ApiConstants.networkBillingAccounts(networkId),
        data: {'currency_id': currencyId},
        fromJson: (json) => BillingAccountModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  @override
  Future<ApiResponse<List<BillingSubscriptionModel>>> getSubscriptions(int accountId) =>
      ApiService.instance.getList<BillingSubscriptionModel>(
        ApiConstants.billingAccountSubscriptions(accountId),
        fromJson: (json) => BillingSubscriptionModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
      );

  @override
  Future<ApiResponse<List<BillingInvoiceModel>>> getInvoices(int accountId) =>
      ApiService.instance.getList<BillingInvoiceModel>(
        ApiConstants.billingAccountInvoices(accountId),
        fromJson: (json) => BillingInvoiceModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
      );

  @override
  Future<ApiResponse<List<BillingPaymentModel>>> getPayments(int accountId) =>
      ApiService.instance.getList<BillingPaymentModel>(
        ApiConstants.billingAccountPayments(accountId),
        fromJson: (json) => BillingPaymentModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
      );

  @override
  Future<ApiResponse<List<BillingCreditNoteModel>>> getCreditNotes(int accountId) =>
      ApiService.instance.getList<BillingCreditNoteModel>(
        ApiConstants.billingAccountCreditNotes(accountId),
        fromJson: (json) => BillingCreditNoteModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
      );

  @override
  Future<ApiResponse<List<BillingRefundModel>>> getRefunds(int accountId) =>
      ApiService.instance.getList<BillingRefundModel>(
        ApiConstants.billingAccountRefunds(accountId),
        fromJson: (json) => BillingRefundModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
      );
}
