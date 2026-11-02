import 'package:get/get.dart';
import 'package:netsales/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:netsales/features/debts/data/datasources/debts_remote_data_source_impl.dart';
import 'package:netsales/features/debts/data/repositories/debts_repository_impl.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';
import 'package:netsales/features/debts/domain/usecases/collect_repayment_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_outstanding_invoices_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_receivables_summary_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/get_repayments_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/reverse_repayment_use_case.dart';
import 'package:netsales/features/debts/domain/usecases/update_credit_limit_use_case.dart';
import 'package:netsales/features/debts/presentation/controllers/network_debts_controller.dart';

class NetworkDebtsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebtsRemoteDataSource>(
      () => const DebtsRemoteDataSourceImpl(),
    );

    Get.lazyPut<DebtsRepository>(
      () => DebtsRepositoryImpl(remoteDataSource: Get.find<DebtsRemoteDataSource>()),
    );

    Get.lazyPut<GetReceivablesSummaryUseCase>(
      () => GetReceivablesSummaryUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<GetOutstandingInvoicesUseCase>(
      () => GetOutstandingInvoicesUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<GetRepaymentsUseCase>(
      () => GetRepaymentsUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<CollectRepaymentUseCase>(
      () => CollectRepaymentUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<ReverseRepaymentUseCase>(
      () => ReverseRepaymentUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<UpdateCreditLimitUseCase>(
      () => UpdateCreditLimitUseCase(Get.find<DebtsRepository>()),
    );

    Get.lazyPut<NetworkDebtsController>(
      () => NetworkDebtsController(
        getReceivablesSummaryUseCase: Get.find<GetReceivablesSummaryUseCase>(),
        getOutstandingInvoicesUseCase: Get.find<GetOutstandingInvoicesUseCase>(),
        getRepaymentsUseCase: Get.find<GetRepaymentsUseCase>(),
        collectRepaymentUseCase: Get.find<CollectRepaymentUseCase>(),
        reverseRepaymentUseCase: Get.find<ReverseRepaymentUseCase>(),
        updateCreditLimitUseCase: Get.find<UpdateCreditLimitUseCase>(),
      ),
    );
  }
}
