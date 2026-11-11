import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
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
    required this.getStatement,
    required this.getPlans,
    required this.purchaseSubscription,
    required this.getPaymentMethods,
    required this.submitInvoicePayment,
  });

  final GetBillingCurrenciesUseCase getCurrencies;
  final GetNetworkBillingAccountsUseCase getAccounts;
  final CreateNetworkBillingAccountUseCase createAccount;
  final GetBillingSubscriptionsUseCase getSubscriptions;
  final GetBillingInvoicesUseCase getInvoices;
  final GetBillingPaymentsUseCase getPayments;
  final GetBillingCreditNotesUseCase getCreditNotes;
  final GetBillingRefundsUseCase getRefunds;
  final GetBillingStatementUseCase getStatement;
  final GetNetworkBillingPlansUseCase getPlans;
  final PurchaseNetworkSubscriptionUseCase purchaseSubscription;
  final GetNetworkBillingPaymentMethodsUseCase getPaymentMethods;
  final SubmitNetworkBillingInvoicePaymentUseCase submitInvoicePayment;

  final isLoading = false.obs;
  final isCreatingAccount = false.obs;
  final errorMessage = RxnString();
  final currencies = <BillingCurrencyEntity>[].obs;
  final accounts = <BillingAccountEntity>[].obs;
  final selectedAccountId = RxnInt();
  final selectedCurrencyId = RxnInt();
  final subscriptions = <BillingSubscriptionEntity>[].obs;
  final invoices = <BillingInvoiceEntity>[].obs;
  final payments = <BillingPaymentEntity>[].obs;
  final creditNotes = <BillingCreditNoteEntity>[].obs;
  final refunds = <BillingRefundEntity>[].obs;
  final plans = <BillingPlanEntity>[].obs;
  final paymentMethods = <BillingPaymentMethodEntity>[].obs;
  final selectedPaymentMethodId = RxnInt();
  final paymentAmountController = TextEditingController();
  final paymentReferenceController = TextEditingController();
  final selectedProofPath = RxnString();
  final isSubmittingPayment = false.obs;
  final isPurchasing = false.obs;
  final Rxn<BillingPurchaseResultEntity> lastPurchase = Rxn<BillingPurchaseResultEntity>();
  final statement = Rxn<BillingStatementEntity>();
  final selectedSection = BillingSection.overview.obs;

  final isLoadingMoreSubscriptions = false.obs;
  final isLoadingMoreInvoices = false.obs;
  final isLoadingMorePayments = false.obs;
  final isLoadingMoreCreditNotes = false.obs;
  final isLoadingMoreRefunds = false.obs;

  String? _subscriptionsCursor;
  String? _invoicesCursor;
  String? _paymentsCursor;
  String? _creditNotesCursor;
  String? _refundsCursor;
  int _requestRevision = 0;

  bool get canLoadMoreSubscriptions => _hasCursor(_subscriptionsCursor);
  bool get canLoadMoreInvoices => _hasCursor(_invoicesCursor);
  bool get canLoadMorePayments => _hasCursor(_paymentsCursor);
  bool get canLoadMoreCreditNotes => _hasCursor(_creditNotesCursor);
  bool get canLoadMoreRefunds => _hasCursor(_refundsCursor);

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

  bool _hasCursor(String? cursor) => cursor != null && cursor.trim().isNotEmpty;

  void _setError(Object error, String fallback) {
    errorMessage.value = AppException.sanitizeMessage(error, fallback: fallback);
  }

  Future<void> load() async {
    final id = networkId;
    if (id == null) {
      errorMessage.value = 'تعذر تحديد الشبكة النشطة. اختر شبكة أولاً.';
      return;
    }

    final revision = ++_requestRevision;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait<Object>([
        getCurrencies(),
        getAccounts(id),
      ]);
      if (revision != _requestRevision) return;

      currencies.assignAll(results[0] as List<BillingCurrencyEntity>);
      selectedCurrencyId.value ??= currencies.isEmpty ? null : currencies.first.currencyId;
      accounts.assignAll(results[1] as List<BillingAccountEntity>);

      if (accounts.isEmpty) {
        selectedAccountId.value = null;
        _clearHistory();
        return;
      }

      final current = selectedAccountId.value;
      selectedAccountId.value = accounts.any((a) => a.billingAccountId == current)
          ? current
          : accounts.first.billingAccountId;
      await loadAccountHistory();
    } catch (error) {
      if (revision == _requestRevision) {
        _setError(error, 'تعذر تحميل بيانات فوترة الشبكة.');
      }
    } finally {
      if (revision == _requestRevision) isLoading.value = false;
    }
  }

  Future<void> selectAccount(int? accountId) async {
    if (accountId == null || accountId == selectedAccountId.value) return;
    selectedAccountId.value = accountId;
    await loadAccountHistory();
  }

  Future<void> loadAccountHistory() async {
    final id = selectedAccountId.value;
    final revision = ++_requestRevision;
    if (id == null) {
      _clearHistory();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    _resetCursors();
    _clearHistory();
    try {
      final pages = await Future.wait<Object>([
        getSubscriptions(id),
        getInvoices(id),
        getPayments(id),
        getCreditNotes(id),
        getRefunds(id),
        getStatement(id),
        getPlans(id),
        getPaymentMethods(id),
      ]);
      if (revision != _requestRevision || selectedAccountId.value != id) return;

      final subscriptionPage = pages[0] as PaginatedList<BillingSubscriptionEntity>;
      final invoicePage = pages[1] as PaginatedList<BillingInvoiceEntity>;
      final paymentPage = pages[2] as PaginatedList<BillingPaymentEntity>;
      final creditPage = pages[3] as PaginatedList<BillingCreditNoteEntity>;
      final refundPage = pages[4] as PaginatedList<BillingRefundEntity>;

      subscriptions.assignAll(subscriptionPage.items);
      invoices.assignAll(invoicePage.items);
      payments.assignAll(paymentPage.items);
      creditNotes.assignAll(creditPage.items);
      refunds.assignAll(refundPage.items);
      _subscriptionsCursor = subscriptionPage.nextCursor;
      _invoicesCursor = invoicePage.nextCursor;
      _paymentsCursor = paymentPage.nextCursor;
      _creditNotesCursor = creditPage.nextCursor;
      _refundsCursor = refundPage.nextCursor;
      statement.value = pages[5] as BillingStatementEntity;
      plans.assignAll((pages[6] as PaginatedList<BillingPlanEntity>).items);
      paymentMethods.assignAll(pages[7] as List<BillingPaymentMethodEntity>);
      if (!paymentMethods.any((item) => item.paymentMethodId == selectedPaymentMethodId.value)) {
        selectedPaymentMethodId.value = paymentMethods.isEmpty ? null : paymentMethods.first.paymentMethodId;
      }
    } catch (error) {
      if (revision == _requestRevision) {
        _setError(error, 'تعذر تحميل سجل الاشتراكات والفواتير وكشف الحساب.');
      }
    } finally {
      if (revision == _requestRevision) isLoading.value = false;
    }
  }

  Future<void> createBillingAccount(int currencyId) async {
    final id = networkId;
    if (id == null || isCreatingAccount.value) return;
    isCreatingAccount.value = true;
    errorMessage.value = null;
    try {
      final created = await createAccount(id, currencyId);
      final existingIndex = accounts.indexWhere(
        (item) => item.billingAccountId == created.billingAccountId,
      );
      if (existingIndex >= 0) {
        accounts[existingIndex] = created;
      } else {
        accounts.add(created);
      }
      selectedAccountId.value = created.billingAccountId;
      await loadAccountHistory();
    } catch (error) {
      _setError(error, 'تعذر إنشاء حساب الفوترة.');
    } finally {
      isCreatingAccount.value = false;
    }
  }

  Future<void> loadMoreSubscriptions() => _loadMore(
    cursor: _subscriptionsCursor,
    loading: isLoadingMoreSubscriptions,
    request: (cursor) => getSubscriptions(selectedAccountId.value!, cursor: cursor),
    append: (page) => _appendUnique<BillingSubscriptionEntity>(
      subscriptions, page.items, (item) => item.subscriptionId,
    ),
    saveCursor: (cursor) => _subscriptionsCursor = cursor,
    fallback: 'تعذر تحميل بقية الاشتراكات.',
  );

  Future<void> loadMoreInvoices() => _loadMore(
    cursor: _invoicesCursor,
    loading: isLoadingMoreInvoices,
    request: (cursor) => getInvoices(selectedAccountId.value!, cursor: cursor),
    append: (page) => _appendUnique<BillingInvoiceEntity>(
      invoices, page.items, (item) => item.invoiceId,
    ),
    saveCursor: (cursor) => _invoicesCursor = cursor,
    fallback: 'تعذر تحميل بقية الفواتير.',
  );

  Future<void> loadMorePayments() => _loadMore(
    cursor: _paymentsCursor,
    loading: isLoadingMorePayments,
    request: (cursor) => getPayments(selectedAccountId.value!, cursor: cursor),
    append: (page) => _appendUnique<BillingPaymentEntity>(
      payments, page.items, (item) => item.paymentId,
    ),
    saveCursor: (cursor) => _paymentsCursor = cursor,
    fallback: 'تعذر تحميل بقية المدفوعات.',
  );

  Future<void> loadMoreCreditNotes() => _loadMore(
    cursor: _creditNotesCursor,
    loading: isLoadingMoreCreditNotes,
    request: (cursor) => getCreditNotes(selectedAccountId.value!, cursor: cursor),
    append: (page) => _appendUnique<BillingCreditNoteEntity>(
      creditNotes, page.items, (item) => item.creditNoteId,
    ),
    saveCursor: (cursor) => _creditNotesCursor = cursor,
    fallback: 'تعذر تحميل بقية الإشعارات الدائنة.',
  );

  Future<void> loadMoreRefunds() => _loadMore(
    cursor: _refundsCursor,
    loading: isLoadingMoreRefunds,
    request: (cursor) => getRefunds(selectedAccountId.value!, cursor: cursor),
    append: (page) => _appendUnique<BillingRefundEntity>(
      refunds, page.items, (item) => item.refundId,
    ),
    saveCursor: (cursor) => _refundsCursor = cursor,
    fallback: 'تعذر تحميل بقية عمليات الاسترداد.',
  );

  Future<void> _loadMore<T>({
    required String? cursor,
    required RxBool loading,
    required Future<PaginatedList<T>> Function(String cursor) request,
    required void Function(PaginatedList<T> page) append,
    required void Function(String?) saveCursor,
    required String fallback,
  }) async {
    final accountId = selectedAccountId.value;
    if (accountId == null || !_hasCursor(cursor) || loading.value) return;
    final revision = _requestRevision;
    loading.value = true;
    try {
      final page = await request(cursor!);
      if (revision != _requestRevision || accountId != selectedAccountId.value) return;
      append(page);
      saveCursor(page.nextCursor);
    } catch (error) {
      if (revision == _requestRevision) _setError(error, fallback);
    } finally {
      loading.value = false;
    }
  }

  void _appendUnique<T>(
    RxList<T> target,
    List<T> incoming,
    int Function(T item) idOf,
  ) {
    final seen = target.map(idOf).toSet();
    for (final item in incoming) {
      if (seen.add(idOf(item))) target.add(item);
    }
  }

  void preparePayment(BillingInvoiceEntity invoice) {
    paymentAmountController.text = invoice.remaining;
    paymentReferenceController.clear();
    selectedProofPath.value = null;
    final matching = paymentMethods.where((method) => method.isActive).toList();
    selectedPaymentMethodId.value = matching.isEmpty
        ? null
        : matching.first.paymentMethodId;
    errorMessage.value = null;
  }

  Future<void> choosePaymentProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        allowMultiple: false,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path != null && path.isNotEmpty) {
        selectedProofPath.value = path;
      }
    } catch (error) {
      _setError(error, 'تعذر اختيار إثبات الدفع.');
    }
  }

  int? _parseMinorUnits(String input, int decimalPlaces) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty || decimalPlaces < 0 || decimalPlaces > 6) {
      return null;
    }
    if (!RegExp(r'^\d+(?:\.\d+)?
    final accountId = selectedAccountId.value;
    if (accountId == null || isPurchasing.value) return null;
    isPurchasing.value = true;
    errorMessage.value = null;
    try {
      final result = await purchaseSubscription(accountId, priceId);
      lastPurchase.value = result;
      await loadAccountHistory();
      return result;
    } catch (error) {
      _setError(error, 'تعذر إتمام طلب الاشتراك.');
      return null;
    } finally {
      isPurchasing.value = false;
    }
  }

  @override
  void onClose() {
    paymentAmountController.dispose();
    paymentReferenceController.dispose();
    super.onClose();
  }

  @override
  void selectSection(BillingSection section) => selectedSection.value = section;

  void _resetCursors() {
    _subscriptionsCursor = null;
    _invoicesCursor = null;
    _paymentsCursor = null;
    _creditNotesCursor = null;
    _refundsCursor = null;
  }

  void _clearHistory() {
    _resetCursors();
    subscriptions.clear();
    invoices.clear();
    payments.clear();
    creditNotes.clear();
    refunds.clear();
    plans.clear();
    paymentMethods.clear();
    selectedPaymentMethodId.value = null;
    statement.value = null;
    lastPurchase.value = null;
  }
}
).hasMatch(normalized)) return null;

    final parts = normalized.split('.');
    final whole = BigInt.tryParse(parts.first);
    if (whole == null) return null;
    final fraction = parts.length == 1 ? '' : parts[1];
    if (fraction.length > decimalPlaces &&
        fraction.substring(decimalPlaces).split('').any((digit) => digit != '0')) {
      return null;
    }
    final normalizedFraction = fraction
        .padRight(decimalPlaces, '0')
        .substring(0, decimalPlaces);
    final scale = BigInt.from(10).pow(decimalPlaces);
    final fractionalMinor = normalizedFraction.isEmpty
        ? BigInt.zero
        : BigInt.parse(normalizedFraction);
    final minor = whole * scale + fractionalMinor;
    if (minor <= BigInt.zero || minor > BigInt.parse('9223372036854775807')) {
      return null;
    }
    return int.tryParse(minor.toString());
  }

  Future<BillingPaymentEntity?> submitPayment(BillingInvoiceEntity invoice) async {
    if (isSubmittingPayment.value) return null;
    final methodId = selectedPaymentMethodId.value;
    final currencyPlaces = invoice.currency?.decimalPlaces ?? 2;
    final amountMinor = _parseMinorUnits(
      paymentAmountController.text,
      currencyPlaces,
    );
    if (methodId == null) {
      errorMessage.value = 'اختر وسيلة الدفع أولاً.';
      return null;
    }
    if (amountMinor == null) {
      errorMessage.value = 'أدخل مبلغاً موجباً صالحاً وفق عدد منازل العملة العشرية.';
      return null;
    }

    isSubmittingPayment.value = true;
    errorMessage.value = null;
    try {
      final randomPart = math.Random.secure().nextInt(0x7fffffff).toRadixString(16);
      final key = 'NSBILL-\u0024{DateTime.now().microsecondsSinceEpoch}-$randomPart';
      final payment = await submitInvoicePayment(
        invoiceId: invoice.invoiceId,
        paymentMethodId: methodId,
        amountMinor: amountMinor,
        idempotencyKey: key,
        externalReference: paymentReferenceController.text.trim().isEmpty
            ? null
            : paymentReferenceController.text.trim(),
        proofPath: selectedProofPath.value,
      );
      await loadAccountHistory();
      return payment;
    } catch (error) {
      _setError(error, 'تعذر تسجيل طلب السداد.');
      return null;
    } finally {
      isSubmittingPayment.value = false;
    }
  }

  Future<BillingPurchaseResultEntity?> buyPlan(int priceId) async {
    final accountId = selectedAccountId.value;
    if (accountId == null || isPurchasing.value) return null;
    isPurchasing.value = true;
    errorMessage.value = null;
    try {
      final result = await purchaseSubscription(accountId, priceId);
      lastPurchase.value = result;
      await loadAccountHistory();
      return result;
    } catch (error) {
      _setError(error, 'تعذر إتمام طلب الاشتراك.');
      return null;
    } finally {
      isPurchasing.value = false;
    }
  }

  void selectSection(BillingSection section) => selectedSection.value = section;

  void _resetCursors() {
    _subscriptionsCursor = null;
    _invoicesCursor = null;
    _paymentsCursor = null;
    _creditNotesCursor = null;
    _refundsCursor = null;
  }

  void _clearHistory() {
    _resetCursors();
    subscriptions.clear();
    invoices.clear();
    payments.clear();
    creditNotes.clear();
    refunds.clear();
    plans.clear();
    statement.value = null;
    lastPurchase.value = null;
  }
}
