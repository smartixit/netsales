import 'package:get/get.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';
import 'package:netsales/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/features/splash/presentation/controllers/splash_controller.dart';

/// ربط وحقن اعتماديات واجهة الإقلاع
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashLocalDataSource>(
      () => const SplashLocalDataSourceImpl(),
    );
    Get.lazyPut<SplashRepository>(
      () => SplashRepositoryImpl(Get.find<SplashLocalDataSource>()),
    );
    Get.lazyPut<DetermineBootDestinationUseCase>(
      () => DetermineBootDestinationUseCase(Get.find<SplashRepository>()),
    );
    Get.put<SplashController>(
      SplashController(Get.find<DetermineBootDestinationUseCase>()),
    );
  }
}
