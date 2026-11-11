import 'package:dio/dio.dart';
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
  Future<ApiResponse<List<BillingPlanModel>>> getPlans(int accountId) =>
      ApiService.instance.getList<BillingPlanModel>(
        ApiConstants.billingAccountPlans(accountId),
        fromJson: (json) => BillingPlanModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 50,
      );

  @override
  Future<ApiResponse<List<BillingSubscriptionModel>>> getSubscriptions(int accountId, {String? cursor}) =>
      ApiService.instance.getList<BillingSubscriptionModel>(
        ApiConstants.billingAccountSubscriptions(accountId),
        fromJson: (json) => BillingSubscriptionModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
        cursor: cursor,
      );

  @override
  Future<ApiResponse<List<BillingInvoiceModel>>> getInvoices(int accountId, {String? cursor}) =>
      ApiService.instance.getList<BillingInvoiceModel>(
        ApiConstants.billingAccountInvoices(accountId),
        fromJson: (json) => BillingInvoiceModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
        cursor: cursor,
      );

  @override
  Future<ApiResponse<List<BillingPaymentModel>>> getPayments(int accountId, {String? cursor}) =>
      ApiService.instance.getList<BillingPaymentModel>(
        ApiConstants.billingAccountPayments(accountId),
        fromJson: (json) => BillingPaymentModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
        cursor: cursor,
      );

  @override
  Future<ApiResponse<List<BillingCreditNoteModel>>> getCreditNotes(int accountId, {String? cursor}) =>
      ApiService.instance.getList<BillingCreditNoteModel>(
        ApiConstants.billingAccountCreditNotes(accountId),
        fromJson: (json) => BillingCreditNoteModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
        cursor: cursor,
      );

  @override
  Future<ApiResponse<List<BillingRefundModel>>> getRefunds(int accountId, {String? cursor}) =>
      ApiService.instance.getList<BillingRefundModel>(
        ApiConstants.billingAccountRefunds(accountId),
        fromJson: (json) => BillingRefundModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 15,
        cursor: cursor,
      );

  @override
  Future<ApiResponse<List<BillingPaymentMethodModel>>> getPaymentMethods(int accountId) =>
      ApiService.instance.getList<BillingPaymentMethodModel>(
        ApiConstants.billingAccountPaymentMethods(accountId),
        fromJson: (json) => BillingPaymentMethodModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        perPage: 50,
      );

  @override
  Future<ApiResponse<BillingPaymentModel>> submitInvoicePayment({
    required int invoiceId,
    required int paymentMethodId,
    required int amountMinor,
    required String idempotencyKey,
    String? externalReference,
    String? proofPath,
  }) async {
    final fields = <String, dynamic>{
      'payment_method_id': paymentMethodId,
      'amount_minor': amountMinor,
      'idempotency_key': idempotencyKey,
      if (externalReference != null && externalReference.trim().isNotEmpty)
        'external_reference': externalReference.trim(),
    };
    dynamic payload = fields;
    if (proofPath != null && proofPath.trim().isNotEmpty) {
      payload = FormData.fromMap({
        ...fields,
        'proof': await MultipartFile.fromFile(proofPath),
      });
    }
    return ApiService.instance.post<BillingPaymentModel>(
      ApiConstants.billingInvoicePayments(invoiceId),
      data: payload,
      idempotencyKey: idempotencyKey,
      fromJson: (json) => BillingPaymentModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<BillingStatementModel>> getStatement(
    int accountId, {
    String? from,
    String? to,
    int? currencyId,
  }) =>
      ApiService.instance.get<BillingStatementModel>(
        ApiConstants.billingAccountStatement(accountId),
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (currencyId != null) 'currency_id': currencyId,
        },
        fromJson: (json) => BillingStatementModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );

  @override
  Future<ApiResponse<BillingPurchaseResultModel>> purchaseSubscription(
    int accountId,
    int priceId,
  ) =>
      ApiService.instance.post<BillingPurchaseResultModel>(
        ApiConstants.billingAccountSubscriptions(accountId),
        data: {'price_id': priceId},
        fromJson: (json) => BillingPurchaseResultModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );
