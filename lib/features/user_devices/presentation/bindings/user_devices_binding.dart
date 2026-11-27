import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/user_devices/data/datasources/user_devices_remote_data_source.dart';
import 'package:netsales/features/user_devices/data/datasources/user_devices_remote_data_source_impl.dart';
import 'package:netsales/features/user_devices/data/repositories/user_devices_repository_impl.dart';
import 'package:netsales/features/user_devices/domain/repositories/user_devices_repository.dart';
import 'package:netsales/features/user_devices/domain/usecases/disconnect_user_device_use_case.dart';
import 'package:netsales/features/user_devices/domain/usecases/get_user_devices_use_case.dart';
import 'package:netsales/features/user_devices/domain/usecases/logout_other_devices_use_case.dart';
import 'package:netsales/features/user_devices/presentation/controllers/user_devices_controller.dart';

/// ربط تبعيات وحدة الأجهزة المقترنة.
class UserDevicesBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<UserDevicesRemoteDataSource>(
      UserDevicesRemoteDataSourceImpl.new,
      fenix: true,
    );

    registerLazyIfAbsent<UserDevicesRepository>(
      () => UserDevicesRepositoryImpl(Get.find<UserDevicesRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetUserDevicesUseCase>(
      () => GetUserDevicesUseCase(Get.find<UserDevicesRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<DisconnectUserDeviceUseCase>(
      () => DisconnectUserDeviceUseCase(Get.find<UserDevicesRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<LogoutOtherDevicesUseCase>(
      () => LogoutOtherDevicesUseCase(Get.find<UserDevicesRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<UserDevicesController>(
      () => UserDevicesController(
        getDevicesUseCase: Get.find<GetUserDevicesUseCase>(),
        disconnectDeviceUseCase: Get.find<DisconnectUserDeviceUseCase>(),
        logoutOtherDevicesUseCase: Get.find<LogoutOtherDevicesUseCase>(),
      ),
      fenix: true,
    );
  }
}
