import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_link_confirm_sheet.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شبكات التزويد المرتبطة بنقطة البيع (POS Commercial Directory)
class PosCommercialDirectoryController
    extends BaseCommercialDirectoryController {
  PosCommercialDirectoryController({
    required this.getPosNetworksListUseCase,
    required this.previewNetworkPosLinkChallengeUseCase,
    required this.confirmNetworkPosLinkChallengeUseCase,
    this.getMyPosUseCase,
    this.initialPosId,
  });

  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final PreviewNetworkPosLinkChallengeUseCase
  previewNetworkPosLinkChallengeUseCase;
  final ConfirmNetworkPosLinkChallengeUseCase
  confirmNetworkPosLinkChallengeUseCase;
  final GetMyPosUseCase? getMyPosUseCase;
  final int? initialPosId;

  @override
  final RxList<NetworkPosLinkEntity> links = <NetworkPosLinkEntity>[].obs;

  @override
  final RxBool isLoading = true.obs;

  @override
  final RxnString errorMessage = RxnString();

  @override
  final RxBool isLoadingMore = false.obs;

  @override
  final RxnString loadMoreError = RxnString();

  @override
  final RxnString statusFilter = RxnString();

  @override
  final RxString searchQuery = ''.obs;

  @override
  final TextEditingController searchController = TextEditingController();

  @override
  final RxnInt expandedLinkId = RxnInt();

  final authorizedPosList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();

  String? _nextCursor;
  int _listRevision = 0;
  int _loadMoreRevision = 0;

  @override
  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  @override
  bool get isNetworkView => false;

  @override
  int get totalPartnersCount => links.length;

  @override
  int get activePartnersCount => links.where((link) => link.isActive).length;

  @override
  int get inactivePartnersCount => links.where((link) => !link.isActive).length;

  bool get canPreviewLinkChallenge =>
      PermissionService.to.can(AppPermissions.posPreviewLinkChallenge);
  bool get canConfirmLinkChallenge =>
      PermissionService.to.can(AppPermissions.posConfirmLinkChallenge);
  bool get canLinkNetwork =>
      canPreviewLinkChallenge && canConfirmLinkChallenge;
  @override
  bool get canViewPartnerWallet =>
      PermissionService.to.can(AppPermissions.posWalletsView);
  @override
  bool get canViewRelationshipLifecycle =>
      PermissionService.to.can(AppPermissions.posViewNetworkAgreements) ||
      PermissionService.to.can(AppPermissions.posViewNetworkLinkEvents) ||
      PermissionService.to.can(AppPermissions.posView) ||
      PermissionService.to.can(AppPermissions.voucherPackageDiscountsView) ||
      PermissionService.to.can(AppPermissions.voucherPackagesView);

  int? get resolvedPosId {
    return selectedPosId.value ??
        (authorizedPosList.isNotEmpty ? authorizedPosList.first.posId : null);
  }

  @override
  String get pageTitle => 'مزودو الشبكات المرتبطة';

  @override
  String get pageSubtitle =>
      'إدارة واستعراض شبكات التزويد المرتبطة بنقطة البيع، وربط مزودين جدد.';

  @override
  IconData get pageIcon => Icons.hub_rounded;

  @override
  String get searchHint => 'البحث باسم الشبكة المزودة أو المعرف أو الهاتف...';

  @override
  bool get hasHeaderAction => canLinkNetwork;

  @override
  void onHeaderAction() => openQrScannerFlow();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    debounce(
      searchQuery,
      (_) => loadLinks(isRefresh: true, clearOnStart: true),
      time: const Duration(milliseconds: 350),
    );
    loadInitialData();
  }

  @override
  void onClose() {
    _listRevision++;
    _loadMoreRevision++;
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadMyPos();
    await loadLinks(isRefresh: true, clearOnStart: true);
  }

  Future<void> loadMyPos() async {
    if (getMyPosUseCase == null) return;
    try {
      final posList = await getMyPosUseCase!();
      authorizedPosList.assignAll(posList);
      final authorizedIds = posList.map((pos) => pos.posId).toSet();
      selectedPosId.value = initialPosId != null
          ? (authorizedIds.contains(initialPosId) ? initialPosId : null)
          : WorkspaceService.to.resolveActivePosId(
              posList.map((pos) => pos.posId).toList(growable: false),
            );
    } catch (_) {
      authorizedPosList.clear();
      selectedPosId.value = null;
    }
  }

  void onPosFilterChanged(int? posId) {
    if (posId == null || selectedPosId.value == posId) return;
    selectedPosId.value = posId;
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  @override
  Future<void> refreshDirectory() =>
      loadLinks(isRefresh: true, clearOnStart: true);

  Future<void> loadLinks({
    bool isRefresh = false,
    bool clearOnStart = false,
  }) async {
    final currentRevision = ++_listRevision;
    _loadMoreRevision++;
    final posId = resolvedPosId;

    if (posId == null) {
      isLoading.value = false;
      errorMessage.value = 'يرجى تحديد نقطة البيع أولاً لعرض الشبكات المرتبطة.';
      links.clear();
      return;
    }

    if (clearOnStart) {
      links.clear();
      _nextCursor = null;
    }

    isLoading.value = true;
    errorMessage.value = null;
    loadMoreError.value = null;
    isLoadingMore.value = false;

    final bool? statusParam;
    if (statusFilter.value == '1' || statusFilter.value == 'true') {
      statusParam = true;
    } else if (statusFilter.value == '0' || statusFilter.value == 'false') {
      statusParam = false;
    } else {
      statusParam = null;
    }

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getPosNetworksListUseCase(
            posId: posId,
            status: statusParam,
            search: searchQuery.value.trim().isEmpty
                ? null
                : searchQuery.value.trim(),
            perPage: 15,
          );

      if (currentRevision != _listRevision) return;

      links.assignAll(result.items);
      _nextCursor = result.nextCursor;
      isLoading.value = false;
    } catch (e) {
      if (currentRevision != _listRevision) return;
      isLoading.value = false;
      errorMessage.value = AppException.sanitizeMessage(e.toString());
    }
  }

  @override
  Future<void> loadMoreLinks() async {
    final posId = resolvedPosId;
    if (posId == null || !hasMore || isLoadingMore.value) return;

    // Bind this page request to the exact directory query that produced its cursor.
    // A response from an older workspace/search/filter must never contaminate the
    // currently visible result set.
    final requestRevision = _listRevision;
    final requestToken = ++_loadMoreRevision;
    final requestSearch = searchQuery.value.trim();
    final requestStatus = statusFilter.value;
    final requestCursor = _nextCursor;

    isLoadingMore.value = true;
    loadMoreError.value = null;

    final bool? statusParam;
    if (requestStatus == '1' || requestStatus == 'true') {
      statusParam = true;
    } else if (requestStatus == '0' || requestStatus == 'false') {
      statusParam = false;
    } else {
      statusParam = null;
    }

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getPosNetworksListUseCase(
            posId: posId,
            status: statusParam,
            search: requestSearch.isEmpty ? null : requestSearch,
            cursor: requestCursor,
            perPage: 15,
          );

      if (requestRevision != _listRevision ||
          resolvedPosId != posId ||
          searchQuery.value.trim() != requestSearch ||
          statusFilter.value != requestStatus ||
          _nextCursor != requestCursor) {
        return;
      }

      links.addAll(result.items);
      _nextCursor = result.nextCursor;
    } catch (e) {
      if (requestRevision != _listRevision ||
          resolvedPosId != posId ||
          searchQuery.value.trim() != requestSearch ||
          statusFilter.value != requestStatus) {
        return;
      }
      loadMoreError.value = AppException.sanitizeMessage(e.toString());
    } finally {
      if (requestToken == _loadMoreRevision) {
        isLoadingMore.value = false;
      }
    }
  }

  @override
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) {
      statusFilter.value = null;
    } else {
      statusFilter.value = status;
    }
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  @override
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  @override
  void toggleAccordion(int linkId) {
    if (expandedLinkId.value == linkId) {
      expandedLinkId.value = null;
    } else {
      expandedLinkId.value = linkId;
    }
  }

  @override
  RxnInt get selectedScopeId => selectedPosId;

  @override
  String get scopeFilterLabel => 'تصفية بحسب نقطة البيع';

  @override
  List<CustomSearchFilterOption<int?>> get scopeFilterOptions =>
      initialPosId != null || authorizedPosList.length <= 1
          ? const []
          : authorizedPosList.map((pos) => CustomSearchFilterOption<int?>(
                label: pos.posName,
                value: pos.posId,
                icon: Icons.storefront_rounded,
              )).toList(growable: false);

  @override
  void onScopeFilterChanged(int? id) => onPosFilterChanged(id);

  @override
  bool get canTogglePartnerLink => false;

  @override
  bool get canDeletePartnerLink => false;

  @override
  Future<void> togglePartnerLink(NetworkPosLinkEntity link) async {
    throw const AppException('تغيير حالة الارتباط غير متاح من مساحة نقطة البيع.');
  }

  @override
  Future<void> deletePartnerLink(NetworkPosLinkEntity link) async {
    throw const AppException('فك الارتباط غير متاح من مساحة نقطة البيع.');
  }

  @override
  void openPosWalletStatement(NetworkPosLinkEntity link) {
    Get.toNamed<void>(
      AppRoutes.posWalletStatement,
      arguments: {'network_id': link.networkId, 'pos_id': link.posId},
    );
  }

  @override
  void openRelationshipLifecycle(NetworkPosLinkEntity link) {
    if (!canViewRelationshipLifecycle) return;
    Get.toNamed<void>(
      AppRoutes.networkPosLifecycle.replaceFirst(':id', link.networkPosId.toString()),
      arguments: {
        'entity_id': link.posId,
        'is_network': false,
        'relationship': link,
        'network_id': link.networkId,
        'pos_id': link.posId,
      },
    );
  }

  Future<void> openQrScannerFlow() async {
    if (!canLinkNetwork) return;
    final posId = resolvedPosId;
    final pos = authorizedPosList.firstWhereOrNull(
      (item) => item.posId == posId,
    );
    final posUuid = pos?.posUuid.trim();

    if (posId == null || posUuid == null || posUuid.isEmpty) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى اختيار نقطة بيع صالحة قبل مسح رمز الارتباط',
        type: SnackType.warning,
      );
      return;
    }

    await HapticFeedback.mediumImpact();
    await Get.to<void>(
      () => CustomQrScanner(
        title: 'مسح رمز ربط مزود شبكة',
        instruction: 'وجّه الكاميرا نحو رمز QR لدعوة شبكة المزود المعتمد',
        onClose: () => Get.back<void>(),
        onScan: (result) async {
          Get.back<void>();
          await handleScannedQrPayload(result.rawValue, posId, posUuid);
        },
      ),
      fullscreenDialog: true,
    );
  }

  Future<void> handleScannedQrPayload(
    String payload,
    int posId,
    String posUuid,
  ) async {
    if (!canLinkNetwork) return;
    try {
      if (resolvedPosId != posId ||
          authorizedPosList
                  .firstWhereOrNull((item) => item.posId == posId)
                  ?.posUuid !=
              posUuid) {
        throw const AppException(
          'تغيرت نقطة البيع النشطة. أعد بدء عملية ربط الشبكة.',
        );
      }

      await HapticFeedback.lightImpact();
      final preview = await previewNetworkPosLinkChallengeUseCase(
        payload: payload,
        posUuid: posUuid,
      );
      final confirmed = await NetworkPosLinkConfirmSheet.show(
        preview: preview,
        onConfirm: () async {
          try {
            await confirmNetworkPosLinkChallengeUseCase(
              challengeUuid: preview.challengeUuid,
              posUuid: posUuid,
            );
            await CustomAnimationOverlay.showSuccess(
              message:
                  'تم ربط نقطة البيع بنجاح مع ${preview.displayNetworkName}',
            );
            return true;
          } catch (error) {
            CustomSnackbar.show(
              title: 'تعذر تأكيد الارتباط',
              message: AppException.sanitizeMessage(error.toString()),
              type: SnackType.error,
            );
            return false;
          }
        },
      );

      if (confirmed == true) {
        await loadLinks(isRefresh: true, clearOnStart: true);
      }
    } catch (error) {
      CustomSnackbar.show(
        title: 'رمز غير صالح أو منتهي',
        message: AppException.sanitizeMessage(error.toString()),
        type: SnackType.error,
      );
    }
  }
}
