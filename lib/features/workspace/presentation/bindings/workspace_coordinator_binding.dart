import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';

/// Dependencies shared by the workspace shell and profile actions.
class WorkspaceCoordinatorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      registerLazyIfAbsent<AuthRemoteDataSource>(
        () => const AuthRemoteDataSourceImpl(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AuthRepository>()) {
      registerLazyIfAbsent<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<LogoutUseCase>()) {
      registerLazyIfAbsent<LogoutUseCase>(
        () => LogoutUseCase(Get.find<AuthRepository>()),
        fenix: true,
      );
    }

    registerLazyIfAbsent<WorkspaceCoordinatorController>(
      WorkspaceCoordinatorController.new,
      fenix: true,
    );
  }
}
