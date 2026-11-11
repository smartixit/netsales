import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';

enum BillingSection { overview, subscriptions, invoices, payments, credits, refunds }

class NetworkBillingController extends GetxController {
  NetworkBillingController({
    required this.getCurrencies,
    required this.getAccounts,
    required this.createAccount,
    required this.getSubscriptions,
    required this.getInvoices,
    required this.getPayments,
    required this.getCreditNotes,
    required this.getRefunds,
  });

  final GetBillingCurrenciesUseCase getCurrencies;
  final GetNetworkBillingAccountsUseCase getAccounts;
  final CreateNetworkBillingAccountUseCase createAccount;
  final GetBillingSubscriptionsUseCase getSubscriptions;
  final GetBillingInvoicesUseCase getInvoices;
  final GetBillingPaymentsUseCase getPayments;
  final GetBillingCreditNotesUseCase getCreditNotes;
  final GetBillingRefundsUseCase getRefunds;

  final isLoading = false.obs;
  final isCreatingAccount = false.obs;
  final errorMessage = RxnString();
  final currencies = <BillingCurrencyEntity>[].obs;
  final accounts = <BillingAccountEntity>[].obs;
  final selectedAccountId = RxnInt();
  final subscriptions = <BillingSubscriptionEntity>[].obs;
  final invoices = <BillingInvoiceEntity>[].obs;
  final payments = <BillingPaymentEntity>[].obs;
  final creditNotes = <BillingCreditNoteEntity>[].obs;
  final refunds = <BillingRefundEntity>[].obs;
  final selectedSection = BillingSection.overview.obs;

  int? get networkId => WorkspaceService.to.savedActiveNetworkId;
  BillingAccountEntity? get selectedAccount {
    final id = selectedAccountId.value;
    for (final account in accounts) {
      if (account.billingAccountId == id) return account;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final id = networkId;
    if (id == null) {
      errorMessage.value = 'تعذر تحديد الشبكة النشطة. اختر شبكة أولاً.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        getCurrencies(),
        getAccounts(id),
      ]);
      currencies.assignAll(results[0] as List<BillingCurrencyEntity>);
      accounts.assignAll(results[1] as List<BillingAccountEntity>);
      if (accounts.isEmpty) {
        selectedAccountId.value = null;
        _clearHistory();
      } else {
        final current = selectedAccountId.value;
        selectedAccountId.value = accounts.any((a) => a.billingAccountId == current)
            ? current
            : accounts.first.billingAccountId;
        await loadAccountHistory();
      }
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل بيانات فوترة الشبكة.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAccount(int? accountId) async {
    if (accountId == null || accountId == selectedAccountId.value) return;
    selectedAccountId.value = accountId;
    await loadAccountHistory();
  }

  Future<void> loadAccountHistory() async {
    final id = selectedAccountId.value;
    if (id == null) {
      _clearHistory();
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future.wait([
        getSubscriptions(id).then((page) => subscriptions.assignAll(page.items)),
        getInvoices(id).then((page) => invoices.assignAll(page.items)),
        getPayments(id).then((page) => payments.assignAll(page.items)),
        getCreditNotes(id).then((page) => creditNotes.assignAll(page.items)),
        getRefunds(id).then((page) => refunds.assignAll(page.items)),
      ]);
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل سجل الاشتراكات والفواتير.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBillingAccount(int currencyId) async {
    final id = networkId;
    if (id == null || isCreatingAccount.value) return;
    isCreatingAccount.value = true;
    errorMessage.value = null;
    try {
      final created = await createAccount(id, currencyId);
      accounts.add(created);
      selectedAccountId.value = created.billingAccountId;
      await loadAccountHistory();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر إنشاء حساب الفوترة.',
      );
    } finally {
      isCreatingAccount.value = false;
    }
  }

  void selectSection(BillingSection section) => selectedSection.value = section;

  void _clearHistory() {
    subscriptions.clear();
    invoices.clear();
    payments.clear();
    creditNotes.clear();
    refunds.clear();
  }
}
