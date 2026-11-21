import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_link_challenge_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/resolve_network_linkable_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_action_dialogs.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_actions.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_qr_invitation_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_invitation_target_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:share_plus/share_plus.dart' show ShareResultStatus;

/// متحكم دليل نقاط البيع والشركاء لمساحة عمل شبكة التوزيع (Network Commercial Directory)
class NetworkCommercialDirectoryController
    extends BaseCommercialDirectoryController {
  NetworkCommercialDirectoryController({
    required this.getNetworkPosListUseCase,
    required this.toggleNetworkPosLinkStatusUseCase,
    required this.deleteNetworkPosLinkUseCase,
    required this.createNetworkPosLinkChallengeUseCase,
    required this.revokeNetworkPosLinkChallengeUseCase,
    this.getMyNetworksUseCase,
    required this.getNetworkPosLinkChallengeStatusUseCase,
    required this.resolveNetworkLinkablePosUseCase,
  });

  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final ToggleNetworkPosLinkStatusUseCase toggleNetworkPosLinkStatusUseCase;
  final DeleteNetworkPosLinkUseCase deleteNetworkPosLinkUseCase;
  final CreateNetworkPosLinkChallengeUseCase
  createNetworkPosLinkChallengeUseCase;
  final RevokeNetworkPosLinkChallengeUseCase
  revokeNetworkPosLinkChallengeUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;
  final GetNetworkPosLinkChallengeStatusUseCase
  getNetworkPosLinkChallengeStatusUseCase;
  final ResolveNetworkLinkablePosUseCase resolveNetworkLinkablePosUseCase;

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

  final authorizedNetworks = <NetworkEntity>[].obs;

  final TextEditingController invitationBusinessCodeController = TextEditingController();
  final RxBool isResolvingInvitationTarget = false.obs;
  final Rxn<PosEntity> resolvedInvitationTarget = Rxn<PosEntity>();

  final GlobalKey invitationShareCardKey = GlobalKey();
  final Rx<LinkingChallengeStatus> invitationStatus = LinkingChallengeStatus.pending.obs;
  final Rxn<DateTime> invitationExpiresAt = Rxn<DateTime>();
  final Rx<DateTime> invitationClock = DateTime.now().obs;
  final RxBool isExportingInvitation = false.obs;
  final RxnString invitationStatusRefreshError = RxnString();
  Timer? _invitationStatusTimer;
  Timer? _invitationClockTimer;
  NetworkPosLinkChallengeEntity? _activeInvitation;
  bool _isInvitationStatusRequestInFlight = false;
  final selectedNetworkId = RxnInt();

  String? _nextCursor;
  int _listRevision = 0;

  @override
  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  @override
  bool get isNetworkView => true;

  int get totalPartnersCount => links.length;

  int get activePartnersCount => links.where((link) => link.isActive).length;

  int get inactivePartnersCount => links.where((link) => !link.isActive).length;

  bool get canManageCommercial =>
      PermissionService.to.can(AppPermissions.networksEdit);

  int? get resolvedNetworkId {
    return selectedNetworkId.value ??
        (authorizedNetworks.isNotEmpty
            ? authorizedNetworks.first.networkId
            : null);
  }

  @override
  String get pageTitle => 'دليل نقاط البيع والشركاء';

  @override
  String get pageSubtitle =>
      'إدارة ومتابعة نقاط البيع المرتبطة، حالة النشاط التجاري، وتوليد رموز الانضمام (QR).';

  @override
  IconData get pageIcon => Icons.storefront_rounded;

  @override
  String get searchHint => 'البحث باسم نقطة البيع أو المعرف أو الهاتف...';

  @override
  Widget? get headerAction {
    if (!canManageCommercial) return null;
    return CustomButton.primary(
      text: 'دعوة نقطة بيع +',
      icon: Icons.qr_code_rounded,
      shape: AppButtonShape.pill,
      size: AppButtonSize.small,
      onPressed: openCreateQrInvitation,
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
    invitationBusinessCodeController.dispose();
    stopInvitationMonitoring();
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
        networks.map((n) => n.networkId).toList(growable: false),
      );
    } catch (_) {
      authorizedNetworks.clear();
      selectedNetworkId.value = null;
    }
  }

  void onNetworkFilterChanged(int? networkId) {
    if (networkId == null || selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
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
    final netId = resolvedNetworkId;

    if (netId == null) {
      isLoading.value = false;
      errorMessage.value = 'يرجى تحديد الشبكة أولاً لعرض الشركاء.';
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
          await getNetworkPosListUseCase(
            networkId: netId,
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
    final netId = resolvedNetworkId;
    if (netId == null || !hasMore || isLoadingMore.value) return;

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
          await getNetworkPosListUseCase(
            networkId: netId,
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
      title: 'ملف نقطة البيع',
      subtitle: 'البيانات التجارية المعتمدة للشريك',
      leadingIcon: Icons.storefront_rounded,
      child: CommercialPartnerDetailsSheet(link: link, isNetworkView: true),
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
        label: 'جميع الشركاء',
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
    final networks = authorizedNetworks;
    if (networks.length <= 1) return null;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomDropdown<int>(
        label: 'تصفية بحسب الشبكة',
        searchEnabled: false,
        rxValue: selectedNetworkId,
        items: networks.map((net) {
          return DropdownItem<int>(
            value: net.networkId,
            child: Text(net.networkName),
          );
        }).toList(),
        onChanged: onNetworkFilterChanged,
      ),
    );
  }

  @override
  Widget buildCardActions(BuildContext context, NetworkPosLinkEntity link) {
    return CommercialPartnerCardActions(
      link: link,
      isNetworkView: true,
      onViewDetails: () => openPartnerDetails(link),
      onToggleStatus: canManageCommercial ? () => onToggleStatus(link) : null,
      onDelete: canManageCommercial ? () => onDeleteLink(link) : null,
    );
  }

  void onToggleStatus(NetworkPosLinkEntity link) {
    CommercialActionDialogs.showToggleStatusDialog(
      partnerName: link.displayPosName,
      willDeactivate: link.isActive,
      onConfirm: () async {
        try {
          final updated = await toggleNetworkPosLinkStatusUseCase(
            link.networkPosId,
          );
          final index = links.indexWhere(
            (item) => item.networkPosId == link.networkPosId,
          );
          if (index != -1) {
            links[index] = updated;
          }
          await CustomAnimationOverlay.showSuccess(
            message: updated.isActive
                ? 'تم تنشيط الارتباط بنجاح'
                : 'تم تجميد الارتباط بنجاح',
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

  void onDeleteLink(NetworkPosLinkEntity link) {
    CommercialActionDialogs.showUnlinkDialog(
      partnerName: link.displayPosName,
      onConfirm: () async {
        try {
          await deleteNetworkPosLinkUseCase(link.networkPosId);
          links.removeWhere(
            (element) => element.networkPosId == link.networkPosId,
          );
          await CustomAnimationOverlay.showSuccess(
            message: 'تم فك الارتباط التجاري بنجاح',
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



  void onInvitationBusinessCodeChanged(String value) {
    resolvedInvitationTarget.value = null;
  }

  void cancelInvitationTargetDialog() {
    if (isResolvingInvitationTarget.value) return;
    resolvedInvitationTarget.value = null;
    Get.back<void>();
  }

  Future<void> resolveInvitationTarget() async {
    final code = invitationBusinessCodeController.text.trim().toUpperCase();
    if (!RegExp(r'^POS-\d{4}-\d{5}-[A-F0-9]{4}$').hasMatch(code)) {
      CustomSnackbar.show(title: 'تحقق من المعرف', message: 'أدخل المعرف التجاري لنقطة البيع بالصيغة الموجودة في ملفها.', type: SnackType.warning);
      return;
    }
    if (isResolvingInvitationTarget.value) return;
    final networkId = resolvedNetworkId;
    if (networkId == null) {
      CustomSnackbar.show(title: 'تعذر تحديد الشبكة', message: 'اختر الشبكة التي ستصدر الدعوة باسمها أولاً.', type: SnackType.warning);
      return;
    }
    isResolvingInvitationTarget.value = true;
    try {
      final target = await resolveNetworkLinkablePosUseCase(networkId: networkId, posBusinessCode: code);
      if (target.posId <= 0 || target.posUuid.trim().isEmpty) {
        throw const AppException('لم يُرجع الخادم هوية صالحة لنقطة البيع المستهدفة.');
      }
      resolvedInvitationTarget.value = target;
      Get.back<void>();
    } catch (error) {
      CustomSnackbar.show(title: 'لم يتم العثور على جهة مؤهلة', message: AppException.sanitizeMessage(error), type: SnackType.error);
    } finally {
      isResolvingInvitationTarget.value = false;
    }
  }

  void startInvitationMonitoring(NetworkPosLinkChallengeEntity challenge) {
    stopInvitationMonitoring();
    _activeInvitation = challenge;
    invitationStatus.value = challenge.typedStatus;
    invitationExpiresAt.value = DateTime.tryParse(challenge.expiresAt ?? '');
    invitationClock.value = DateTime.now();
    invitationStatusRefreshError.value = null;
    _refreshInvitationStatus();
    if (invitationStatus.value == LinkingChallengeStatus.pending) {
      _invitationStatusTimer = Timer.periodic(const Duration(seconds: 10), (_) => _refreshInvitationStatus());
      _invitationClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        invitationClock.value = DateTime.now();
        if (invitationStatus.value != LinkingChallengeStatus.pending) _cancelInvitationTimers();
      });
    }
  }

  bool get isInvitationActive {
    final expiry = invitationExpiresAt.value;
    return invitationStatus.value == LinkingChallengeStatus.pending && expiry != null && expiry.isAfter(invitationClock.value);
  }

  String get invitationExpiresAtLabel {
    final expiry = invitationExpiresAt.value;
    return expiry == null ? 'غير متاح' : DateFormatter.dateTime(expiry.toLocal());
  }

  String get invitationRemainingLabel {
    final expiry = invitationExpiresAt.value;
    if (expiry == null) return 'تعذر تحديد وقت الانتهاء';
    final remaining = expiry.difference(invitationClock.value);
    if (remaining <= Duration.zero) return 'انتهت مدة الدعوة';
    return 'متبقي ' + remaining.inMinutes.toString() + ' دقيقة و' + (remaining.inSeconds % 60).toString() + ' ثانية';
  }

  void _cancelInvitationTimers() {
    _invitationStatusTimer?.cancel();
    _invitationStatusTimer = null;
    _invitationClockTimer?.cancel();
    _invitationClockTimer = null;
  }

  void stopInvitationMonitoring() {
    _cancelInvitationTimers();
    _activeInvitation = null;
    _isInvitationStatusRequestInFlight = false;
  }

  Future<void> _refreshInvitationStatus() async {
    final challenge = _activeInvitation;
    if (challenge == null || invitationStatus.value != LinkingChallengeStatus.pending || _isInvitationStatusRequestInFlight) return;
    _isInvitationStatusRequestInFlight = true;
    try {
      final latest = await getNetworkPosLinkChallengeStatusUseCase(challenge.challengeUuid);
      if (_activeInvitation?.challengeUuid != challenge.challengeUuid) return;
      invitationStatus.value = latest.status;
      invitationExpiresAt.value = latest.expiresAt ?? invitationExpiresAt.value;
      invitationStatusRefreshError.value = null;
      if (latest.status != LinkingChallengeStatus.pending) _cancelInvitationTimers();
    } catch (error) {
      if (_activeInvitation?.challengeUuid == challenge.challengeUuid) {
        invitationStatusRefreshError.value = AppException.sanitizeMessage(error);
      }
    } finally {
      _isInvitationStatusRequestInFlight = false;
    }
  }

  Future<Uint8List> captureInvitationCard(BuildContext context) async {
    await precacheImage(const AssetImage('assets/images/brand_icon.png'), context);
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = invitationShareCardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) throw const AppException('تعذر تجهيز بطاقة الدعوة للتصدير.');
    final image = await renderObject.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const AppException('تعذر تحويل بطاقة الدعوة إلى صورة.');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      if (bytes.isEmpty) throw const AppException('الصورة الناتجة لبطاقة الدعوة فارغة.');
      return bytes;
    } finally {
      image.dispose();
    }
  }

  Future<void> shareInvitation(BuildContext context) async {
    if (!isInvitationActive || isExportingInvitation.value) return;
    isExportingInvitation.value = true;
    try {
      final bytes = await captureInvitationCard(context);
      final result = await ShareService.instance.shareBytes(bytes: bytes, fileName: 'NetSales_Invitation.png', mimeType: 'image/png', subject: 'دعوة ربط عبر NetSales', text: 'امسح رمز الدعوة من داخل تطبيق NetSales.');
      if (result.status == ShareResultStatus.success) {
        CustomSnackbar.show(title: 'تمت المشاركة', message: 'تم إرسال بطاقة الدعوة إلى تطبيق المشاركة المختار.', type: SnackType.success);
      }
    } catch (error) {
      CustomSnackbar.show(title: 'تعذرت المشاركة', message: AppException.sanitizeMessage(error), type: SnackType.error);
    } finally {
      isExportingInvitation.value = false;
    }
  }

  Future<void> saveInvitation(BuildContext context) async {
    if (!isInvitationActive || isExportingInvitation.value) return;
    isExportingInvitation.value = true;
    try {
      final bytes = await captureInvitationCard(context);
      final result = await FileExportService.instance.saveFile(bytes: bytes, fileName: 'NetSales_Invitation', extension: 'png', folderName: 'NetSales', autoOpen: false, showFeedback: false);
      CustomSnackbar.show(title: result.isSuccess ? 'تم حفظ الدعوة' : 'تعذر حفظ الدعوة', message: result.isSuccess ? 'تم حفظ بطاقة الدعوة في مجلد تنزيلات NetSales.' : (result.errorMessage ?? 'لم نتمكن من حفظ صورة الدعوة.'), type: result.isSuccess ? SnackType.success : SnackType.error);
    } catch (error) {
      CustomSnackbar.show(title: 'تعذر حفظ الدعوة', message: AppException.sanitizeMessage(error), type: SnackType.error);
    } finally {
      isExportingInvitation.value = false;
    }
  }

  Future<void> revokeActiveInvitation() async {
    final challenge = _activeInvitation;
    if (challenge == null || invitationStatus.value != LinkingChallengeStatus.pending) return;
    try {
      await revokeNetworkPosLinkChallengeUseCase(challenge.challengeUuid);
      invitationStatus.value = LinkingChallengeStatus.revoked;
      _cancelInvitationTimers();
      await CustomAnimationOverlay.showSuccess(message: 'تم إلغاء رمز الدعوة بنجاح');
      Get.back<void>();
    } catch (error) {
      CustomSnackbar.show(title: 'تعذر إلغاء الدعوة', message: AppException.sanitizeMessage(error), type: SnackType.error);
    }
  }

  Future<void> openCreateQrInvitation() async {
    final netId = resolvedNetworkId;
    if (netId == null) {
      CustomSnackbar.show(title: 'تنبيه', message: 'يرجى اختيار الشبكة أولاً', type: SnackType.warning);
      return;
    }
    invitationBusinessCodeController.clear();
    resolvedInvitationTarget.value = null;
    try {
      await CustomDialog.show(
        type: DialogType.custom,
        title: 'تحديد نقطة البيع المستهدفة',
        content: NetworkPosInvitationTargetDialog(controller: this),
        canPop: false,
        maxWidth: 480,
      );
      final target = resolvedInvitationTarget.value;
      if (target == null) return;
      final challenge = await createNetworkPosLinkChallengeUseCase(networkId: netId, posUuid: target.posUuid);
      final networkName = challenge.network?.networkName.trim() ?? '';
      final posName = challenge.pos?.posName.trim() ?? '';
      if (challenge.networkId != netId || challenge.posId != target.posId || networkName.isEmpty || posName.isEmpty || challenge.expiresAt == null) {
        throw const AppException('لم يؤكد الخادم تطابق الشبكة ونقطة البيع ووقت انتهاء الدعوة.');
      }
      startInvitationMonitoring(challenge);
      try {
        await CustomBottomSheet.show<void>(
          title: 'دعوة ربط نقطة بيع',
          subtitle: 'دعوة موجهة حصرياً إلى نقطة البيع المحددة',
          leadingIcon: Icons.qr_code_rounded,
          child: NetworkPosQrInvitationSheet(controller: this, challenge: challenge, networkName: networkName, posName: posName),
        );
      } finally {
        stopInvitationMonitoring();
      }
    } catch (error) {
      CustomSnackbar.show(title: 'فشل إنشاء الدعوة', message: AppException.sanitizeMessage(error), type: SnackType.error);
    } finally {
      resolvedInvitationTarget.value = null;
    }
  }
}
