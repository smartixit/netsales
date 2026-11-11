import 'package:get/get.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source_impl.dart';
import 'package:netsales/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/features/billing/presentation/controllers/network_billing_controller.dart';

class NetworkBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillingRemoteDataSource>(
      () => const BillingRemoteDataSourceImpl(),
    );
    Get.lazyPut<BillingRepository>(
      () => BillingRepositoryImpl(Get.find<BillingRemoteDataSource>()),
    );
    final repository = Get.find<BillingRepository>();
    Get.lazyPut(() => GetBillingCurrenciesUseCase(repository));
    Get.lazyPut(() => GetNetworkBillingAccountsUseCase(repository));
    Get.lazyPut(() => CreateNetworkBillingAccountUseCase(repository));
    Get.lazyPut(() => GetBillingSubscriptionsUseCase(repository));
    Get.lazyPut(() => GetBillingInvoicesUseCase(repository));
    Get.lazyPut(() => GetBillingPaymentsUseCase(repository));
    Get.lazyPut(() => GetBillingCreditNotesUseCase(repository));
    Get.lazyPut(() => GetBillingRefundsUseCase(repository));
    Get.lazyPut(() => GetBillingStatementUseCase(repository));
    Get.lazyPut(() => GetNetworkBillingPlansUseCase(repository));
    Get.lazyPut(() => PurchaseNetworkSubscriptionUseCase(repository));
    Get.lazyPut(() => GetNetworkBillingPaymentMethodsUseCase(repository));
    Get.lazyPut(() => SubmitNetworkBillingInvoicePaymentUseCase(repository));
    Get.lazyPut(() => NetworkBillingController(
      getCurrencies: Get.find(),
      getAccounts: Get.find(),
      createAccount: Get.find(),
      getSubscriptions: Get.find(),
      getInvoices: Get.find(),
      getPayments: Get.find(),
      getCreditNotes: Get.find(),
      getRefunds: Get.find(),
      getStatement: Get.find(),
      getPlans: Get.find(),
      purchaseSubscription: Get.find(),
      getPaymentMethods: Get.find(),
      submitInvoicePayment: Get.find(),
    ));
  }
}
