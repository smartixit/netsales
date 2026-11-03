import 'package:get/get.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/workspace/data/datasources/workspace_local_data_source.dart';
import 'package:netsales/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/domain/usecases/set_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';

/// ربط التبعيات لمنسق مساحات العمل
class WorkspaceCoordinatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkspaceLocalDataSource>(
      () => WorkspaceLocalDataSourceImpl(
        storageService: StorageService.instance,
        workspaceService: WorkspaceService.to,
      ),
      fenix: true,
    );

    Get.lazyPut<WorkspaceRepository>(
      () => WorkspaceRepositoryImpl(Get.find<WorkspaceLocalDataSource>()),
      fenix: true,
    );

    Get.lazyPut<GetActiveWorkspaceUseCase>(
      () => GetActiveWorkspaceUseCase(Get.find<WorkspaceRepository>()),
      fenix: true,
    );

    Get.lazyPut<SetActiveWorkspaceUseCase>(
      () => SetActiveWorkspaceUseCase(Get.find<WorkspaceRepository>()),
      fenix: true,
    );

    Get.lazyPut<WorkspaceCoordinatorController>(
      () => WorkspaceCoordinatorController(
        getActiveWorkspaceUseCase: Get.find<GetActiveWorkspaceUseCase>(),
        setActiveWorkspaceUseCase: Get.find<SetActiveWorkspaceUseCase>(),
      ),
      fenix: true,
    );
  }
}
