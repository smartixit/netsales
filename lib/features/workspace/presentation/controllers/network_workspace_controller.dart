import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkWorkspaceController extends GetxController {
  NetworkWorkspaceController({
    required this.getMyNetworksUseCase,
    required this.getOverviewUseCase,
  });

  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkWorkspaceOverviewUseCase getOverviewUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final networks = <NetworkEntity>[].obs;
  final RxnInt selectedNetworkId = RxnInt();
  final Rxn<NetworkWorkspaceOverviewEntity> overview =
      Rxn<NetworkWorkspaceOverviewEntity>();
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final selectedPeriod = '30d'.obs;
  int _revision = 0;

  NetworkEntity? get selectedNetwork => networks.firstWhereOrNull(
    (network) => network.networkId == selectedNetworkId.value,
  );

  @override
  void onInit() {
    super.onInit();
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.network) {
      WorkspaceService.to.setActiveWorkspace(AppWorkspace.network);
    }
    loadWorkspace();
  }

  @override
  void onClose() {
    _revision++;
    super.onClose();
  }

  void onNavItemSelected(int index) => selectedNavIndex.value = index;

  Future<void> loadWorkspace() async {
    final revision = ++_revision;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await getMyNetworksUseCase();
      if (revision != _revision) return;
      networks.assignAll(result);
      if (selectedNetworkId.value == null ||
          !result.any((network) => network.networkId == selectedNetworkId.value)) {
        selectedNetworkId.value = result.isEmpty ? null : result.first.networkId;
      }
      await loadOverview(revision: revision);
    } catch (error) {
      if (revision != _revision) return;
      errorMessage.value = error is AppException
          ? error.message
          : 'تعذر تحميل مساحة عمل الشبكة.';
    } finally {
      if (revision == _revision) isLoading.value = false;
    }
  }

  Future<void> loadOverview({int? revision}) async {
    final requestRevision = revision ?? ++_revision;
    final networkId = selectedNetworkId.value;
    if (networkId == null) {
      overview.value = null;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await getOverviewUseCase(
        networkId,
        period: selectedPeriod.value,
      );
      if (requestRevision != _revision) return;
      if (result.networkId != networkId) {
        throw const FormatException('أعاد الخادم ملخص شبكة غير الشبكة المحددة.');
      }
      overview.value = result;
    } catch (error) {
      if (requestRevision != _revision) return;
      overview.value = null;
      errorMessage.value = error is AppException
          ? error.message
          : error is FormatException
              ? error.message
              : 'تعذر جلب مؤشرات الشبكة.';
    } finally {
      if (requestRevision == _revision) isLoading.value = false;
    }
  }

  Future<void> selectNetwork(int? networkId) async {
    if (networkId == null || networkId == selectedNetworkId.value) return;
    selectedNetworkId.value = networkId;
    await loadOverview();
  }

  Future<void> selectPeriod(String period) async {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    await loadOverview();
  }
}
