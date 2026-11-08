import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';

/// Reactive POS home state and tenant-scoped network account selection.
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

  int _posGeneration = 0;
  int _networkGeneration = 0;
  int _walletGeneration = 0;

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
    final posId = activePos.value?.posId;
    if (posId != null) {
      await loadNetworks(posId);
    }
  }

  Future<void> loadPosTenants() async {
    if (isLoadingPos.value) return;
    final generation = ++_posGeneration;
    isLoadingPos.value = true;
    posError.value = null;

    try {
      final positions = await getMyPosUseCase();
      if (generation != _posGeneration) return;

      final previousPosId = activePos.value?.posId;
      availablePos.assignAll(positions);

      final savedPosId = StorageService.instance.getInt(
        _posStorageKey,
      );
      final savedPosition = positions.firstWhereOrNull(
        (position) => position.posId == savedPosId,
      );
      final resolvedPosition = savedPosition ??
          (positions.length == 1 ? positions.first : null);

      if (resolvedPosition?.posId != previousPosId) {
        _clearNetworkContext();
      }
      activePos.value = resolvedPosition;

      if (resolvedPosition != null) {
        await StorageService.instance.setInt(
          _posStorageKey,
          resolvedPosition.posId,
        );
      }
    } catch (error) {
      if (generation == _posGeneration) {
        posError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل نقاط البيع المصرح بها.',
        );
      }
    } finally {
      if (generation == _posGeneration) {
        isLoadingPos.value = false;
      }
    }
  }

  Future<void> selectPos(PosEntity pos) async {
    if (activePos.value?.posId == pos.posId) return;

    activePos.value = pos;
    _clearNetworkContext();
    await StorageService.instance.setInt(_posStorageKey, pos.posId);
    await loadNetworks(pos.posId);
  }

  Future<void> loadNetworks(int posId, {bool refresh = true}) async {
    if (activePos.value?.posId != posId) return;
    if (!refresh &&
        (!hasMoreNetworks.value ||
            isLoadingNetworks.value ||
            isLoadingMoreNetworks.value)) {
      return;
    }

    final generation = ++_networkGeneration;
    if (refresh) {
      isLoadingNetworks.value = true;
      isLoadingMoreNetworks.value = false;
      networksError.value = null;
      networkLinks.clear();
      networkCursor.value = null;
      hasMoreNetworks.value = false;
      selectedNetworkLink.value = null;
      selectedWallet.value = null;
      currentNetworkIndex.value = 0;
      ++_walletGeneration;
      isLoadingWallet.value = false;
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
          activePos.value?.posId != posId) {
        return;
      }

      final knownIds = networkLinks.map((item) => item.networkId).toSet();
      for (final link in result.items) {
        if (knownIds.add(link.networkId)) {
          networkLinks.add(link);
        }
      }
      networkCursor.value = result.nextCursor;
      hasMoreNetworks.value = result.hasMore;

      if (selectedNetworkLink.value == null && networkLinks.isNotEmpty) {
        final savedNetworkId = StorageService.instance.getInt(
          _networkStorageKey(posId),
        );
        final savedLink = networkLinks.firstWhereOrNull(
          (link) => link.networkId == savedNetworkId && link.status,
        );
        final initialLink = savedLink ?? networkLinks.first;
        await selectNetwork(
          initialLink,
          index: networkLinks.indexOf(initialLink),
        );
      }
    } catch (error) {
      if (generation == _networkGeneration) {
        networksError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل الشبكات المرتبطة بنقطة البيع.',
        );
      }
    } finally {
      if (generation == _networkGeneration) {
        isLoadingNetworks.value = false;
        isLoadingMoreNetworks.value = false;
      }
    }
  }

  Future<void> selectNetwork(
    NetworkPosLinkEntity link, {
    int? index,
    bool forceRefresh = false,
  }) async {
    final posId = activePos.value?.posId;
    if (posId == null || !link.status) return;

    final isSameNetwork =
        selectedNetworkLink.value?.networkId == link.networkId;
    if (isSameNetwork &&
        !forceRefresh &&
        (selectedWallet.value != null || isLoadingWallet.value)) {
      return;
    }

    selectedNetworkLink.value = link;
    currentNetworkIndex.value = index ?? networkLinks.indexOf(link);
    selectedWallet.value = null;
    walletError.value = null;

    final generation = ++_walletGeneration;
    isLoadingWallet.value = true;
    try {
      await StorageService.instance.setInt(
        _networkStorageKey(posId),
        link.networkId,
      );
      if (generation != _walletGeneration) return;

      final wallet = await getPosWalletByNetworkAndPosUseCase(
        link.networkId,
        posId,
      );
      if (generation != _walletGeneration ||
          activePos.value?.posId != posId ||
          selectedNetworkLink.value?.networkId != link.networkId) {
        return;
      }
      selectedWallet.value = wallet;
    } catch (error) {
      if (generation == _walletGeneration) {
        walletError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل الحساب المالي لهذه الشبكة.',
        );
      }
    } finally {
      if (generation == _walletGeneration) {
        isLoadingWallet.value = false;
      }
    }
  }

  Future<void> onNetworkPageChanged(int index) async {
    if (index < 0 || index >= networkLinks.length) return;
    await selectNetwork(networkLinks[index], index: index);

    if (index >= networkLinks.length - 2 && hasMoreNetworks.value) {
      final posId = activePos.value?.posId;
      if (posId != null) {
        await loadNetworks(posId, refresh: false);
      }
    }
  }

  Future<void> retryNetworks() async {
    final posId = activePos.value?.posId;
    if (posId != null) {
      await loadNetworks(posId);
    }
  }

  Future<void> retrySelectedWallet() async {
    final link = selectedNetworkLink.value;
    if (link == null) return;
    await selectNetwork(
      link,
      index: currentNetworkIndex.value,
      forceRefresh: true,
    );
  }

  String get _posStorageKey =>
      '${StorageKeys.activePosTenantPrefix}_${SessionService.to.currentUser?.userId ?? 0}';

  String _networkStorageKey(int posId) =>
      '${StorageKeys.activePosNetworkPrefix}_${SessionService.to.currentUser?.userId ?? 0}_$posId';

  void _clearNetworkContext() {
    ++_networkGeneration;
    ++_walletGeneration;
    networkLinks.clear();
    selectedNetworkLink.value = null;
    selectedWallet.value = null;
    networkCursor.value = null;
    hasMoreNetworks.value = false;
    currentNetworkIndex.value = 0;
    isLoadingNetworks.value = false;
    isLoadingMoreNetworks.value = false;
    isLoadingWallet.value = false;
    networksError.value = null;
    walletError.value = null;
  }

  void onNavItemSelected(int index) {
    selectedNavIndex.value = index;
  }
}
