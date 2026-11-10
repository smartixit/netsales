import 'package:get/get.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source_impl.dart';
import 'package:netsales/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/transfer_pos_to_network_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/update_pos_credit_limit_use_case.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_transfer_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_collection_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<FinanceRemoteDataSource>(
      () => const FinanceRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Commercial Data Source & Repositories for Relations
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      Get.lazyPut<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      Get.lazyPut<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyPosUseCase>()) {
      Get.lazyPut<GetMyPosUseCase>(
        () => GetMyPosUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPosNetworksListUseCase>()) {
      Get.lazyPut<GetPosNetworksListUseCase>(
        () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworkPosListUseCase>()) {
      Get.lazyPut<GetNetworkPosListUseCase>(
        () => GetNetworkPosListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    // 3. Finance Repository
    Get.lazyPut<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: Get.find<FinanceRemoteDataSource>(),
      ),
      fenix: true,
    );

    // 4. Use Cases
    Get.lazyPut<GetPosWalUseCase>(
      () => GetPosWalUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosWalletByNetworkAndPosUseCase>(
      () => GetPosWalletByNetworkAndPosUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosWalletLogsUseCase>(
      () => GetPosWalletLogsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetNetworkWalletsUseCase>(
      () => GetNetworkWalletsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetNetworkWalletLogsUseCase>(
      () => GetNetworkWalletLogsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<TransferFromNetworkToPosUseCase>(
      () => TransferFromNetworkToPosUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<TransferPosToNetworkUseCase>(
      () => TransferPosToNetworkUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<UpdatePosCreditLimitUseCase>(
      () => UpdatePosCreditLimitUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetDebtSummaryUseCase>(
      () => GetDebtSummaryUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetOutstandingInvoicesUseCase>(
      () => GetOutstandingInvoicesUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetRepaymentsUseCase>(
      () => GetRepaymentsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetRepaymentDetailsUseCase>(
      () => GetRepaymentDetailsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<CollectRepaymentUseCase>(
      () => CollectRepaymentUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    Get.lazyPut<ReverseRepaymentUseCase>(
      () => ReverseRepaymentUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    // 5. Controllers
    Get.lazyPut<PosWalletDashboardController>(
      () => PosWalletDashboardController(
        getPosWalUseCase: Get.find<GetPosWalUseCase>(),
        getPosWalletLogsUseCase: Get.find<GetPosWalletLogsUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PosDebtLedgerController>(
      () => PosDebtLedgerController(
        getDebtSummaryUseCase: Get.find<GetDebtSummaryUseCase>(),
        getOutstandingInvoicesUseCase:
            Get.find<GetOutstandingInvoicesUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RepaymentHistoryController>(
      () => RepaymentHistoryController(
        getRepaymentsUseCase: Get.find<GetRepaymentsUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        reverseRepaymentUseCase: Get.find<ReverseRepaymentUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RepaymentCollectionController>(
      () => RepaymentCollectionController(
        collectRepaymentUseCase: Get.find<CollectRepaymentUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NetworkWalletDashboardController>(
      () => NetworkWalletDashboardController(
        getNetworkWalletsUseCase: Get.find<GetNetworkWalletsUseCase>(),
        getNetworkWalletLogsUseCase: Get.find<GetNetworkWalletLogsUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NetworkWalletTransferController>(
      () => NetworkWalletTransferController(
        transferFromNetworkToPosUseCase:
            Get.find<TransferFromNetworkToPosUseCase>(),
        transferPosToNetworkUseCase:
            Get.find<TransferPosToNetworkUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
      ),
      fenix: true,
    );
  }
}
