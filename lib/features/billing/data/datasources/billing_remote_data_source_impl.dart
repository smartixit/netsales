import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  const BillingRemoteDataSourceImpl();

  Map<String, dynamic> _map(dynamic value) {
    if (value is List) {
      return {'data': value.map((row) {
        if (row is! Map<String, dynamic>) throw const FormatException('سجل الفوترة غير صالح.');
        return Map<String, dynamic>.from(row);
      }).toList(growable: false)};
    }
    if (value is! Map<String, dynamic>) throw const FormatException('استجابة الفوترة غير صالحة.');
    return Map<String, dynamic>.from(value);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCurrencies() =>
      ApiService.instance.get(ApiConstants.billingCurrencies, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getNetworkAccounts(int networkId) =>
      ApiService.instance.get(ApiConstants.billingNetworkAccounts(networkId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> createNetworkAccount(int networkId, int currencyId) =>
      ApiService.instance.post(ApiConstants.billingNetworkAccounts(networkId), data: {'currency_id': currencyId}, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getAccount(int accountId) =>
      ApiService.instance.get(ApiConstants.billingAccount(accountId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateAccount(int accountId, Map<String, dynamic> data) =>
      ApiService.instance.put(ApiConstants.billingAccount(accountId), data: data, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> createContact(int accountId, Map<String, dynamic> data) =>
      ApiService.instance.post('/billing/accounts/$accountId/contacts', data: data, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateContact(int accountId, int contactId, Map<String, dynamic> data) =>
      ApiService.instance.put('/billing/accounts/$accountId/contacts/$contactId', data: data, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> deleteContact(int accountId, int contactId) =>
      ApiService.instance.delete('/billing/accounts/$accountId/contacts/$contactId', fromJson: (_) => <String, dynamic>{});

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPlans(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountPlans(accountId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getEntitlements(int accountId) =>
      ApiService.instance.get(ApiConstants.billingAccountEntitlements(accountId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getReportsCatalog(int networkId) =>
      ApiService.instance.get(ApiConstants.billingNetworkReportsCatalog(networkId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getBillingReport(int networkId, String type, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingNetworkReport(networkId, type), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getBillingReportSummary(int networkId, String type, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingNetworkReportSummary(networkId, type), queryParameters: query, fromJson: _map);

  @override
  Future<Uint8List> exportBillingReport(int networkId, String type, Map<String, dynamic> query) async {
    final response = await ApiService.instance.dio.get<List<int>>(
      ApiConstants.billingNetworkReportExport(networkId, type),
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) throw const FormatException('ملف التقرير فارغ.');
    return Uint8List.fromList(bytes);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTrialEligibility(int accountId, int priceId) =>
      ApiService.instance.get(ApiConstants.billingTrialEligibility(accountId, priceId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> purchase(int accountId, int priceId) =>
      ApiService.instance.post(ApiConstants.billingPurchase(accountId), data: {'price_id': priceId}, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getSubscriptions(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountSubscriptions(accountId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getSubscription(int subscriptionId) =>
      ApiService.instance.get(ApiConstants.billingSubscription(subscriptionId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getSubscriptionEvents(int subscriptionId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingSubscriptionEvents(subscriptionId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getUsage(int subscriptionId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingSubscriptionUsage(subscriptionId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> cancelSubscription(int subscriptionId, bool atPeriodEnd) =>
      ApiService.instance.post(ApiConstants.billingCancelSubscription(subscriptionId), data: {'at_period_end': atPeriodEnd}, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getInvoices(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountInvoices(accountId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCreditNotes(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountCreditNotes(accountId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRefunds(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountRefunds(accountId), queryParameters: query, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPaymentMethods(int accountId) =>
      ApiService.instance.get(ApiConstants.billingAccountPaymentMethods(accountId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> recordPayment(
    int invoiceId,
    int paymentMethodId,
    int amountMinor,
    String idempotencyKey,
    String? externalReference,
    String? proofPath,
  ) async {
    final data = FormData.fromMap({
      'payment_method_id': paymentMethodId,
      'amount_minor': amountMinor,
      'idempotency_key': idempotencyKey,
      if (externalReference != null && externalReference.trim().isNotEmpty) 'external_reference': externalReference.trim(),
      if (proofPath != null) 'proof': await MultipartFile.fromFile(proofPath),
    });
    return ApiService.instance.post(
      ApiConstants.billingInvoicePayments(invoiceId),
      data: data,
      fromJson: _map,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPayments(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountPayments(accountId), queryParameters: query, fromJson: _map);
}
