import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/data/datasources/workspace_local_data_source.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';

/// تطبيق مستودع مساحات العمل
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceLocalDataSource _localDataSource;

  const WorkspaceRepositoryImpl(this._localDataSource);

  @override
  Future<WorkspaceContextEntity> getActiveWorkspaceContext() {
    return _localDataSource.getActiveWorkspaceContext();
  }

  @override
  Future<void> setActiveWorkspace(AppWorkspace workspace) {
    return _localDataSource.saveActiveWorkspace(workspace);
  }
}
