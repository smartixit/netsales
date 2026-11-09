import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/data/models/workspace_context_model.dart';

/// واجهة مصدر البيانات المحلي لمساحة العمل
abstract interface class WorkspaceLocalDataSource {
  Future<WorkspaceContextModel> getActiveWorkspaceContext();
  Future<void> saveActiveWorkspace(AppWorkspace workspace);
}
