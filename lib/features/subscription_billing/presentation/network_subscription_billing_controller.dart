import 'package:get/get.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/subscription_billing/data/network_billing_repository.dart';
import 'package:netsales/features/subscription_billing/domain/entities/network_billing_record.dart';

enum NetworkBillingSection { subscriptions, invoices, payments, creditNotes, refunds, statement }

class NetworkSubscriptionBillingController extends GetxController {
  NetworkSubscriptionBillingController(this.repository);
  final NetworkBillingRepository repository;

  final accounts = <NetworkBillingRecord>[].obs;
  final records = <NetworkBillingRecord>[].obs;
  final statementData = Rxn<Map<String, dynamic>>();
  final selectedAccountId = RxnInt();
  final selectedSection = NetworkBillingSection.subscriptions.obs;
  final isLoading = false.obs;
  final isLoadingAccounts = false.obs;
  final error = RxnString();

  int? get networkId => WorkspaceService.to.savedActiveNetworkId;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final id = networkId;
    if (id == null || id <= 0) {
      error.value = 'حدد الشبكة النشطة أولاً.';
      return;
    }
    isLoadingAccounts.value = true;
    error.value = null;
    try {
      accounts.assignAll(await repository.accounts(id));
      if (accounts.isNotEmpty) {
        final selected = accounts.firstWhereOrNull((a) => a.id == selectedAccountId.value);
        selectedAccountId.value = selected?.id ?? accounts.first.id;
        await loadSection(selectedSection.value);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  Future<void> selectAccount(int? id) async {
    if (id == null || !accounts.any((a) => a.id == id)) return;
    selectedAccountId.value = id;
    await loadSection(selectedSection.value);
  }

  Future<void> selectSection(NetworkBillingSection section) async {
    selectedSection.value = section;
    await loadSection(section);
  }

  Future<void> loadSection(NetworkBillingSection section) async {
    final accountId = selectedAccountId.value;
    if (accountId == null) return;
    isLoading.value = true;
    error.value = null;
    try {
      if (section == NetworkBillingSection.statement) {
        statementData.value = await repository.statement(accountId: accountId);
        records.clear();
      } else {
        final resource = switch (section) {
          NetworkBillingSection.subscriptions => 'subscriptions',
          NetworkBillingSection.invoices => 'invoices',
          NetworkBillingSection.payments => 'payments',
          NetworkBillingSection.creditNotes => 'credit-notes',
          NetworkBillingSection.refunds => 'refunds',
          NetworkBillingSection.statement => 'statement',
        };
        records.assignAll(await repository.list(accountId: accountId, resource: resource));
        statementData.value = null;
      }
    } catch (e) {
      error.value = e.toString();
      records.clear();
      statementData.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
