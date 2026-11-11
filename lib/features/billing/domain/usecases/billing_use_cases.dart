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
  Future<PaginatedList<BillingSubscriptionEntity>> call(int accountId) =>
      repository.getSubscriptions(accountId);
}

class GetBillingInvoicesUseCase {
  const GetBillingInvoicesUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingInvoiceEntity>> call(int accountId) =>
      repository.getInvoices(accountId);
}

class GetBillingPaymentsUseCase {
  const GetBillingPaymentsUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingPaymentEntity>> call(int accountId) =>
      repository.getPayments(accountId);
}

class GetBillingCreditNotesUseCase {
  const GetBillingCreditNotesUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingCreditNoteEntity>> call(int accountId) =>
      repository.getCreditNotes(accountId);
}

class GetBillingRefundsUseCase {
  const GetBillingRefundsUseCase(this.repository);
  final BillingRepository repository;
  Future<PaginatedList<BillingRefundEntity>> call(int accountId) =>
      repository.getRefunds(accountId);
}
