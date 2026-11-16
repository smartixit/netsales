import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/workspace/data/datasources/workspace_local_data_source.dart';
import 'package:netsales/features/workspace/data/datasources/workspace_local_data_source_impl.dart';
import 'package:netsales/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/domain/usecases/set_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';

/// ربط التبعيات لمنسق مساحات العمل
class WorkspaceCoordinatorBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<WorkspaceLocalDataSource>(
      () => WorkspaceLocalDataSourceImpl(
        storageService: StorageService.instance,
        workspaceService: WorkspaceService.to,
      ),
      fenix: true,
    );

    registerLazyIfAbsent<WorkspaceRepository>(
      () => WorkspaceRepositoryImpl(Get.find<WorkspaceLocalDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetActiveWorkspaceUseCase>(
      () => GetActiveWorkspaceUseCase(Get.find<WorkspaceRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<SetActiveWorkspaceUseCase>(
      () => SetActiveWorkspaceUseCase(Get.find<WorkspaceRepository>()),
      fenix: true,
    );

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
      () => WorkspaceCoordinatorController(
        getActiveWorkspaceUseCase: Get.find<GetActiveWorkspaceUseCase>(),
        setActiveWorkspaceUseCase: Get.find<SetActiveWorkspaceUseCase>(),
      ),
      fenix: true,
    );
  }
}
