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

class _NetworkOverviewRepository implements NetworkWorkspaceRepository {
  @override
  Future<NetworkWorkspaceOverviewEntity> getOverview(
    int networkId, {
    required String period,
  }) async {
    return NetworkWorkspaceOverviewEntity(
      networkId: networkId,
      networkName: 'شبكة الاختبار',
      generatedAt: '2026-11-21T10:00:00+03:00',
      periodKey: period,
      timezone: 'Asia/Aden',
      periodDays: 30,
      periodFrom: '2026-10-22',
      periodTo: '2026-11-21',
      sales: null,
      pointsOfSale: null,
      requests: null,
      packages: null,
      expenses: null,
      recentPendingRequests: const [],
    );
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

  test('selects the first authorized network when the saved network is no longer available', () async {
    await WorkspaceService.instance.saveActiveNetworkId(999);

    final controller = NetworkWorkspaceController(
      getMyNetworksUseCase: GetMyNetworksUseCase(_MultipleNetworksRepository()),
      getOverviewUseCase: GetNetworkWorkspaceOverviewUseCase(
        _NetworkOverviewRepository(),
      ),
    );
    controller.isLoadingOverview.value = true;

    await controller.loadWorkspace();

    expect(controller.networks, hasLength(2));
    expect(controller.selectedNetworkId.value, 10);
    expect(controller.overview.value?.networkId, 10);
    expect(controller.networksError.value, isNull);
    expect(controller.overviewError.value, isNull);
    expect(controller.isLoadingNetworks.value, isFalse);
    expect(controller.isLoadingOverview.value, isFalse);
  });

  test('keeps the saved network when it is still authorized', () async {
    await WorkspaceService.instance.saveActiveNetworkId(20);

    final controller = NetworkWorkspaceController(
      getMyNetworksUseCase: GetMyNetworksUseCase(_MultipleNetworksRepository()),
      getOverviewUseCase: GetNetworkWorkspaceOverviewUseCase(
        _NetworkOverviewRepository(),
      ),
    );

    await controller.loadWorkspace();

    expect(controller.selectedNetworkId.value, 20);
    expect(controller.overview.value?.networkId, 20);
  });
}
