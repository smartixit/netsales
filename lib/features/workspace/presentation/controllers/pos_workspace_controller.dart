import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';

class PosWorkspaceController extends GetxController {
  PosWorkspaceController({
    required this.getMyPosUseCase,
    required this.getPosNetworksListUseCase,
    required this.getPosWalletByNetworkAndPosUseCase,
  });

  final GetMyPosUseCase getMyPosUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final GetPosWalletByNetworkAndPosUseCase
  getPosWalletByNetworkAndPosUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final RxList<PosEntity> availablePos = <PosEntity>[].obs;
  final Rxn<PosEntity> activePos = Rxn<PosEntity>();
  final RxList<NetworkPosLinkEntity> networkLinks =
      <NetworkPosLinkEntity>[].obs;
  final Rxn<NetworkPosLinkEntity> selectedNetworkLink =
      Rxn<NetworkPosLinkEntity>();
  final Rxn<PosWalletEntity> selectedWallet = Rxn<PosWalletEntity>();

  final RxBool isLoadingPos = false.obs;
  final RxBool isLoadingNetworks = false.obs;
  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingMoreNetworks = false.obs;
  final RxnString posError = RxnString();
  final RxnString networksError = RxnString();
  final RxnString walletError = RxnString();
  final RxnString networkCursor = RxnString();
  final RxBool hasMoreNetworks = false.obs;
  final RxInt currentNetworkIndex = 0.obs;

  int _networkGeneration = 0;
  int _walletGeneration = 0;
  bool _networkRequestInFlight = false;

  String get userName {
    final name = SessionService.to.currentUser?.userFullName.trim() ?? '';
    return name.isEmpty ? 'مرحباً بك' : name;
  }

  String get welcomePeriod {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'طاب يومك';
    return 'مساء الخير';
  }

  @override
  void onInit() {
    super.onInit();
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.pos) {
      WorkspaceService.to.setActiveWorkspace(AppWorkspace.pos);
    }
    loadWorkspace();
  }

  Future<void> loadWorkspace() async {
    await loadPosTenants();
    final pos = activePos.value;
    if (pos != null) await loadNetworks(pos.posId);
  }

  Future<void> loadPosTenants() async {
    if (isLoadingPos.value) return;
    isLoadingPos.value = true;
    posError.value = null;
    try {
      final result = await getMyPosUseCase();
      final posList = result;
      availablePos.assignAll(posList);
      if (posList.isEmpty) {
        activePos.value = null;
        networkLinks.clear();
        selectedNetworkLink.value = null;
        selectedWallet.value = null;
        return;
      }
      final savedId = StorageService.instance.getInt(
        StorageKeys.activePosTenantId,
      );
      final saved = posList.where((item) => item.posId == savedId);
      activePos.value = saved.isNotEmpty
          ? saved.first
          : (posList.length == 1 ? posList.first : null);
      if (activePos.value != null) {
        await StorageService.instance.setInt(
          StorageKeys.activePosTenantId,
          activePos.value!.posId,
        );
      }
    } catch (error) {
      posError.value = error.toString();
    } finally {
      isLoadingPos.value = false;
    }
  }

  Future<void> selectPos(PosEntity pos) async {
    if (activePos.value?.posId == pos.posId) return;
    activePos.value = pos;
    networkLinks.clear();
    selectedNetworkLink.value = null;
    selectedWallet.value = null;
    currentNetworkIndex.value = 0;
    networkCursor.value = null;
    hasMoreNetworks.value = false;
    _networkGeneration++;
    _walletGeneration++;
    await StorageService.instance.setInt(
      StorageKeys.activePosTenantId,
      pos.posId,
    );
    await loadNetworks(pos.posId);
  }

  Future<void> loadNetworks(int posId, {bool refresh = true}) async {
    if (_networkRequestInFlight) return;
    if (!refresh && (!hasMoreNetworks.value || isLoadingMoreNetworks.value)) {
      return;
    }
    _networkRequestInFlight = true;
    final generation = ++_networkGeneration;
    if (refresh) {
      isLoadingNetworks.value = true;
      networksError.value = null;
      networkLinks.clear();
      networkCursor.value = null;
      hasMoreNetworks.value = false;
    } else {
      isLoadingMoreNetworks.value = true;
    }
    try {
      final result = await getPosNetworksListUseCase(
        posId,
        cursor: refresh ? null : networkCursor.value,
        status: true,
        perPage: 12,
      );
      if (generation != _networkGeneration ||
          activePos.value?.posId != posId) return;
      final knownIds = networkLinks.map((item) => item.networkId).toSet();
      networkLinks.addAll(
        result.items.where((item) => !knownIds.contains(item.networkId)),
      );
      networkCursor.value = result.nextCursor;
      hasMoreNetworks.value = result.hasMore;
      if (selectedNetworkLink.value == null && networkLinks.isNotEmpty) {
        final savedId = StorageService.instance.getInt(_networkStorageKey(posId));
        final saved = networkLinks.where((item) => item.networkId == savedId);
        final first = saved.isNotEmpty ? saved.first : networkLinks.first;
        await selectNetwork(first, index: networkLinks.indexOf(first));
      }
    } catch (error) {
      if (generation == _networkGeneration) networksError.value = error.toString();
    } finally {
      if (generation == _networkGeneration) {
        isLoadingNetworks.value = false;
        isLoadingMoreNetworks.value = false;
      }
      _networkRequestInFlight = false;
    }
  }

  Future<void> selectNetwork(
    NetworkPosLinkEntity link, {
    int? index,
  }) async {
    final posId = activePos.value?.posId;
    if (posId == null || !link.status) return;
    selectedNetworkLink.value = link;
    currentNetworkIndex.value = index ?? networkLinks.indexOf(link);
    selectedWallet.value = null;
    walletError.value = null;
    await StorageService.instance.setInt(
      _networkStorageKey(posId),
      link.networkId,
    );
    final generation = ++_walletGeneration;
    isLoadingWallet.value = true;
    try {
      final wallet = await getPosWalletByNetworkAndPosUseCase(
        link.networkId,
        posId,
      );
      if (generation != _walletGeneration ||
          activePos.value?.posId != posId ||
          selectedNetworkLink.value?.networkId != link.networkId) return;
      selectedWallet.value = wallet;
    } catch (error) {
      if (generation == _walletGeneration) walletError.value = error.toString();
    } finally {
      if (generation == _walletGeneration) isLoadingWallet.value = false;
    }
  }

  Future<void> onNetworkPageChanged(int index) async {
    if (index < 0 || index >= networkLinks.length) return;
    await selectNetwork(networkLinks[index], index: index);
    if (index >= networkLinks.length - 2 && hasMoreNetworks.value) {
      final posId = activePos.value?.posId;
      if (posId != null) await loadNetworks(posId, refresh: false);
    }
  }

  Future<void> retryNetworks() async {
    final posId = activePos.value?.posId;
    if (posId != null) await loadNetworks(posId);
  }

  String _networkStorageKey(int posId) =>
      '${StorageKeys.activePosNetworkPrefix}_${SessionService.to.currentUser?.userId ?? 0}_$posId';

  void onNavItemSelected(int index) => selectedNavIndex.value = index;
}
