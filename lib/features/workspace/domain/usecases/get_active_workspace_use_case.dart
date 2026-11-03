import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';

/// حالة استخدام جلب سياق مساحة العمل النشطة
class GetActiveWorkspaceUseCase {
  final WorkspaceRepository _repository;

  const GetActiveWorkspaceUseCase(this._repository);

  Future<WorkspaceContextEntity> call() {
    return _repository.getActiveWorkspaceContext();
  }
}

