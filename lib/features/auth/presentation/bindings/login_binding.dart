import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/login_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';

/// تسجيل وحقن اعتماديات شاشة تسجيل الدخول وفق المعمارية النظيفة
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(() => const AuthRemoteDataSourceImpl());

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
    );

    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find<AuthRepository>()));

    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginUseCase>()),
      fenix: true,
    );
  }
}
