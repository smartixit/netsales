import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';

/// متحكم مساحة عمل نقطة البيع التفاعلي الشامل المرتبط كلياً بواجهات الـ API (PosWorkspaceController)
class PosWorkspaceController extends GetxController {
  PosWorkspaceController({
    required this.getMyPosUseCase,
    required this.getPosNetworksListUseCase,
    required this.getPosWalletByNetworkAndPosUseCase,
    this.getPosInvoicesUseCase,
    this.getRequestsUseCase,
    this.getNetworkPackagesUseCase,
  });

  final GetMyPosUseCase getMyPosUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final GetPosWalletByNetworkAndPosUseCase getPosWalletByNetworkAndPosUseCase;
  final GetPosInvoicesUseCase? getPosInvoicesUseCase;
  final GetRequestsUseCase? getRequestsUseCase;
  final GetNetworkPackagesUseCase? getNetworkPackagesUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final RxList<PosEntity> availablePos = <PosEntity>[].obs;
  final Rxn<PosEntity> activePos = Rxn<PosEntity>();
  final RxList<NetworkPosLinkEntity> networkLinks =
      <NetworkPosLinkEntity>[].obs;
  final Rxn<NetworkPosLinkEntity> selectedNetworkLink =
      Rxn<NetworkPosLinkEntity>();
  final Rxn<PosWalletEntity> selectedWallet = Rxn<PosWalletEntity>();

  // بيانات حية من الـ API: فواتير المشتريات، طلبات التوريد، وباقات الشبكة
  final RxList<InvoiceEntity> recentInvoices = <InvoiceEntity>[].obs;
  final RxList<RequestEntity> recentRequests = <RequestEntity>[].obs;
  final RxList<PackageEntity> networkPackages = <PackageEntity>[].obs;

  final RxBool isLoadingPos = false.obs;
  final RxBool isLoadingNetworks = false.obs;
  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingMoreNetworks = false.obs;
  final RxBool isLoadingRecentData = false.obs;
  final RxBool isLoadingPackages = false.obs;

  final RxnString posError = RxnString();
  final RxnString networksError = RxnString();
  final RxnString walletError = RxnString();
  final RxnString recentDataError = RxnString();
  final RxnString packagesError = RxnString();

  final RxnString networkCursor = RxnString();
  final RxBool hasMoreNetworks = false.obs;
  final RxInt currentNetworkIndex = 0.obs;

  int _posGeneration = 0;
  int _networkGeneration = 0;
  int _walletGeneration = 0;
  int _scopedDataGeneration = 0;

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

      final resolvedId = WorkspaceService.to.resolveActivePosId(
        positions.map((p) => p.posId).toList(),
      );
      final resolvedPosition = resolvedId != null
          ? positions.firstWhereOrNull((p) => p.posId == resolvedId)
          : null;

      if (resolvedPosition?.posId != previousPosId) {
        _clearNetworkContext();
      }
      activePos.value = resolvedPosition;

      if (resolvedPosition != null) {
        await WorkspaceService.to.saveActivePosId(resolvedPosition.posId);
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
    await WorkspaceService.to.saveActivePosId(pos.posId);
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
    } else {
      isLoadingMoreNetworks.value = true;
    }

    try {
      final result = await getPosNetworksListUseCase(
         posId,
        cursor: refresh ? null : networkCursor.value,
        perPage: 10,
      );
      if (generation != _networkGeneration ||
          activePos.value?.posId != posId) {
        return;
      }

      final knownIds = networkLinks.map((link) => link.networkId).toSet();
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
        final initialLink = savedLink ??
            (networkLinks.length == 1 ? networkLinks.single : null);
        if (initialLink != null) {
          await selectNetwork(
            initialLink,
            index: networkLinks.indexOf(initialLink),
          );
        }
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

      // جلب البيانات الحقيقية المرتبطة بالشبكة المحددة (فواتير، طلبات، باقات)
      await loadNetworkScopedData(link.networkId);
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

  /// تحميل البيانات الفعلية من الـ API الخاصة بالحركات والباقات للشبكة المحددة
  Future<void> loadNetworkScopedData(int networkId) async {
    final posId = activePos.value?.posId;
    if (posId == null) return;

    final scopedGen = ++_scopedDataGeneration;
    isLoadingRecentData.value = true;
    isLoadingPackages.value = true;
    recentDataError.value = null;
    packagesError.value = null;

    // 1. فواتير المشتريات من الـ API
    if (getPosInvoicesUseCase != null) {
      try {
        final invResult = await getPosInvoicesUseCase!(
          posId: posId,
          perPage: 5,
        );
        if (scopedGen == _scopedDataGeneration) {
          recentInvoices.assignAll(invResult.items);
        }
      } catch (e) {
        if (scopedGen == _scopedDataGeneration) {
          recentDataError.value = AppException.sanitizeMessage(
            e,
            fallback: 'تعذر جلب فواتير التوريد من الخادم.',
          );
        }
      } finally {
        if (scopedGen == _scopedDataGeneration) {
          isLoadingRecentData.value = false;
        }
      }
    } else {
      isLoadingRecentData.value = false;
    }

    // 2. طلبات التوريد من الـ API
    if (getRequestsUseCase != null) {
      try {
        final reqResult = await getRequestsUseCase!(
          posId: posId,
          networkId: networkId,
          perPage: 5,
        );
        if (scopedGen == _scopedDataGeneration) {
          recentRequests.assignAll(reqResult.items);
        }
      } catch (_) {
        // Non-fatal fallback
      }
    }

    // 3. باقات الشبكة المعتمدة من الـ API
    if (getNetworkPackagesUseCase != null) {
      try {
        final pkgs = await getNetworkPackagesUseCase!(networkId);
        if (scopedGen == _scopedDataGeneration) {
          networkPackages.assignAll(pkgs.items);
        }
      } catch (e) {
        if (scopedGen == _scopedDataGeneration) {
          packagesError.value = AppException.sanitizeMessage(
            e,
            fallback: 'تعذر جلب باقات الشبكة من الخادم.',
          );
        }
      } finally {
        if (scopedGen == _scopedDataGeneration) {
          isLoadingPackages.value = false;
        }
      }
    } else {
      isLoadingPackages.value = false;
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

  String _networkStorageKey(int posId) =>
      '${StorageKeys.activePosNetworkPrefix}_${SessionService.to.currentUser?.userId ?? 0}_$posId';

  void _clearNetworkContext() {
    ++_networkGeneration;
    ++_walletGeneration;
    ++_scopedDataGeneration;
    networkLinks.clear();
    selectedNetworkLink.value = null;
    selectedWallet.value = null;
    recentInvoices.clear();
    recentRequests.clear();
    networkPackages.clear();
    networkCursor.value = null;
    hasMoreNetworks.value = false;
    currentNetworkIndex.value = 0;
    isLoadingNetworks.value = false;
    isLoadingMoreNetworks.value = false;
    isLoadingWallet.value = false;
    isLoadingRecentData.value = false;
    isLoadingPackages.value = false;
    networksError.value = null;
    walletError.value = null;
    recentDataError.value = null;
    packagesError.value = null;
  }

  void onNavItemSelected(int index) {
    selectedNavIndex.value = index;
  }
}
