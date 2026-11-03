import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/disconnect_device_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_devices_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/logout_other_devices_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/active_sessions_controller.dart';

/// ربط التبعيات لشاشة الأجهزة والجلسات النشطة
class ActiveSessionsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.lazyPut<AuthRemoteDataSource>(
        () => const AuthRemoteDataSourceImpl(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
        fenix: true,
      );
    }

    Get.lazyPut<GetDevicesUseCase>(
      () => GetDevicesUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<DisconnectDeviceUseCase>(
      () => DisconnectDeviceUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<LogoutOtherDevicesUseCase>(
      () => LogoutOtherDevicesUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<ActiveSessionsController>(
      () => ActiveSessionsController(
        getDevicesUseCase: Get.find<GetDevicesUseCase>(),
        disconnectDeviceUseCase: Get.find<DisconnectDeviceUseCase>(),
        logoutOtherDevicesUseCase: Get.find<LogoutOtherDevicesUseCase>(),
      ),
      fenix: true,
    );
  }
}
