import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  const BillingRemoteDataSourceImpl();

  Map<String, dynamic> _map(dynamic value) {
    if (value is List) {
      return {'data': value.map((row) {
        if (row is! Map) throw const FormatException('سجل الفوترة غير صالح.');
        return Map<String, dynamic>.from(row);
      }).toList(growable: false)};
    }
    if (value is! Map) throw const FormatException('استجابة الفوترة غير صالحة.');
    return Map<String, dynamic>.from(value);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCurrencies() =>
      ApiService.instance.get(ApiConstants.billingCurrencies, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getNetworkAccounts(int networkId) =>
      ApiService.instance.get(ApiConstants.billingNetworkAccounts(networkId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getAccount(int accountId) =>
      ApiService.instance.get(ApiConstants.billingAccount(accountId), fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateAccount(int accountId, Map<String, dynamic> data) =>
      ApiService.instance.put(ApiConstants.billingAccount(accountId), data: data, fromJson: _map);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPlans(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountPlans(accountId), queryParameters: query, fromJson: _map);

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
  Future<ApiResponse<Map<String, dynamic>>> getPayments(int accountId, Map<String, dynamic> query) =>
      ApiService.instance.get(ApiConstants.billingAccountPayments(accountId), queryParameters: query, fromJson: _map);
}
