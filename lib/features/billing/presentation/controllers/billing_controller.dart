import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/enums/billing_status.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/billing/domain/entities/billing_payload.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_state.dart';

class BillingController extends GetxController {
  BillingController({
    required this.useCases,
    required this.networkId,
    this.networkIdSignal,
  });

  final BillingUseCases useCases;
  final int? Function() networkId;
  final RxnInt? networkIdSignal;
  Worker? _networkWorker;
  int? _loadedNetworkId;

  final accounts = <Map<String, dynamic>>[].obs;
  final currencies = <Map<String, dynamic>>[].obs;
  final selectedCurrencyId = RxnInt();

  final plansPage = BillingCursorPageState(identityKey: 'plan_id');
  final subscriptionsPage =
      BillingCursorPageState(identityKey: 'billing_subscription_id');
  final invoicesPage = BillingCursorPageState(identityKey: 'invoice_id');
  final paymentsPage = BillingCursorPageState(identityKey: 'payment_id');
  final creditNotesPage =
      BillingCursorPageState(identityKey: 'credit_note_id');
  final refundsPage = BillingCursorPageState(identityKey: 'refund_id');

  final plansFilter = CustomCollectionFilterState();
  final subscriptionsFilter = CustomCollectionFilterState(
    statusValues: [
      BillingStatus.incomplete.wireValue,
      BillingStatus.trialing.wireValue,
      BillingStatus.active.wireValue,
      BillingStatus.pastDue.wireValue,
      BillingStatus.paused.wireValue,
      BillingStatus.suspended.wireValue,
      BillingStatus.canceled.wireValue,
      BillingStatus.expired.wireValue,
    ],
  );
  final invoicesFilter = CustomCollectionFilterState(
    statusValues: [
      BillingStatus.draft.wireValue,
      BillingStatus.open.wireValue,
      BillingStatus.partiallyPaid.wireValue,
      BillingStatus.partiallyCredited.wireValue,
      BillingStatus.paid.wireValue,
      BillingStatus.credited.wireValue,
      BillingStatus.uncollectible.wireValue,
      BillingStatus.voided.wireValue,
    ],
  );
  final paymentsFilter = CustomCollectionFilterState(
    statusValues: [
      BillingStatus.pendingReview.wireValue,
      BillingStatus.verified.wireValue,
      BillingStatus.failed.wireValue,
      BillingStatus.rejected.wireValue,
      BillingStatus.refunded.wireValue,
      BillingStatus.partiallyRefunded.wireValue,
    ],
  );
  final creditNotesFilter = CustomCollectionFilterState(
    statusValues: [
      BillingStatus.issued.wireValue,
      BillingStatus.partiallyRefunded.wireValue,
      BillingStatus.refunded.wireValue,
    ],
  );
  final refundsFilter = CustomCollectionFilterState(
    statusValues: [
      BillingStatus.pending.wireValue,
      BillingStatus.completed.wireValue,
    ],
  );

  List<CustomCollectionFilterState> get _collectionFilters => [
        plansFilter,
        subscriptionsFilter,
        invoicesFilter,
        paymentsFilter,
        creditNotesFilter,
        refundsFilter,
      ];

  RxList<Map<String, dynamic>> get plans => plansPage.items;
  RxList<Map<String, dynamic>> get subscriptions => subscriptionsPage.items;
  RxList<Map<String, dynamic>> get invoices => invoicesPage.items;
  RxList<Map<String, dynamic>> get payments => paymentsPage.items;
  RxList<Map<String, dynamic>> get creditNotes => creditNotesPage.items;
  RxList<Map<String, dynamic>> get refunds => refundsPage.items;

  final paymentMethods = <Map<String, dynamic>>[].obs;
  final selectedPaymentMethodId = RxnInt();
  final paymentProof = Rxn<AppPickedFileModel>();
  final entitlements = Rxn<Map<String, dynamic>>();
  final account = Rxn<Map<String, dynamic>>();
  final errorMessage = RxnString();
  final isLoading = false.obs;
  final isMutating = false.obs;
  final selectedAccountId = RxnInt();

  final subscriptionDetails = Rxn<Map<String, dynamic>>();
  final eventsPage = BillingCursorPageState(identityKey: 'event_id');
  final usagePage =
      BillingCursorPageState(identityKey: 'usage_aggregate_id');
  RxList<Map<String, dynamic>> get eventRows => eventsPage.items;
  RxList<Map<String, dynamic>> get usageRows => usagePage.items;

  int _revision = 0;
  int _detailsRevision = 0;
  int? _detailsSubscriptionId;

  List<BillingCursorPageState> get _accountPages => [
        plansPage,
        subscriptionsPage,
        invoicesPage,
        paymentsPage,
        creditNotesPage,
        refundsPage,
      ];

  List<Map<String, dynamic>> _rows(BillingPayload payload) {
    dynamic value = payload.data['data'] ?? payload.data['items'] ?? payload.data;
    if (value is Map<String, dynamic>) {
      value = value['data'] ?? value['items'];
    }
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  Map<String, dynamic> _object(BillingPayload payload) {
    final value = payload.data['data'] ?? payload.data;
    return value is Map
        ? Map<String, dynamic>.from(value)
        : payload.data;
  }

  Map<String, dynamic> _page(BillingPayload payload) => _object(payload);

  void _invalidateAccountPages({required bool clearItems}) {
    for (final page in _accountPages) {
      if (clearItems) {
        page.reset();
      } else {
        page.beginRefresh();
      }
    }
  }

  void _resetCollectionFilters() {
    for (final filter in _collectionFilters) {
      filter.reset();
    }
  }

  Map<String, dynamic> _firstPageQuery(
    CustomCollectionFilterState filter,
  ) =>
      {
        'per_page': 25,
        ...filter.queryParameters,
      };

  Future<void> _refreshCollection({
    required BillingCursorPageState page,
    required CustomCollectionFilterState filter,
    required Future<BillingPayload> Function(Map<String, dynamic>) fetchPage,
    required String fallback,
  }) async {
    final accountId = selectedAccountId.value;
    final requestNetworkId = networkId();
    if (accountId == null || requestNetworkId == null) return;

    final controllerRevision = _revision;
    final pageRevision = page.beginRefresh();
    try {
      final payload = await fetchPage(_firstPageQuery(filter));
      if (controllerRevision != _revision ||
          accountId != selectedAccountId.value ||
          requestNetworkId != networkId() ||
          pageRevision != page.revision) {
        return;
      }
      page.replace(_page(payload));
    } catch (error) {
      if (controllerRevision == _revision &&
          accountId == selectedAccountId.value &&
          requestNetworkId == networkId() &&
          pageRevision == page.revision) {
        page.failFirstPage(
          AppException.sanitizeMessage(error, fallback: fallback),
          revision: pageRevision,
        );
      }
    }
  }

  void searchPlans(String value) =>
      plansFilter.onSearchChanged(value, refreshPlans);
  void searchSubscriptions(String value) =>
      subscriptionsFilter.onSearchChanged(value, refreshSubscriptions);
  void searchInvoices(String value) =>
      invoicesFilter.onSearchChanged(value, refreshInvoices);
  void searchPayments(String value) =>
      paymentsFilter.onSearchChanged(value, refreshPayments);
  void searchCreditNotes(String value) =>
      creditNotesFilter.onSearchChanged(value, refreshCreditNotes);
  void searchRefunds(String value) =>
      refundsFilter.onSearchChanged(value, refreshRefunds);

  void setSubscriptionStatus(String? value) =>
      unawaited(subscriptionsFilter.onStatusChanged(value, refreshSubscriptions));
  void setInvoiceStatus(String? value) =>
      unawaited(invoicesFilter.onStatusChanged(value, refreshInvoices));
  void setPaymentStatus(String? value) =>
      unawaited(paymentsFilter.onStatusChanged(value, refreshPayments));
  void setCreditNoteStatus(String? value) =>
      unawaited(creditNotesFilter.onStatusChanged(value, refreshCreditNotes));
  void setRefundStatus(String? value) =>
      unawaited(refundsFilter.onStatusChanged(value, refreshRefunds));

  Future<void> refreshPlans() => _refreshCollection(
        page: plansPage,
        filter: plansFilter,
        fetchPage: (query) => useCases.plans(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث الخطط المطابقة.',
      );
  Future<void> refreshSubscriptions() => _refreshCollection(
        page: subscriptionsPage,
        filter: subscriptionsFilter,
        fetchPage: (query) => useCases.subscriptions(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث الاشتراكات المطابقة.',
      );
  Future<void> refreshInvoices() => _refreshCollection(
        page: invoicesPage,
        filter: invoicesFilter,
        fetchPage: (query) => useCases.invoices(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث الفواتير المطابقة.',
      );
  Future<void> refreshPayments() => _refreshCollection(
        page: paymentsPage,
        filter: paymentsFilter,
        fetchPage: (query) => useCases.payments(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث المدفوعات المطابقة.',
      );
  Future<void> refreshCreditNotes() => _refreshCollection(
        page: creditNotesPage,
        filter: creditNotesFilter,
        fetchPage: (query) => useCases.creditNotes(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث الإشعارات الدائنة المطابقة.',
      );
  Future<void> refreshRefunds() => _refreshCollection(
        page: refundsPage,
        filter: refundsFilter,
        fetchPage: (query) => useCases.refunds(selectedAccountId.value!, query),
        fallback: 'تعذر تحديث الاستردادات المطابقة.',
      );

  void _clearSubscriptionDetails() {
    _detailsRevision++;
    _detailsSubscriptionId = null;
    subscriptionDetails.value = null;
    eventsPage.reset();
    usagePage.reset();
  }

  @override
  void onInit() {
    super.onInit();
    final signal = networkIdSignal;
    if (signal != null) {
      _networkWorker = ever<int?>(signal, (_) => unawaited(load()));
    }
    unawaited(load());
  }

  @override
  void onClose() {
    _networkWorker?.dispose();
    for (final filter in _collectionFilters) {
      filter.dispose();
    }
    super.onClose();
  }

  void _clearWorkspaceData() {
    _resetCollectionFilters();
    accounts.clear();
    selectedAccountId.value = null;
    account.value = null;
    entitlements.value = null;
    paymentMethods.clear();
    selectedPaymentMethodId.value = null;
    paymentProof.value = null;
    _invalidateAccountPages(clearItems: true);
    _clearSubscriptionDetails();
  }

  Future<void> load() async {
    final revision = ++_revision;
    final network = networkId();
    if (network == null) {
      _loadedNetworkId = null;
      _clearWorkspaceData();
      isLoading.value = false;
      errorMessage.value = 'حدد الشبكة أولاً.';
      return;
    }
    if (_loadedNetworkId != network) {
      _clearWorkspaceData();
      _loadedNetworkId = network;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        useCases.accounts(network),
        useCases.currencies(),
      ]);
      if (revision != _revision || network != networkId()) return;

      accounts.assignAll(_rows(results[0]));
      currencies.assignAll(_rows(results[1]));
      if (selectedCurrencyId.value == null && currencies.isNotEmpty) {
        selectedCurrencyId.value =
            (currencies.first['currency_id'] as num).toInt();
      }

      if (accounts.isEmpty) {
        _resetCollectionFilters();
        selectedAccountId.value = null;
        account.value = null;
        _invalidateAccountPages(clearItems: true);
        _clearSubscriptionDetails();
        return;
      }

      final previousAccountId = selectedAccountId.value;
      final chosen = accounts.firstWhereOrNull(
            (row) => row['billing_account_id'] == previousAccountId,
          ) ??
          accounts.first;
      final chosenId = (chosen['billing_account_id'] as num).toInt();
      if (previousAccountId != chosenId) {
        _resetCollectionFilters();
        _invalidateAccountPages(clearItems: true);
        _clearSubscriptionDetails();
      }
      selectedAccountId.value = chosenId;
      await loadAccountData(revision: revision);
    } catch (error) {
      if (revision == _revision) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل بيانات الفوترة.',
        );
      }
    } finally {
      if (revision == _revision) isLoading.value = false;
    }
  }

  Future<void> createAccount() async {
    final network = networkId();
    final currencyId = selectedCurrencyId.value;
    if (network == null || currencyId == null || isMutating.value) return;

    isMutating.value = true;
    try {
      await useCases.createAccount(network, currencyId);
      await load();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر إنشاء حساب الفوترة.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> selectAccount(int? id) async {
    if (id == null || id == selectedAccountId.value) return;
    _resetCollectionFilters();
    selectedAccountId.value = id;
    account.value = null;
    _invalidateAccountPages(clearItems: true);
    _clearSubscriptionDetails();
    await loadAccountData();
  }

  Future<void> loadAccountData({int? revision}) async {
    final id = selectedAccountId.value;
    final requestNetworkId = networkId();
    if (id == null || requestNetworkId == null) return;

    final currentRevision = revision ?? ++_revision;
    isLoading.value = true;
    errorMessage.value = null;

    // Each growing collection owns its first-page request and error state.
    // A failure in one list must not discard successful data from another.
    final collectionLoads = <Future<void>>[
      refreshPlans(),
      refreshSubscriptions(),
      refreshInvoices(),
      refreshPayments(),
      refreshCreditNotes(),
      refreshRefunds(),
    ];

    try {
      final results = await Future.wait([
        useCases.account(id),
        useCases.entitlements(id),
        useCases.paymentMethods(id),
      ]);

      if (currentRevision != _revision ||
          id != selectedAccountId.value ||
          requestNetworkId != networkId()) {
        return;
      }

      account.value = _object(results[0]);
      entitlements.value = _object(results[1]);
      paymentMethods.assignAll(_rows(results[2]));

      if (selectedPaymentMethodId.value == null ||
          !paymentMethods.any(
            (method) =>
                (method['payment_method_id'] as num?)?.toInt() ==
                selectedPaymentMethodId.value,
          )) {
        selectedPaymentMethodId.value = paymentMethods.isEmpty
            ? null
            : (paymentMethods.first['payment_method_id'] as num).toInt();
      }

      await Future.wait(collectionLoads);
    } catch (error) {
      if (currentRevision == _revision &&
          id == selectedAccountId.value &&
          requestNetworkId == networkId()) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل بيانات حساب الفوترة.',
        );
      }
      await Future.wait(collectionLoads);
    } finally {
      if (currentRevision == _revision) isLoading.value = false;
    }
  }

  Future<void> _loadMorePage({
    required BillingCursorPageState state,
    required Future<BillingPayload> Function(Map<String, dynamic> query)
        fetchPage,
    required String fallback,
    int perPage = 25,
    bool Function()? additionalGuard,
  }) async {
    final accountId = selectedAccountId.value;
    final requestNetworkId = networkId();
    final cursor = state.nextCursor;
    if (accountId == null ||
        requestNetworkId == null ||
        cursor == null ||
        cursor.isEmpty ||
        !state.hasMore ||
        state.isLoadingMore.value ||
        isLoading.value) {
      return;
    }

    final controllerRevision = _revision;
    final pageRevision = state.revision;
    state.isLoadingMore.value = true;
    state.loadMoreError.value = null;

    try {
      final payload = await fetchPage({
        'per_page': perPage,
        'cursor': cursor,
      });
      if (controllerRevision != _revision ||
          accountId != selectedAccountId.value ||
          requestNetworkId != networkId() ||
          pageRevision != state.revision ||
          (additionalGuard != null && !additionalGuard())) {
        return;
      }
      state.append(
        _page(payload),
        revision: pageRevision,
        requestedCursor: cursor,
      );
    } catch (error) {
      if (controllerRevision == _revision &&
          accountId == selectedAccountId.value &&
          requestNetworkId == networkId() &&
          pageRevision == state.revision &&
          (additionalGuard == null || additionalGuard())) {
        state.loadMoreError.value = AppException.sanitizeMessage(
          error,
          fallback: fallback,
        );
      }
    } finally {
      if (controllerRevision == _revision &&
          pageRevision == state.revision) {
        state.isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMorePlans() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: plansPage,
      fetchPage: (query) => useCases.plans(accountId, {...plansFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية الخطط.',
    );
  }

  Future<void> loadMoreSubscriptions() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: subscriptionsPage,
      fetchPage: (query) => useCases.subscriptions(accountId, {...subscriptionsFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية الاشتراكات.',
    );
  }

  Future<void> loadMoreInvoices() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: invoicesPage,
      fetchPage: (query) => useCases.invoices(accountId, {...invoicesFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية الفواتير.',
    );
  }

  Future<void> loadMorePayments() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: paymentsPage,
      fetchPage: (query) => useCases.payments(accountId, {...paymentsFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية المدفوعات.',
    );
  }

  Future<void> loadMoreCreditNotes() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: creditNotesPage,
      fetchPage: (query) => useCases.creditNotes(accountId, {...creditNotesFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية الإشعارات الدائنة.',
    );
  }

  Future<void> loadMoreRefunds() {
    final accountId = selectedAccountId.value;
    if (accountId == null) return Future<void>.value();
    return _loadMorePage(
      state: refundsPage,
      fetchPage: (query) => useCases.refunds(accountId, {...refundsFilter.queryParameters, ...query}),
      fallback: 'تعذر تحميل بقية الاستردادات.',
    );
  }

  Future<Map<String, dynamic>?> checkTrial(int priceId) async {
    final id = selectedAccountId.value;
    final revision = _revision;
    final network = networkId();
    if (id == null || network == null) return null;
    try {
      final payload = await useCases.trialEligibility(id, priceId);
      if (revision != _revision ||
          id != selectedAccountId.value ||
          network != networkId()) {
        return null;
      }
      final value = payload.data['data'] ?? payload.data;
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر التحقق من أهلية الفترة التجريبية.',
      );
      return null;
    }
  }

  Future<void> loadSubscriptionDetails(int id) async {
    final detailsRevision = ++_detailsRevision;
    _detailsSubscriptionId = id;
    errorMessage.value = null;
    subscriptionDetails.value = null;
    eventsPage.reset();
    usagePage.reset();
    try {
      final values = await Future.wait([
        useCases.subscription(id),
        useCases.usage(id, const {'per_page': 30}),
      ]);
      if (detailsRevision != _detailsRevision ||
          id != _detailsSubscriptionId) {
        return;
      }

      final detail = _object(values[0]);
      final rawSubscription = detail['subscription'];
      subscriptionDetails.value = rawSubscription is Map
          ? Map<String, dynamic>.from(rawSubscription)
          : detail;
      final rawEvents = detail['events'];
      if (rawEvents is Map) {
        eventsPage.replace(Map<String, dynamic>.from(rawEvents));
      } else {
        eventsPage.reset();
      }
      usagePage.replace(_page(values[1]));
    } catch (error) {
      if (detailsRevision == _detailsRevision) {
        errorMessage.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل تفاصيل الاشتراك والاستخدام.',
        );
      }
    }
  }

  Future<void> loadMoreEvents() {
    final id = _detailsSubscriptionId;
    final detailsRevision = _detailsRevision;
    if (id == null) return Future<void>.value();
    return _loadMorePage(
      state: eventsPage,
      perPage: 30,
      fetchPage: (query) => useCases.events(id, query),
      fallback: 'تعذر تحميل بقية أحداث الاشتراك.',
      additionalGuard: () =>
          detailsRevision == _detailsRevision &&
          id == _detailsSubscriptionId,
    );
  }

  Future<void> loadMoreUsage() {
    final id = _detailsSubscriptionId;
    final detailsRevision = _detailsRevision;
    if (id == null) return Future<void>.value();
    return _loadMorePage(
      state: usagePage,
      perPage: 30,
      fetchPage: (query) => useCases.usage(id, query),
      fallback: 'تعذر تحميل بقية سجلات الاستخدام.',
      additionalGuard: () =>
          detailsRevision == _detailsRevision &&
          id == _detailsSubscriptionId,
    );
  }

  Future<void> updateAccount(Map<String, dynamic> data) async {
    final id = selectedAccountId.value;
    if (id == null || isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.updateAccount(id, data);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحديث حساب الفوترة.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> createContact(Map<String, dynamic> data) async {
    final id = selectedAccountId.value;
    if (id == null || isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.createContact(id, data);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر إضافة جهة الاتصال.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> updateContact(int contactId, Map<String, dynamic> data) async {
    final id = selectedAccountId.value;
    if (id == null || isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.updateContact(id, contactId, data);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحديث جهة الاتصال.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> deleteContact(int contactId) async {
    final id = selectedAccountId.value;
    if (id == null || isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.deleteContact(id, contactId);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر حذف جهة الاتصال.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> purchase(int priceId) async {
    final id = selectedAccountId.value;
    if (id == null || isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.purchase(id, priceId);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر إنشاء الاشتراك.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> recordPayment(
    int invoiceId,
    int paymentMethodId,
    int amountMinor,
    String? externalReference,
    String? proofPath,
  ) async {
    if (isMutating.value) return;
    isMutating.value = true;
    try {
      final random = Random.secure();
      final key = List<int>.generate(16, (_) => random.nextInt(256))
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      await useCases.recordPayment(
        invoiceId,
        paymentMethodId,
        amountMinor,
        key,
        externalReference,
        proofPath,
      );
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تسجيل طلب الدفع.',
      );
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> cancel(int id, {required bool atPeriodEnd}) async {
    if (isMutating.value) return;
    isMutating.value = true;
    try {
      await useCases.cancel(id, atPeriodEnd);
      await loadAccountData();
    } catch (error) {
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر جدولة الإلغاء.',
      );
    } finally {
      isMutating.value = false;
    }
  }
}
