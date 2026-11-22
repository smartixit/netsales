import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_actions.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_link_confirm_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/qr/custom_qr_scanner.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شبكات التزويد المرتبطة بنقطة البيع (POS Commercial Directory)
class PosCommercialDirectoryController
    extends BaseCommercialDirectoryController {
  PosCommercialDirectoryController({
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

  @override
  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  @override
  bool get isNetworkView => false;

  int get totalPartnersCount => links.length;

  int get activePartnersCount => links.where((link) => link.isActive).length;

  int get inactivePartnersCount => links.where((link) => !link.isActive).length;

  bool get canManageCommercial =>
      PermissionService.to.can(AppPermissions.posEdit);

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
  Widget? get headerAction {
    if (!canManageCommercial) return null;
    return CustomButton.icon(
      tooltip: 'ربط مزود شبكة',
      icon: Icons.qr_code_scanner_rounded,
      backgroundColor: Theme.of(Get.context!).colorScheme.surfaceContainer,
      foregroundColor: Theme.of(Get.context!).colorScheme.primary,
      shape: AppButtonShape.rounded,
      size: AppButtonSize.small,
      onPressed: openQrScannerFlow,
    );
  }

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

    isLoadingMore.value = true;
    loadMoreError.value = null;

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
            cursor: _nextCursor,
            perPage: 15,
          );

      links.addAll(result.items);
      _nextCursor = result.nextCursor;
      isLoadingMore.value = false;
    } catch (e) {
      isLoadingMore.value = false;
      loadMoreError.value = AppException.sanitizeMessage(e.toString());
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
  void openPartnerDetails(NetworkPosLinkEntity link) {
    CustomBottomSheet.show<void>(
      title: 'ملف مزود الشبكة',
      subtitle: 'البيانات التجارية المعتمدة للشريك',
      leadingIcon: Icons.hub_rounded,
      child: CommercialPartnerDetailsSheet(link: link, isNetworkView: false),
    );
  }

  @override
  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final activePres = EnumPresentationRegistry.resolveLinkStatus(true);
    final inactivePres = EnumPresentationRegistry.resolveLinkStatus(false);

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: totalPartnersCount,
        icon: Icons.all_inbox_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: activePres.label,
        count: activePartnersCount,
        icon: activePres.icon ?? Icons.check_circle_rounded,
        accentColor: activePres.tone.color(context),
        statusKey: '1',
      ),
      CustomKpiCardData(
        label: inactivePres.label,
        count: inactivePartnersCount,
        icon: inactivePres.icon ?? Icons.pause_circle_rounded,
        accentColor: inactivePres.tone.color(context),
        statusKey: '0',
      ),
    ];
  }

  @override
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    final activePres = EnumPresentationRegistry.resolveLinkStatus(true);
    final inactivePres = EnumPresentationRegistry.resolveLinkStatus(false);

    return [
      const CustomSearchFilterOption<String?>(
        label: 'جميع المزودين',
        value: null,
        icon: Icons.all_inbox_rounded,
      ),
      CustomSearchFilterOption<String?>(
        label: activePres.label,
        value: '1',
        icon: activePres.icon ?? Icons.check_circle_rounded,
      ),
      CustomSearchFilterOption<String?>(
        label: inactivePres.label,
        value: '0',
        icon: inactivePres.icon ?? Icons.pause_circle_rounded,
      ),
    ];
  }

  @override
  Widget? buildExtraFilters(BuildContext context) {
    final posList = authorizedPosList;
    if (posList.length <= 1) return null;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomDropdown<int>(
        label: 'تصفية بحسب نقطة البيع',
        searchEnabled: false,
        rxValue: selectedPosId,
        items: posList.map((pos) {
          return DropdownItem<int>(value: pos.posId, child: Text(pos.posName));
        }).toList(),
        onChanged: onPosFilterChanged,
      ),
    );
  }

  @override
  Widget buildCardActions(BuildContext context, NetworkPosLinkEntity link) {
    return CommercialPartnerCardActions(
      link: link,
      isNetworkView: false,
      onViewDetails: () => openPartnerDetails(link),
      onDelete: canManageCommercial ? () => onDeleteLink(link) : null,
    );
  }

  void onDeleteLink(NetworkPosLinkEntity link) {
    CommercialActionDialogs.showUnlinkDialog(
      partnerName: link.displayNetworkName,
      onConfirm: () async {
        try {
          await deleteNetworkPosLinkUseCase(link.networkPosId);
          links.removeWhere(
            (element) => element.networkPosId == link.networkPosId,
          );
          await CustomAnimationOverlay.showSuccess(
            message: 'تم فك الارتباط بمزود الشبكة بنجاح',
          );
        } catch (e) {
          CustomSnackbar.show(
            title: 'خطأ',
            message: AppException.sanitizeMessage(e.toString()),
            type: SnackType.error,
          );
        }
      },
    );
  }

  Future<void> openQrScannerFlow() async {
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
                  'تم ربط نقطة البيع بنجاح مع شبكة ${preview.displayNetworkName}',
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
