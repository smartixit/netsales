import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns only the Network POS directory collection and commercial partner actions.
class NetworkPosDirectoryController extends GetxController {
  NetworkPosDirectoryController({
    required this.getNetworkPosListUseCase,
    required this.toggleNetworkPosLinkStatusUseCase,
    required this.deleteNetworkPosLinkUseCase,
    required this.createNetworkPosLinkChallengeUseCase,
    required this.revokeNetworkPosLinkChallengeUseCase,
    this.getMyNetworksUseCase,
  });

  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final ToggleNetworkPosLinkStatusUseCase toggleNetworkPosLinkStatusUseCase;
  final DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;
  final CreateNetworkPosLinkChallengeUseCase createNetworkPosLinkChallengeUseCase;
  final RevokeNetworkPosLinkChallengeUseCase revokeNetworkPosLinkChallengeUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  final links = <NetworkPosLinkEntity>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnBool();
  final RxnInt expandedLinkId = RxnInt();

  final authorizedNetworks = <NetworkEntity>[].obs;
  final selectedNetworkId = RxnInt();

  int _linksListRevision = 0;

  bool get hasMore => nextCursor.value != null;

  int get totalCount => links.length;

  int get activeCount => links.where((link) => link.isActive).length;

  int get inactiveCount => links.where((link) => !link.isActive).length;

  bool get canManageCommercial =>
      PermissionService.to.can(AppPermissions.networkPosManage);

  Future<void> refreshLinks() => loadLinks(isRefresh: true, clearOnStart: true);

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
    _linksListRevision++;
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadMyNetworks();
    await loadLinks(isRefresh: true, clearOnStart: true);
  }

  Future<void> loadMyNetworks() async {
    if (getMyNetworksUseCase == null) return;
    try {
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);
      selectedNetworkId.value = WorkspaceService.to.resolveActiveNetworkId(
        networks.map((network) => network.networkId).toList(growable: false),
      );
    } catch (_) {
      authorizedNetworks.clear();
      selectedNetworkId.value = null;
    }
  }

  Future<void> loadLinks({
    bool isRefresh = false,
    bool clearOnStart = false,
  }) async {
    final revision = ++_linksListRevision;
    if (clearOnStart) {
      links.clear();
    }
    isLoading.value = true;
    errorMessage.value = null;
    loadMoreError.value = null;
    nextCursor.value = null;
    isLoadingMore.value = false;

    final networkId = selectedNetworkId.value;
    if (networkId == null || networkId <= 0) {
      isLoading.value = false;
      return;
    }

    final status = statusFilter.value;
    final query = searchQuery.value.trim();

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getNetworkPosListUseCase(
        networkId: networkId,
        status: status,
        search: query.isEmpty ? null : query,
        cursor: null,
      );
      if (revision != _linksListRevision) return;
      links.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (error) {
      if (revision != _linksListRevision) return;
      errorMessage.value = error is AppException
          ? error.message
          : 'تعذر استرجاع نقاط البيع المرتبطة بالشبكة: $error';
    } finally {
      if (revision == _linksListRevision) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreLinks() async {
    final cursor = nextCursor.value;
    final networkId = selectedNetworkId.value;
    if (isLoadingMore.value || isLoading.value || cursor == null || networkId == null) {
      return;
    }

    final revision = _linksListRevision;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    isLoadingMore.value = true;

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getNetworkPosListUseCase(
        networkId: networkId,
        status: status,
        search: query.isEmpty ? null : query,
        cursor: cursor,
      );
      if (revision != _linksListRevision) return;

      final existingIds = links.map((link) => link.networkPosId).toSet();
      links.addAll(
        result.items
            .where((link) => !existingIds.contains(link.networkPosId))
            .toList(growable: false),
      );
      nextCursor.value = result.nextCursor;
      loadMoreError.value = null;
    } catch (error) {
      if (revision == _linksListRevision) {
        loadMoreError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر استرجاع المزيد من نقاط البيع.',
        );
      }
    } finally {
      if (revision == _linksListRevision) {
        isLoadingMore.value = false;
      }
    }
  }

  void setStatusFilter(bool? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  void onNetworkFilterChanged(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    if (networkId != null) {
      WorkspaceService.to.saveActiveNetworkId(networkId);
    }
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadLinks(isRefresh: true, clearOnStart: true);
  }

  void toggleAccordion(int networkPosId) {
    expandedLinkId.value =
        expandedLinkId.value == networkPosId ? null : networkPosId;
  }

  Future<void> toggleLinkStatus(NetworkPosLinkEntity link) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: link.isActive
            ? 'جاري تجميد الارتباط التجاري...'
            : 'جاري تفعيل الارتباط التجاري...',
      );
      final updated =
          await toggleNetworkPosLinkStatusUseCase(link.networkPosId);
      final index =
          links.indexWhere((l) => l.networkPosId == link.networkPosId);
      if (index != -1) {
        links[index] = updated;
      }
      await CustomAnimationOverlay.showSuccess(
        message: updated.isActive
            ? 'تم تفعيل الارتباط التجاري بنجاح'
            : 'تم تجميد الارتباط التجاري بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر تعديل الحالة',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تعديل حالة الارتباط: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> deleteLink(NetworkPosLinkEntity link) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري فك الارتباط التجاري...',
      );
      await deleteNetworkPosLinkUseCase(link.networkPosId);
      links.removeWhere((l) => l.networkPosId == link.networkPosId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم فك الارتباط التجاري بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر فك الارتباط',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية فك الارتباط: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> promptToggleStatus(NetworkPosLinkEntity link) async {
    final posName = link.pos?.posName ?? 'نقطة البيع #${link.posId}';
    await CommercialActionDialogs.showToggleStatusDialog(
      partnerName: posName,
      willDeactivate: link.isActive,
      onConfirm: () => toggleLinkStatus(link),
    );
  }

  Future<void> promptDeleteLink(NetworkPosLinkEntity link) async {
    final posName = link.pos?.posName ?? 'نقطة البيع #${link.posId}';
    await CommercialActionDialogs.showUnlinkDialog(
      partnerName: posName,
      onConfirm: () => deleteLink(link),
    );
  }

  Future<NetworkPosLinkChallengeEntity?> createQrInvitation({
    int? posId,
    String? posUuid,
    int durationMinutes = 30,
  }) async {
    final netId = selectedNetworkId.value;
    if (netId == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى تحديد شبكة العمل أولاً.',
        type: SnackType.warning,
      );
      return null;
    }

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري توليد رمز الدعوة المشفر (QR)...',
      );
      final challenge = await createNetworkPosLinkChallengeUseCase(
        networkId: netId,
        posId: posId,
        posUuid: posUuid,
        durationMinutes: durationMinutes,
      );
      await CustomAnimationOverlay.showSuccess(
        message: 'تم توليد رمز الدعوة بنجاح',
      );
      return challenge;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الدعوة',
        message: error.message,
        type: SnackType.error,
      );
      return null;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر توليد رمز الدعوة: $error',
        type: SnackType.error,
      );
      return null;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> revokeChallenge(String challengeUuid) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إلغاء رمز الدعوة...',
      );
      await revokeNetworkPosLinkChallengeUseCase(challengeUuid);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء رمز الدعوة بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إلغاء الدعوة',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إلغاء رمز الدعوة: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}

