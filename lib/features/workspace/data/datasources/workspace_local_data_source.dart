import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/workspace/data/models/workspace_context_model.dart';

/// واجهة مصدر البيانات المحلي لمساحة العمل
abstract class WorkspaceLocalDataSource {
  Future<WorkspaceContextModel> getActiveWorkspaceContext();
  Future<void> saveActiveWorkspace(AppWorkspace workspace);
}

/// تطبيق مصدر البيانات المحلي بالاعتماد على StorageService و WorkspaceService
class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {
  final StorageService _storageService;
  final WorkspaceService _workspaceService;

  const WorkspaceLocalDataSourceImpl({
    required this._storageService,
    required this._workspaceService,
  });

  @override
  Future<WorkspaceContextModel> getActiveWorkspaceContext() async {
    final user = SessionService.to.currentUser;
    final resolved = _workspaceService.resolveWorkspaceForUser(user);
    final permissions = _storageService.getStringList(
      StorageKeys.permissionsStorage,
    );

    return WorkspaceContextModel(
      workspace: resolved,
      roleKey: user?.role?.roleKey,
      permissions: permissions,
    );
  }

  @override
  Future<void> saveActiveWorkspace(AppWorkspace workspace) async {
    await _storageService.setString(
      StorageKeys.activeWorkspaceKey,
      workspace.name,
    );
    await _workspaceService.setActiveWorkspace(workspace);
  }
}
