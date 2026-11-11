import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';

class GetBillingCurrenciesUseCase {
  const GetBillingCurrenciesUseCase(this.repository);
  final BillingRepository repository;
  Future<List<BillingCurrencyEntity>> call() => repository.getCurrencies();
}

class GetNetworkBillingAccountsUseCase {
  const GetNetworkBillingAccountsUseCase(this.repository);
  final BillingRepository repository;
  Future<List<BillingAccountEntity>> call(int networkId) =>
      repository.getAccounts(networkId);
}

class CreateNetworkBillingAccountUseCase {
  const CreateNetworkBillingAccountUseCase(this.repository);
  final BillingRepository repository;
  Future<BillingAccountEntity> call(int networkId, int currencyId) =>
      repository.createAccount(networkId, currencyId);
}

class GetBillingSubscriptionsUseCase {
  const GetBillingSubscriptionsUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingSubscriptionEntity>> call(int accountId, {String? cursor}) =>
      repository.getSubscriptions(accountId, cursor: cursor);
}

class GetBillingInvoicesUseCase {
  const GetBillingInvoicesUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingInvoiceEntity>> call(int accountId, {String? cursor}) =>
      repository.getInvoices(accountId, cursor: cursor);
}

class GetBillingPaymentsUseCase {
  const GetBillingPaymentsUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingPaymentEntity>> call(int accountId, {String? cursor}) =>
      repository.getPayments(accountId, cursor: cursor);
}

class GetBillingCreditNotesUseCase {
  const GetBillingCreditNotesUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingCreditNoteEntity>> call(int accountId, {String? cursor}) =>
      repository.getCreditNotes(accountId, cursor: cursor);
}

class GetBillingRefundsUseCase {
  const GetBillingRefundsUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingRefundEntity>> call(int accountId, {String? cursor}) =>
      repository.getRefunds(accountId, cursor: cursor);
}

class GetBillingStatementUseCase {
  const GetBillingStatementUseCase(this.repository);
  final BillingRepository repository;
  Future<BillingStatementEntity> call(
    int accountId, {
    String? from,
    String? to,
    int? currencyId,
  }) => repository.getStatement(
    accountId,
    from: from,
    to: to,
    currencyId: currencyId,
  );
}

class GetNetworkBillingPlansUseCase {
  const GetNetworkBillingPlansUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingPlanEntity>> call(int accountId) =>
      repository.getPlans(accountId);
}

class PurchaseNetworkSubscriptionUseCase {
  const PurchaseNetworkSubscriptionUseCase(this.repository);
  final BillingRepository repository;
  Future<BillingPurchaseResultEntity> call(int accountId, int priceId) =>
      repository.purchaseSubscription(accountId, priceId);
}
