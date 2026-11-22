import 'package:get/get.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/wallet/data/datasources/network_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/data/datasources/network_wallet_remote_data_source_impl.dart';
import 'package:netsales/features/wallet/data/repositories/network_wallet_repository_impl.dart';
import 'package:netsales/features/wallet/domain/repositories/network_wallet_repository.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_logs_use_case.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_use_case.dart';
import 'package:netsales/features/wallet/presentation/controllers/network_wallet_statement_controller.dart';

/// ربط التبعيات لشاشة كشف حساب وخزينة مزود الشبكة (Network Wallet Statement Binding)
class NetworkWalletStatementBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<NetworkWalletRemoteDataSource>(
      () => NetworkWalletRemoteDataSourceImpl(Get.find<ApiService>()),
    );

    // 2. Repository
    Get.lazyPut<NetworkWalletRepository>(
      () => NetworkWalletRepositoryImpl(
        Get.find<NetworkWalletRemoteDataSource>(),
      ),
    );

    // 3. Use Cases
    Get.lazyPut<GetNetworkWalletUseCase>(
      () => GetNetworkWalletUseCase(Get.find<NetworkWalletRepository>()),
    );
    Get.lazyPut<GetNetworkWalletLogsUseCase>(
      () => GetNetworkWalletLogsUseCase(Get.find<NetworkWalletRepository>()),
    );

    // 4. Controller
    Get.lazyPut<NetworkWalletStatementController>(
      () => NetworkWalletStatementController(
        getNetworkWalletUseCase: Get.find<GetNetworkWalletUseCase>(),
        getNetworkWalletLogsUseCase: Get.find<GetNetworkWalletLogsUseCase>(),
      ),
    );
  }
}
