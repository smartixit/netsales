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
import 'package:netsales/features/workspace/presentation/mappers/pos_workspace_transaction_mapper.dart';
import 'package:netsales/features/workspace/presentation/models/pos_active_supply_order_view_model.dart';
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
  final RxInt currentNetworkIndex = 0.obs;

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
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (item) => item.scope == RoleScope.pos,
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
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.pos) {
      WorkspaceService.to.setActiveWorkspace(AppWorkspace.pos);
    }
    loadWorkspace();
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

    try {
      final positions = await getMyPosUseCase();
      if (generation != _posGeneration || isClosed) return;

      availablePos.assignAll(positions);
      final ids = positions.map((position) => position.posId).toList(growable: false);
      final selectedId = WorkspaceService.to.resolveWorkspaceActivePosId(ids);
      final selected = selectedId == null
          ? null
          : positions.firstWhereOrNull((position) => position.posId == selectedId);

      if (activePos.value?.posId != selected?.posId) {
        _clearNetworkContext();
      }
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
      currentNetworkIndex.value = 0;
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

      final knownIds = networkLinks.map((link) => link.networkId).toSet();
      for (final link in result.items) {
        if (knownIds.add(link.networkId)) networkLinks.add(link);
      }
      networkCursor.value = result.nextCursor;
      hasMoreNetworks.value = result.hasMore;

      if (refresh) {
        final savedId = StorageService.instance.getInt(_networkStorageKey(posId));
        final saved = networkLinks.firstWhereOrNull(
          (link) => link.networkId == savedId && link.status,
        );
        NetworkPosLinkEntity? initial;
        if (saved != null) {
          initial = saved;
        } else if (!result.hasMore) {
          final activeLinks = networkLinks.where((link) => link.status).toList();
          if (activeLinks.length == 1) initial = activeLinks.single;
        }

        if (initial != null) {
          await selectNetwork(
            initial,
            index: networkLinks.indexOf(initial),
          );
        }
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
    int? index,
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

    if (selectedNetworkLink.value?.networkId == link.networkId &&
        !forceRefresh &&
        isLoadingRecentData.value) {
      return;
    }

    selectedNetworkLink.value = authorizedLink;
    currentNetworkIndex.value = index ?? networkLinks.indexOf(authorizedLink);
    await StorageService.instance.setInt(
      _networkStorageKey(posId),
      authorizedLink.networkId,
    );
    await loadNetworkScopedData(authorizedLink.networkId, posId: posId);
  }

  Future<void> loadNetworkScopedData(
    int networkId, {
    required int posId,
  }) async {
    final generation = ++_scopedDataGeneration;
    recentInvoices.clear();
    recentRequests.clear();
    recentInvoicesError.value = null;
    recentRequestsError.value = null;
    isLoadingRecentData.value = true;

    try {
      final results = await Future.wait([
        getPosInvoicesUseCase(posId: posId, networkId: networkId, perPage: 5),
        getRequestsUseCase(posId: posId, networkId: networkId, perPage: 5),
      ]);

      if (generation != _scopedDataGeneration ||
          activePos.value?.posId != posId ||
          selectedNetworkLink.value?.networkId != networkId ||
          isClosed) {
        return;
      }

      recentInvoices.assignAll(results[0].items);
      recentRequests.assignAll(results[1].items);
    } catch (error) {
      if (generation != _scopedDataGeneration || isClosed) return;
      final message = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل نشاط الشبكة المحددة.',
      );
      recentInvoicesError.value = message;
      recentRequestsError.value = message;
    } finally {
      if (generation == _scopedDataGeneration && !isClosed) {
        isLoadingRecentData.value = false;
      }
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

  Future<void> retryScopedData() async {
    final posId = activePos.value?.posId;
    final networkId = selectedNetworkLink.value?.networkId;
    if (posId != null && networkId != null) {
      await loadNetworkScopedData(networkId, posId: posId);
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
    currentNetworkIndex.value = 0;
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
      (link) => link.networkId == newLink.networkId,
    );
    if (existingIndex < 0) {
      networkLinks.insert(0, newLink);
    } else {
      networkLinks[existingIndex] = newLink;
    }
    await selectNetwork(
      newLink,
      index: existingIndex < 0 ? 0 : existingIndex,
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
