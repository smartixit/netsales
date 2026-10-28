import 'package:get/get.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source_impl.dart';
import 'package:netsales/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/features/splash/domain/usecases/initialize_app_use_case.dart';
import 'package:netsales/features/splash/presentation/controllers/splash_controller.dart';

/// ربط وحقن اعتماديات واجهة الإقلاع
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashLocalDataSource>(() => const SplashLocalDataSourceImpl());
    Get.lazyPut<SplashRepository>(
      () => SplashRepositoryImpl(Get.find<SplashLocalDataSource>()),
    );
    Get.lazyPut<InitializeAppUseCase>(
      () => InitializeAppUseCase(Get.find<SplashRepository>()),
    );
    Get.lazyPut<DetermineBootDestinationUseCase>(
      () => DetermineBootDestinationUseCase(Get.find<SplashRepository>()),
    );
    Get.lazyPut<SplashController>(
      () => SplashController(
        Get.find<InitializeAppUseCase>(),
        Get.find<DetermineBootDestinationUseCase>(),
      ),
    );
  }
}

