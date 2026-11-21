import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MultipleNetworksRepository implements CommercialRepository {
  @override
  Future<List<NetworkEntity>> getMyNetworks() async => const [
    NetworkEntity(
      networkId: 10,
      ownerId: 1,
      networkName: 'الشبكة الأولى',
      networkPhoneNumber: '700000010',
    ),
    NetworkEntity(
      networkId: 20,
      ownerId: 1,
      networkName: 'الشبكة الثانية',
      networkPhoneNumber: '700000020',
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedOverviewRepository implements NetworkWorkspaceRepository {
  @override
  Future<NetworkWorkspaceOverviewEntity> getOverview(
    int networkId, {
    required String period,
  }) {
    throw StateError('No overview should load before explicit network selection.');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<SessionService>(SessionService.instance);
    await SessionService.instance.init();
    await WorkspaceService.instance.init();
  });

  tearDown(Get.reset);

  test('clears stale overview loading when refresh requires explicit tenant choice', () async {
    await WorkspaceService.instance.saveActiveNetworkId(999);

    final controller = NetworkWorkspaceController(
      getMyNetworksUseCase: GetMyNetworksUseCase(_MultipleNetworksRepository()),
      getOverviewUseCase: GetNetworkWorkspaceOverviewUseCase(
        _UnusedOverviewRepository(),
      ),
    );
    controller.isLoadingOverview.value = true;

    await controller.loadWorkspace();

    expect(controller.networks, hasLength(2));
    expect(controller.selectedNetworkId.value, isNull);
    expect(controller.overview.value, isNull);
    expect(controller.isLoadingNetworks.value, isFalse);
    expect(controller.isLoadingOverview.value, isFalse);
  });
}
