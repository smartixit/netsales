import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/domain/usecases/set_active_workspace_use_case.dart';

class MockWorkspaceRepository implements WorkspaceRepository {
  WorkspaceContextEntity _context = const WorkspaceContextEntity(
    workspace: AppWorkspace.network,
    tenantId: 100,
    tenantName: 'Smart Network',
    roleKey: 'NETWORK_OWNER',
    permissions: ['view_dashboard', 'manage_pos'],
  );

  @override
  Future<WorkspaceContextEntity> getActiveWorkspaceContext() async {
    return _context;
  }

  @override
  Future<void> setActiveWorkspace(AppWorkspace workspace) async {
    _context = _context.copyWith(workspace: workspace);
  }
}

void main() {
  group('Workspace Clean Architecture Domain & UseCase Tests', () {
    late MockWorkspaceRepository repository;
    late GetActiveWorkspaceUseCase getActiveWorkspaceUseCase;
    late SetActiveWorkspaceUseCase setActiveWorkspaceUseCase;

    setUp(() {
      repository = MockWorkspaceRepository();
      getActiveWorkspaceUseCase = GetActiveWorkspaceUseCase(repository);
      setActiveWorkspaceUseCase = SetActiveWorkspaceUseCase(repository);
    });

    test(
      'GetActiveWorkspaceUseCase returns current active workspace context',
      () async {
        final context = await getActiveWorkspaceUseCase();

        expect(context.workspace, equals(AppWorkspace.network));
        expect(context.isNetwork, isTrue);
        expect(context.isPos, isFalse);
        expect(context.tenantId, equals(100));
        expect(context.tenantName, equals('Smart Network'));
        expect(context.roleKey, equals('NETWORK_OWNER'));
        expect(context.permissions.contains('manage_pos'), isTrue);
      },
    );

    test(
      'SetActiveWorkspaceUseCase updates active workspace successfully',
      () async {
        await setActiveWorkspaceUseCase(AppWorkspace.pos);
        final updatedContext = await getActiveWorkspaceUseCase();

        expect(updatedContext.workspace, equals(AppWorkspace.pos));
        expect(updatedContext.isPos, isTrue);
        expect(updatedContext.isNetwork, isFalse);
      },
    );

    test('WorkspaceContextEntity unsupported state check', () {
      const unsupported = WorkspaceContextEntity(
        workspace: AppWorkspace.unsupported,
      );

      expect(unsupported.isUnsupported, isTrue);
      expect(unsupported.isNetwork, isFalse);
      expect(unsupported.isPos, isFalse);
    });
  });
}
