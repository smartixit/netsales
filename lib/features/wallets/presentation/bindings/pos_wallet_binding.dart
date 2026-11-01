import 'package:get/get.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source_impl.dart';
import 'package:netsales/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_linked_networks_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/features/wallets/presentation/controllers/pos_wallet_controller.dart';

class PosWalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletsRemoteDataSource>()) {
      Get.lazyPut<WalletsRemoteDataSource>(() => const WalletsRemoteDataSourceImpl());
    }

    if (!Get.isRegistered<WalletsRepository>()) {
      Get.lazyPut<WalletsRepository>(
        () => WalletsRepositoryImpl(remoteDataSource: Get.find<WalletsRemoteDataSource>()),
      );
    }

    Get.lazyPut<GetPosLinkedNetworksUseCase>(
      () => GetPosLinkedNetworksUseCase(Get.find<WalletsRepository>()),
    );

    Get.lazyPut<GetPosWalletUseCase>(
      () => GetPosWalletUseCase(Get.find<WalletsRepository>()),
    );

    Get.lazyPut<GetPosWalletLogsUseCase>(
      () => GetPosWalletLogsUseCase(Get.find<WalletsRepository>()),
    );

    Get.lazyPut<PosWalletController>(
      () => PosWalletController(
        getPosLinkedNetworksUseCase: Get.find<GetPosLinkedNetworksUseCase>(),
        getPosWalletUseCase: Get.find<GetPosWalletUseCase>(),
        getPosWalletLogsUseCase: Get.find<GetPosWalletLogsUseCase>(),
      ),
    );
  }
}

