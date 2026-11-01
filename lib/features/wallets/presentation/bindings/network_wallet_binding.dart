import 'package:get/get.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source.dart';
import 'package:netsales/features/wallets/data/datasources/wallets_remote_data_source_impl.dart';
import 'package:netsales/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:netsales/features/wallets/domain/usecases/get_network_wallet_logs_use_case.dart';
import 'package:netsales/features/wallets/domain/usecases/get_network_wallet_use_case.dart';
import 'package:netsales/features/wallets/presentation/controllers/network_wallet_controller.dart';

class NetworkWalletBinding extends Bindings {
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

    Get.lazyPut<GetNetworkWalletUseCase>(
      () => GetNetworkWalletUseCase(Get.find<WalletsRepository>()),
    );

    Get.lazyPut<GetNetworkWalletLogsUseCase>(
      () => GetNetworkWalletLogsUseCase(Get.find<WalletsRepository>()),
    );

    Get.lazyPut<NetworkWalletController>(
      () => NetworkWalletController(
        getNetworkWalletUseCase: Get.find<GetNetworkWalletUseCase>(),
        getNetworkWalletLogsUseCase: Get.find<GetNetworkWalletLogsUseCase>(),
      ),
    );
  }
}

