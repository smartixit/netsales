import 'dart:typed_data';
import 'package:netsales/features/billing/domain/entities/billing_payload.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';

class BillingUseCases {
  const BillingUseCases(this.repository);
  final BillingRepository repository;
  Future<BillingPayload> currencies() => repository.getCurrencies();
  Future<BillingPayload> accounts(int networkId) => repository.getNetworkAccounts(networkId);
  Future<BillingPayload> createAccount(int networkId, int currencyId) => repository.createNetworkAccount(networkId, currencyId);
  Future<BillingPayload> account(int id) => repository.getAccount(id);
  Future<BillingPayload> updateAccount(int id, Map<String, dynamic> data) => repository.updateAccount(id, data);
  Future<BillingPayload> createContact(int id, Map<String, dynamic> data) => repository.createContact(id, data);
  Future<BillingPayload> updateContact(int id, int contactId, Map<String, dynamic> data) => repository.updateContact(id, contactId, data);
  Future<BillingPayload> deleteContact(int id, int contactId) => repository.deleteContact(id, contactId);
  Future<BillingPayload> plans(int id, Map<String, dynamic> query) => repository.getPlans(id, query);
  Future<BillingPayload> entitlements(int id) => repository.getEntitlements(id);
  Future<BillingPayload> reportsCatalog(int networkId) => repository.getReportsCatalog(networkId);
  Future<BillingPayload> billingReport(int networkId, String type, Map<String, dynamic> query) => repository.getBillingReport(networkId, type, query);
  Future<BillingPayload> billingReportSummary(int networkId, String type, Map<String, dynamic> query) => repository.getBillingReportSummary(networkId, type, query);
  Future<Uint8List> exportBillingReport(int networkId, String type, Map<String, dynamic> query) => repository.exportBillingReport(networkId, type, query);
  Future<BillingPayload> trialEligibility(int id, int priceId) => repository.getTrialEligibility(id, priceId);
  Future<BillingPayload> purchase(int id, int priceId) => repository.purchase(id, priceId);
  Future<BillingPayload> subscriptions(int id, Map<String, dynamic> query) => repository.getSubscriptions(id, query);
  Future<BillingPayload> subscription(int id) => repository.getSubscription(id);
  Future<BillingPayload> events(int id, Map<String, dynamic> query) => repository.getSubscriptionEvents(id, query);
  Future<BillingPayload> usage(int id, Map<String, dynamic> query) => repository.getUsage(id, query);
  Future<BillingPayload> cancel(int id, bool atPeriodEnd) => repository.cancelSubscription(id, atPeriodEnd);
  Future<BillingPayload> invoices(int id, Map<String, dynamic> query) => repository.getInvoices(id, query);
  Future<BillingPayload> payments(int id, Map<String, dynamic> query) => repository.getPayments(id, query);
  Future<BillingPayload> creditNotes(int id, Map<String, dynamic> query) => repository.getCreditNotes(id, query);
  Future<BillingPayload> refunds(int id, Map<String, dynamic> query) => repository.getRefunds(id, query);
  Future<BillingPayload> paymentMethods(int id) => repository.getPaymentMethods(id);
  Future<BillingPayload> recordPayment(int invoiceId, int methodId, int amountMinor, String key, String? reference, String? proofPath) =>
      repository.recordPayment(invoiceId, methodId, amountMinor, key, reference, proofPath);
}
