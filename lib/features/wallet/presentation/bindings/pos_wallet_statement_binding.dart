import 'package:get/get.dart';
import 'package:netsales/features/wallet/data/datasources/pos_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/data/datasources/pos_wallet_remote_data_source_impl.dart';
import 'package:netsales/features/wallet/data/repositories/pos_wallet_repository_impl.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';
import 'package:netsales/features/wallet/domain/usecases/get_pos_wallet_by_network_and_pos_use_case.dart';
import 'package:netsales/features/wallet/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/wallet/presentation/controllers/pos_wallet_statement_controller.dart';

/// ربط التبعيات لشاشة كشف حساب ودفتر أستاذ محفظة نقطة البيع (GetX Binding)
class PosWalletStatementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosWalletRemoteDataSource>(
      () => const PosWalletRemoteDataSourceImpl(),
    );

    Get.lazyPut<PosWalletRepository>(
      () => PosWalletRepositoryImpl(Get.find<PosWalletRemoteDataSource>()),
    );

    Get.lazyPut<GetPosWalletByNetworkAndPosUseCase>(
      () => GetPosWalletByNetworkAndPosUseCase(Get.find<PosWalletRepository>()),
    );

    Get.lazyPut<GetPosWalletLogsUseCase>(
      () => GetPosWalletLogsUseCase(Get.find<PosWalletRepository>()),
    );

    Get.lazyPut<PosWalletStatementController>(
      () => PosWalletStatementController(
        getPosWalletByNetworkAndPosUseCase:
            Get.find<GetPosWalletByNetworkAndPosUseCase>(),
        getPosWalletLogsUseCase: Get.find<GetPosWalletLogsUseCase>(),
      ),
    );
  }
}
