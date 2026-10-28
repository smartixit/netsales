import 'package:get/get.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source_impl.dart';
import 'package:netsales/features/partners/data/repositories/partners_repository_impl.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';
import 'package:netsales/features/partners/domain/usecases/approve_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/reject_partner_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/toggle_network_pos_status_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/transfer_pos_wallet_balance_use_case.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/controllers/pos_wallet_sheet_controller.dart';

/// ============================================================================
/// رابط حقن تبعيات الشركاء ونقاط التوزيع (PartnersBinding)
/// ============================================================================
/// يربط سلسلة التبعيات كاملة طبقاً لقاعدة سريان الاعتمادية للداخل (Inward Dependency Rule):
/// DataSource -> Repository -> UseCases -> Controller.
class PartnersBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<PartnersRemoteDataSource>(
      () => const PartnersRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Repository
    Get.lazyPut<PartnersRepository>(
      () => PartnersRepositoryImpl(Get.find<PartnersRemoteDataSource>()),
      fenix: true,
    );

    // 3. Atomic UseCases
    Get.lazyPut<GetNetworksUseCase>(
      () => GetNetworksUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosListUseCase>(
      () => GetPosListUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetNetworkPosListUseCase>(
      () => GetNetworkPosListUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<ToggleNetworkPosStatusUseCase>(
      () => ToggleNetworkPosStatusUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<ApprovePartnerUseCase>(
      () => ApprovePartnerUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<RejectPartnerUseCase>(
      () => RejectPartnerUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosWalletUseCase>(
      () => GetPosWalletUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<TransferPosWalletBalanceUseCase>(
      () => TransferPosWalletBalanceUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosWalletLogsUseCase>(
      () => GetPosWalletLogsUseCase(Get.find<PartnersRepository>()),
      fenix: true,
    );

    // 4. Controller
    Get.lazyPut<PartnersController>(
      () => PartnersController(
        getNetworksUseCase: Get.find<GetNetworksUseCase>(),
        getPosListUseCase: Get.find<GetPosListUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        toggleNetworkPosStatusUseCase: Get.find<ToggleNetworkPosStatusUseCase>(),
        approvePartnerUseCase: Get.find<ApprovePartnerUseCase>(),
        rejectPartnerUseCase: Get.find<RejectPartnerUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PosWalletSheetController>(
      () => PosWalletSheetController(
        getPosWalletUseCase: Get.find<GetPosWalletUseCase>(),
        transferPosWalletBalanceUseCase:
            Get.find<TransferPosWalletBalanceUseCase>(),
        getPosWalletLogsUseCase: Get.find<GetPosWalletLogsUseCase>(),
      ),
      fenix: true,
    );
  }
}
