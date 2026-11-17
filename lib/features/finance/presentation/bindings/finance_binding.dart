import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
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
import 'package:netsales/features/finance/data/repositories/repayment_document_repository_impl.dart';
import 'package:netsales/features/finance/data/repositories/wallet_statement_document_repository_impl.dart';
import 'package:netsales/features/finance/data/services/wallet_statement_document_service.dart';
import 'package:netsales/features/finance/data/services/repayment_document_service.dart';
import 'package:netsales/features/finance/domain/repositories/repayment_document_repository.dart';
import 'package:netsales/features/finance/domain/repositories/wallet_statement_document_repository.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_document_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/export_wallet_statement_document_use_case.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_pos_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/transfer_pos_to_network_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/update_pos_credit_limit_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_pos_wallet_use_case.dart';
import 'package:netsales/features/finance/presentation/controllers/manual_wallet_transaction_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_transfer_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_collection_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/update_pos_credit_limit_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    registerLazyIfAbsent<FinanceRemoteDataSource>(
      () => const FinanceRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Commercial Data Source & Repositories for Relations
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      registerLazyIfAbsent<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      registerLazyIfAbsent<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      registerLazyIfAbsent<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyPosUseCase>()) {
      registerLazyIfAbsent<GetMyPosUseCase>(
        () => GetMyPosUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPosNetworksListUseCase>()) {
      registerLazyIfAbsent<GetPosNetworksListUseCase>(
        () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworkPosListUseCase>()) {
      registerLazyIfAbsent<GetNetworkPosListUseCase>(
        () => GetNetworkPosListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    // 3. Finance Repository
    registerLazyIfAbsent<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: Get.find<FinanceRemoteDataSource>(),
      ),
      fenix: true,
    );

    // 4. Use Cases
    registerLazyIfAbsent<GetPosWalUseCase>(
      () => GetPosWalUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosWalletByNetworkAndPosUseCase>(
      () => GetPosWalletByNetworkAndPosUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosWalletLogsUseCase>(
      () => GetPosWalletLogsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetNetworkWalletsUseCase>(
      () => GetNetworkWalletsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkWalletLogsUseCase>(
      () => GetNetworkWalletLogsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkWalletByIdUseCase>(
      () => GetNetworkWalletByIdUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<TransferFromNetworkToPosUseCase>(
      () => TransferFromNetworkToPosUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<TransferPosToNetworkUseCase>(
      () => TransferPosToNetworkUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdatePosCreditLimitUseCase>(
      () => UpdatePosCreditLimitUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<DepositPosWalletUseCase>(
      () => DepositPosWalletUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<WithdrawPosWalletUseCase>(
      () => WithdrawPosWalletUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<DepositNetworkWalletUseCase>(
      () => DepositNetworkWalletUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<WithdrawNetworkWalletUseCase>(
      () => WithdrawNetworkWalletUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetDebtSummaryUseCase>(
      () => GetDebtSummaryUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetOutstandingInvoicesUseCase>(
      () => GetOutstandingInvoicesUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetRepaymentsUseCase>(
      () => GetRepaymentsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetRepaymentDetailsUseCase>(
      () => GetRepaymentDetailsUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<CollectRepaymentUseCase>(
      () => CollectRepaymentUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<ReverseRepaymentUseCase>(
      () => ReverseRepaymentUseCase(Get.find<FinanceRepository>()),
      fenix: true,
    );

    if (!Get.isRegistered<RepaymentDocumentRepository>()) {
      registerLazyIfAbsent<RepaymentDocumentRepository>(
        () => RepaymentDocumentRepositoryImpl(
          documentService: RepaymentDocumentService.instance,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RepaymentDocumentUseCase>()) {
      registerLazyIfAbsent<RepaymentDocumentUseCase>(
        () => RepaymentDocumentUseCase(Get.find<RepaymentDocumentRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<WalletStatementDocumentRepository>()) {
      registerLazyIfAbsent<WalletStatementDocumentRepository>(
        () => WalletStatementDocumentRepositoryImpl(
          documentService: WalletStatementDocumentService.instance,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ExportWalletStatementDocumentUseCase>()) {
      registerLazyIfAbsent<ExportWalletStatementDocumentUseCase>(
        () => ExportWalletStatementDocumentUseCase(
          Get.find<WalletStatementDocumentRepository>(),
        ),
        fenix: true,
      );
    }

    // 5. Controllers
    registerLazyIfAbsent<PosWalletDashboardController>(
      () => PosWalletDashboardController(
        getPosWalUseCase: Get.find<GetPosWalUseCase>(),
        getPosWalletLogsUseCase: Get.find<GetPosWalletLogsUseCase>(),
        getPosWalletByNetworkAndPosUseCase:
            Get.find<GetPosWalletByNetworkAndPosUseCase>(),
        exportWalletStatementDocumentUseCase:
            Get.find<ExportWalletStatementDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<PosDebtLedgerController>(
      () => PosDebtLedgerController(
        getDebtSummaryUseCase: Get.find<GetDebtSummaryUseCase>(),
        getOutstandingInvoicesUseCase:
            Get.find<GetOutstandingInvoicesUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<RepaymentHistoryController>(
      () => RepaymentHistoryController(
        getRepaymentsUseCase: Get.find<GetRepaymentsUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        reverseRepaymentUseCase: Get.find<ReverseRepaymentUseCase>(),
        repaymentDocumentUseCase: Get.find<RepaymentDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<RepaymentCollectionController>(
      () => RepaymentCollectionController(
        collectRepaymentUseCase: Get.find<CollectRepaymentUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkWalletDashboardController>(
      () => NetworkWalletDashboardController(
        getNetworkWalletsUseCase: Get.find<GetNetworkWalletsUseCase>(),
        getNetworkWalletLogsUseCase: Get.find<GetNetworkWalletLogsUseCase>(),
        getNetworkWalletByIdUseCase: Get.find<GetNetworkWalletByIdUseCase>(),
        exportWalletStatementDocumentUseCase:
            Get.find<ExportWalletStatementDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkWalletTransferController>(
      () => NetworkWalletTransferController(
        transferFromNetworkToPosUseCase:
            Get.find<TransferFromNetworkToPosUseCase>(),
        transferPosToNetworkUseCase: Get.find<TransferPosToNetworkUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<UpdatePosCreditLimitController>(
      () => UpdatePosCreditLimitController(
        updatePosCreditLimitUseCase: Get.find<UpdatePosCreditLimitUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<ManualWalletTransactionController>(
      () => ManualWalletTransactionController(
        depositPosWalletUseCase: Get.find<DepositPosWalletUseCase>(),
        withdrawPosWalletUseCase: Get.find<WithdrawPosWalletUseCase>(),
        depositNetworkWalletUseCase: Get.find<DepositNetworkWalletUseCase>(),
        withdrawNetworkWalletUseCase: Get.find<WithdrawNetworkWalletUseCase>(),
      ),
      fenix: true,
    );
  }
}
