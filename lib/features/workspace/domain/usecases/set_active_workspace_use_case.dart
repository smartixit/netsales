import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';

/// حالة استخدام تعيين مساحة العمل النشطة
class SetActiveWorkspaceUseCase {
  final WorkspaceRepository _repository;

  const SetActiveWorkspaceUseCase(this._repository);

  Future<void> call(AppWorkspace workspace) {
    return _repository.setActiveWorkspace(workspace);
  }
}

