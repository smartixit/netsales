import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns only the POS linked networks collection and merchant link establishment actions.
class PosLinkedNetworksController extends GetxController {
  PosLinkedNetworksController({
    required this.getPosNetworksListUseCase,
    required this.deleteNetworkPosLinkUseCase,
    required this.previewNetworkPosLinkChallengeUseCase,
    required this.confirmNetworkPosLinkChallengeUseCase,
    this.getMyPosUseCase,
  });

  final GetPosNetworksListUseCase getPosNetworksListUseCase;
  final DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;
  final PreviewNetworkPosLinkChallengeUseCase
      previewNetworkPosLinkChallengeUseCase;
  final ConfirmNetworkPosLinkChallengeUseCase
      confirmNetworkPosLinkChallengeUseCase;
  final GetMyPosUseCase? getMyPosUseCase;

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

  final authorizedPosList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();

  int _linksListRevision = 0;

  bool get hasMore => nextCursor.value != null;

  int get totalCount => links.length;

  int get activeCount => links.where((link) => link.isActive).length;

  int get inactiveCount => links.where((link) => !link.isActive).length;

  bool get canManageCommercial =>
      PermissionService.to.can(AppPermissions.posEdit);

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
    await loadMyPos();
    await loadLinks(isRefresh: true, clearOnStart: true);
  }

  Future<void> loadMyPos() async {
    if (getMyPosUseCase == null) return;
    try {
      final posList = await getMyPosUseCase!();
      authorizedPosList.assignAll(posList);
      selectedPosId.value = WorkspaceService.to.resolveActivePosId(
        posList.map((pos) => pos.posId).toList(growable: false),
      );
    } catch (_) {
      authorizedPosList.clear();
      selectedPosId.value = null;
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

    final posId = selectedPosId.value;
    if (posId == null || posId <= 0) {
      isLoading.value = false;
      return;
    }

    final status = statusFilter.value;
    final query = searchQuery.value.trim();

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getPosNetworksListUseCase(
        posId: posId,
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
          : 'تعذر استرجاع شبكات التزويد المرتبطة: $error';
    } finally {
      if (revision == _linksListRevision) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreLinks() async {
    final cursor = nextCursor.value;
    final posId = selectedPosId.value;
    if (isLoadingMore.value || isLoading.value || cursor == null || posId == null) {
      return;
    }

    final revision = _linksListRevision;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    isLoadingMore.value = true;

    try {
      final PaginatedList<NetworkPosLinkEntity> result =
          await getPosNetworksListUseCase(
        posId: posId,
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
          fallback: 'تعذر استرجاع المزيد من شبكات التزويد.',
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

  void onPosFilterChanged(int? posId) {
    if (selectedPosId.value == posId) return;
    selectedPosId.value = posId;
    if (posId != null) {
      WorkspaceService.to.saveActivePosId(posId);
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

  Future<void> deleteLink(NetworkPosLinkEntity link) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري فك الارتباط بالشبكة...',
      );
      await deleteNetworkPosLinkUseCase(link.networkPosId);
      links.removeWhere((l) => l.networkPosId == link.networkPosId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم فك الارتباط بالشبكة بنجاح',
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

  Future<void> promptDeleteLink(NetworkPosLinkEntity link) async {
    final networkName = link.network?.networkName ?? 'الشبكة #${link.networkId}';
    await CommercialActionDialogs.showUnlinkDialog(
      partnerName: networkName,
      onConfirm: () => deleteLink(link),
    );
  }

  Future<NetworkPosLinkPreviewEntity?> previewChallenge(String payload) async {
    final posId = selectedPosId.value;
    if (posId == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى تحديد نقطة البيع أولاً.',
        type: SnackType.warning,
      );
      return null;
    }

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري فحص رمز الدعوة...',
      );
      final preview = await previewNetworkPosLinkChallengeUseCase(
        payload: payload,
        posId: posId,
      );
      return preview;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'رمز غير صالح',
        message: error.message,
        type: SnackType.error,
      );
      return null;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر فحص رمز الدعوة: $error',
        type: SnackType.error,
      );
      return null;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<bool> confirmChallenge(String challengeUuid) async {
    final posId = selectedPosId.value;
    if (posId == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى تحديد نقطة البيع أولاً.',
        type: SnackType.warning,
      );
      return false;
    }

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تأكيد الارتباط بالشبكة...',
      );
      await confirmNetworkPosLinkChallengeUseCase(
        challengeUuid: challengeUuid,
        posId: posId,
      );
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تأسيس الارتباط التجاري بنجاح!',
      );
      await loadLinks(isRefresh: true, clearOnStart: true);
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر تأكيد الارتباط',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تأكيد الارتباط: $error',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
