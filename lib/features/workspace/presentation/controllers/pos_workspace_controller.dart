import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/greeting_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_active_supply_order_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_linked_network_option_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_workspace_transaction_mapper.dart';
import 'package:netsales/features/workspace/presentation/models/pos_active_supply_order_view_model.dart';
import 'package:netsales/features/workspace/presentation/models/pos_linked_network_option_view_model.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';

/// Coordinates POS selection, linked supplier selection and dashboard data.
class PosWorkspaceController extends GetxController {
  PosWorkspaceController({
    required this.getMyPosUseCase,
    required this.getPosNetworksListUseCase,
    required this.getPosInvoicesUseCase,
    required this.getRequestsUseCase,
    required this.previewNetworkPosLinkChallengeUseCase,
    required this.confirmNetworkPosLinkChallengeUseCase,
  });

  final GetMyPosUseCase getMyPosUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final GetPosInvoicesUseCase getPosInvoicesUseCase;
  final GetRequestsUseCase getRequestsUseCase;
  final PreviewNetworkPosLinkChallengeUseCase previewNetworkPosLinkChallengeUseCase;
  final ConfirmNetworkPosLinkChallengeUseCase confirmNetworkPosLinkChallengeUseCase;

  final RxInt selectedNavIndex = 0.obs;
  final RxList<PosEntity> availablePos = <PosEntity>[].obs;
  final Rxn<PosEntity> activePos = Rxn<PosEntity>();
  final RxList<NetworkPosLinkEntity> networkLinks = <NetworkPosLinkEntity>[].obs;
  final Rxn<NetworkPosLinkEntity> selectedNetworkLink = Rxn<NetworkPosLinkEntity>();

  final RxList<InvoiceEntity> recentInvoices = <InvoiceEntity>[].obs;
  final RxList<RequestEntity> recentRequests = <RequestEntity>[].obs;

  final RxBool isLoadingPos = false.obs;
  final RxBool isLoadingNetworks = false.obs;
  final RxBool isLoadingMoreNetworks = false.obs;
  final RxBool isLoadingRecentData = false.obs;

  final RxnString posError = RxnString();
  final RxnString networksError = RxnString();
  final RxnString recentInvoicesError = RxnString();
  final RxnString recentRequestsError = RxnString();

  final RxnString networkCursor = RxnString();
  final RxBool hasMoreNetworks = false.obs;

  int _posGeneration = 0;
  int _networkGeneration = 0;
  int _scopedDataGeneration = 0;

  String get userName {
    final name = SessionService.to.currentUser?.userFullName.trim() ?? '';
    return name.isEmpty ? 'مرحباً بك' : name;
  }

  String get welcomeGreeting => GreetingFormatter.greeting();
  String get todayFormatted => DateFormatter.fullDate(DateTime.now());
  String get activePosName => activePos.value?.posName ?? '';
  String? get userProfileLogo => SessionService.to.currentUser?.userProfileLogo;
  String get userInitials => TextFormatter.avatarInitials(userName, maxChars: 2);

  EnumPresentation get rolePresentation {
    final user = SessionService.to.currentUser;
    final activePosId = activePos.value?.posId;
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (item) =>
          item.scope == RoleScope.pos &&
          activePosId != null &&
          item.tenantId == activePosId,
    );
    final rawRoleKey =
        membership?.roleKey ?? user?.role?.roleKey ?? user?.generalRoleKey;
    final serverLabel =
        membership?.roleName ??
        user?.role?.roleName ??
        user?.role?.roleKeyLabel;
    final presentation = EnumPresentationRegistry.resolveRoleKey(
      RoleKey.fromWire(rawRoleKey),
      serverLabel: serverLabel,
    );
    if (presentation.isKnown) return presentation;
    return EnumPresentationRegistry.resolveRoleScope(
      RoleScope.pos,
      serverLabel: serverLabel,
    );
  }

  String get userRole => rolePresentation.label;

  PosActiveSupplyOrderViewModel? get activeSupplyOrder =>
      PosActiveSupplyOrderMapper.map(recentRequests);

  int? get selectedNetworkPosId => selectedNetworkLink.value?.networkPosId;

  List<PosLinkedNetworkOptionViewModel> get linkedNetworkOptions =>
      PosLinkedNetworkOptionMapper.map(
        links: networkLinks,
        selectedNetworkPosId: selectedNetworkLink.value?.networkPosId,
      );

  List<WorkspaceTransactionItemViewModel> get recentTransactionItems =>
      PosWorkspaceTransactionMapper.map(
        invoices: recentInvoices,
        requests: recentRequests,
        onOpenInvoice: (invoice) => Get.toNamed<void>(
          AppRoutes.purchaseInvoiceDetails,
          arguments: invoice,
        ),
        onOpenRequest: (request) => Get.toNamed<void>(
          AppRoutes.procurementOrders,
          arguments: request,
        ),
      );

  @override
  void onInit() {
    super.onInit();
    unawaited(_initializeWorkspace());
  }

  Future<void> _initializeWorkspace() async {
    try {
      if (WorkspaceService.to.activeWorkspace != AppWorkspace.pos) {
        await WorkspaceService.to.setActiveWorkspace(AppWorkspace.pos);
      }
    } catch (error) {
      // Workspace selection is a navigation preference. A storage failure
      // must not prevent loading the server-authorized POS context.
      log(
        '⚠️ [PosWorkspaceController] Could not persist active workspace preference: $error',
      );
    }
    await loadWorkspace();
  }

  Future<void> loadWorkspace() async {
    await loadPosTenants();
    final posId = activePos.value?.posId;
    if (posId != null) await loadNetworks(posId);
  }

  Future<void> loadPosTenants() async {
    if (isLoadingPos.value) return;
    final generation = ++_posGeneration;
    isLoadingPos.value = true;
    posError.value = null;
    availablePos.clear();
    activePos.value = null;
    _clearNetworkContext();

    try {
      final positions = await getMyPosUseCase();
      if (generation != _posGeneration || isClosed) return;

      availablePos.assignAll(positions);
      final ids = positions.map((position) => position.posId).toList(growable: false);
      final selectedId = WorkspaceService.to.resolveWorkspaceActivePosId(ids);
      final selected = selectedId == null
          ? null
          : positions.firstWhereOrNull((position) => position.posId == selectedId);

      activePos.value = selected;

      if (selected == null) {
        await WorkspaceService.to.clearActivePosId();
        return;
      }
      await WorkspaceService.to.saveActivePosId(selected.posId);
    } catch (error) {
      if (generation != _posGeneration || isClosed) return;
      availablePos.clear();
      activePos.value = null;
      _clearNetworkContext();
      posError.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل نقاط البيع المصرح بها.',
      );
    } finally {
      if (generation == _posGeneration && !isClosed) {
        isLoadingPos.value = false;
      }
    }
  }

  Future<void> selectPos(PosEntity pos) async {
    if (!availablePos.any((item) => item.posId == pos.posId)) return;
    if (activePos.value?.posId == pos.posId) return;

    activePos.value = pos;
    _clearNetworkContext();
    await WorkspaceService.to.saveActivePosId(pos.posId);
    await loadNetworks(pos.posId);
  }

  Future<void> selectPosById(int? posId) async {
    if (posId == null) return;
    final selected = availablePos.firstWhereOrNull(
      (position) => position.posId == posId,
    );
    if (selected != null) await selectPos(selected);
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
      selectedNetworkLink.value = null;
      networkCursor.value = null;
      hasMoreNetworks.value = false;
      _clearScopedData();
    } else {
      isLoadingMoreNetworks.value = true;
    }

    try {
      final result = await getPosNetworksListUseCase(
        posId: posId,
        cursor: refresh ? null : networkCursor.value,
        perPage: 10,
      );
      if (generation != _networkGeneration ||
          activePos.value?.posId != posId ||
          isClosed) {
        return;
      }

      // A POS may have distinct relationship records for the same network.
      // The relationship ID, not the network ID, identifies a selectable link.
      final knownLinkIds = networkLinks.map((link) => link.networkPosId).toSet();
      for (final link in result.items) {
        if (knownLinkIds.add(link.networkPosId)) networkLinks.add(link);
      }
      networkCursor.value = result.nextCursor;
      hasMoreNetworks.value = result.hasMore;

      final savedId = StorageService.instance.getInt(_networkStorageKey(posId));
      final saved = networkLinks.firstWhereOrNull(
        (link) => link.networkPosId == savedId && link.status,
      );
      NetworkPosLinkEntity? initial = saved;
      if (initial == null && !result.hasMore) {
        final activeLinks = networkLinks.where((link) => link.status).toList();
        if (activeLinks.length == 1) initial = activeLinks.single;
      }

      if (selectedNetworkLink.value == null && initial != null) {
        await selectNetwork(
          initial,
        );
      }
    } catch (error) {
      if (generation != _networkGeneration || isClosed) return;
      networksError.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل الشبكات المرتبطة بنقطة البيع.',
      );
    } finally {
      if (generation == _networkGeneration && !isClosed) {
        isLoadingNetworks.value = false;
        isLoadingMoreNetworks.value = false;
      }
    }
  }

  Future<void> selectNetwork(
    NetworkPosLinkEntity link, {
    bool forceRefresh = false,
  }) async {
    final posId = activePos.value?.posId;
    final authorizedLink = networkLinks.firstWhereOrNull(
      (candidate) =>
          candidate.networkId == link.networkId &&
          candidate.networkPosId == link.networkPosId &&
          candidate.status,
    );
    if (posId == null || authorizedLink == null) return;

    if (selectedNetworkLink.value?.networkPosId == link.networkPosId &&
        !forceRefresh &&
        isLoadingRecentData.value) {
      return;
    }

    selectedNetworkLink.value = authorizedLink;

    // Start the scoped load immediately so old-network rows are cleared before
    // any persistence await can yield back to the frame scheduler.
    final scopedLoad = loadNetworkScopedData(
      authorizedLink.networkId,
      posId: posId,
      networkPosId: authorizedLink.networkPosId,
    );

    try {
      await StorageService.instance.setInt(
        _networkStorageKey(posId),
        authorizedLink.networkPosId,
      );
    } catch (error) {
      log(
        '⚠️ [PosWorkspaceController] Could not persist linked-network preference: $error',
      );
    }

    await scopedLoad;
  }

  Future<void> selectNetworkLink(int networkPosId) async {
    final link = networkLinks.firstWhereOrNull(
      (candidate) => candidate.networkPosId == networkPosId && candidate.status,
    );
    if (link != null) await selectNetwork(link);
  }

  Future<void> loadNetworkScopedData(
    int networkId, {
    required int posId,
    required int networkPosId,
  }) async {
    final generation = ++_scopedDataGeneration;
    recentInvoices.clear();
    recentRequests.clear();
    recentInvoicesError.value = null;
    recentRequestsError.value = null;
    isLoadingRecentData.value = true;

    Future<void> loadInvoices() async {
      try {
        final result = await getPosInvoicesUseCase(
          posId: posId,
          networkId: networkId,
          perPage: 5,
        );
        if (generation == _scopedDataGeneration &&
            activePos.value?.posId == posId &&
            selectedNetworkLink.value?.networkPosId == networkPosId &&
            !isClosed) {
          recentInvoices.assignAll(result.items);
        }
      } catch (error) {
        if (generation == _scopedDataGeneration && !isClosed) {
          recentInvoicesError.value = AppException.sanitizeMessage(
            error,
            fallback: 'تعذر تحميل فواتير الشبكة المحددة.',
          );
        }
      }
    }

    Future<void> loadRequests() async {
      try {
        final result = await getRequestsUseCase(
          posId: posId,
          networkId: networkId,
          perPage: 5,
        );
        if (generation == _scopedDataGeneration &&
            activePos.value?.posId == posId &&
            selectedNetworkLink.value?.networkPosId == networkPosId &&
            !isClosed) {
          recentRequests.assignAll(result.items);
        }
      } catch (error) {
        if (generation == _scopedDataGeneration && !isClosed) {
          recentRequestsError.value = AppException.sanitizeMessage(
            error,
            fallback: 'تعذر تحميل طلبات الشبكة المحددة.',
          );
        }
      }
    }

    try {
      await Future.wait<void>([loadInvoices(), loadRequests()]);
    } finally {
      if (generation == _scopedDataGeneration && !isClosed) {
        isLoadingRecentData.value = false;
      }
    }
  }

  Future<void> retryNetworks() async {
    final posId = activePos.value?.posId;
    if (posId != null) await loadNetworks(posId);
  }

  Future<void> loadMoreNetworks() async {
    final posId = activePos.value?.posId;
    if (posId != null) await loadNetworks(posId, refresh: false);
  }

  Future<void> retryScopedData() async {
    final posId = activePos.value?.posId;
    final selectedLink = selectedNetworkLink.value;
    if (posId != null && selectedLink != null) {
      await loadNetworkScopedData(
        selectedLink.networkId,
        posId: posId,
        networkPosId: selectedLink.networkPosId,
      );
    }
  }

  String _networkStorageKey(int posId) =>
      '${StorageKeys.activePosNetworkPrefix}_${SessionService.to.currentUser?.userId ?? 0}_$posId';

  void _clearScopedData() {
    ++_scopedDataGeneration;
    recentInvoices.clear();
    recentRequests.clear();
    recentInvoicesError.value = null;
    recentRequestsError.value = null;
    isLoadingRecentData.value = false;
  }

  void _clearNetworkContext() {
    ++_networkGeneration;
    networkLinks.clear();
    selectedNetworkLink.value = null;
    networkCursor.value = null;
    hasMoreNetworks.value = false;
    isLoadingNetworks.value = false;
    isLoadingMoreNetworks.value = false;
    networksError.value = null;
    _clearScopedData();
  }

  Future<NetworkPosLinkPreviewEntity> previewNetworkLinkChallenge({
    required String payload,
    required int posId,
  }) =>
      previewNetworkPosLinkChallengeUseCase(payload: payload, posId: posId);

  Future<bool> confirmNetworkLinkChallenge({
    required String challengeUuid,
    required int posId,
  }) async {
    final newLink = await confirmNetworkPosLinkChallengeUseCase(
      challengeUuid: challengeUuid,
      posId: posId,
    );

    final existingIndex = networkLinks.indexWhere(
      (link) => link.networkPosId == newLink.networkPosId,
    );
    if (existingIndex < 0) {
      networkLinks.insert(0, newLink);
    } else {
      networkLinks[existingIndex] = newLink;
    }
    await selectNetwork(
      newLink,
      forceRefresh: true,
    );
    return true;
  }

  void openNewProcurementOrder() =>
      Get.toNamed<void>(AppRoutes.newProcurementOrder);

  void openPurchaseInvoices() => Get.toNamed<void>(AppRoutes.purchaseInvoices);

  void openProcurementOrder(RequestEntity request) =>
      Get.toNamed<void>(AppRoutes.procurementOrders, arguments: request);

  void onNavItemSelected(int index) => selectedNavIndex.value = index;
}
