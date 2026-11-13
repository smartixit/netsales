import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/domain/entities/billing_payload.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(this.remote);
  final BillingRemoteDataSource remote;

  BillingPayload _unwrap(dynamic response) {
    if (response == null || response.data == null || response.success != true) {
      throw Exception(response?.message ?? 'تعذر إتمام طلب الفوترة.');
    }
    return BillingPayload.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<BillingPayload> getCurrencies() async => _unwrap(await remote.getCurrencies());
  @override
  Future<BillingPayload> getNetworkAccounts(int id) async => _unwrap(await remote.getNetworkAccounts(id));
  @override
  Future<BillingPayload> createNetworkAccount(int networkId, int currencyId) async => _unwrap(await remote.createNetworkAccount(networkId, currencyId));
  @override
  Future<BillingPayload> getAccount(int id) async => _unwrap(await remote.getAccount(id));
  @override
  Future<BillingPayload> updateAccount(int id, Map<String, dynamic> data) async => _unwrap(await remote.updateAccount(id, data));
  @override
  Future<BillingPayload> getPlans(int id, Map<String, dynamic> query) async => _unwrap(await remote.getPlans(id, query));
  @override
  Future<BillingPayload> getTrialEligibility(int id, int priceId) async => _unwrap(await remote.getTrialEligibility(id, priceId));
  @override
  Future<BillingPayload> purchase(int id, int priceId) async => _unwrap(await remote.purchase(id, priceId));
  @override
  Future<BillingPayload> getSubscriptions(int id, Map<String, dynamic> query) async => _unwrap(await remote.getSubscriptions(id, query));
  @override
  Future<BillingPayload> getSubscription(int id) async => _unwrap(await remote.getSubscription(id));
  @override
  Future<BillingPayload> getSubscriptionEvents(int id, Map<String, dynamic> query) async => _unwrap(await remote.getSubscriptionEvents(id, query));
  @override
  Future<BillingPayload> getUsage(int id, Map<String, dynamic> query) async => _unwrap(await remote.getUsage(id, query));
  @override
  Future<BillingPayload> cancelSubscription(int id, bool atPeriodEnd) async => _unwrap(await remote.cancelSubscription(id, atPeriodEnd));
  @override
  Future<BillingPayload> getInvoices(int id, Map<String, dynamic> query) async => _unwrap(await remote.getInvoices(id, query));
  @override
  Future<BillingPayload> getPayments(int id, Map<String, dynamic> query) async => _unwrap(await remote.getPayments(id, query));
}
