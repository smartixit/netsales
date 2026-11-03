import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';

/// العقد الدوميني لمستودع مساحات العمل
abstract class WorkspaceRepository {
  /// استرجاع سياق مساحة العمل الحالية
  Future<WorkspaceContextEntity> getActiveWorkspaceContext();

  /// تعيين مساحة العمل النشطة
  Future<void> setActiveWorkspace(AppWorkspace workspace);
}
