import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_status_summary_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/base_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/network_request_modification_sheet.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/features/requests/presentation/widgets/request_approval_result_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم مراجعة واعتماد طلبات التوريد لمشغلي الشبكة (Network Procurement Review Controller)
class NetworkProcurementReviewController
    extends BaseProcurementOrdersController {
  final GetRequestsUseCase getRequestsUseCase;
  final ApproveRequestUseCase approveRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;
  final PreviewRequestModificationUseCase previewRequestModificationUseCase;
  final GetPackagesUseCase getPackagesUseCase;
  final GetRequestDetailsUseCase getRequestDetailsUseCase;
  final GetRequestStatusSummaryUseCase? getRequestStatusSummaryUseCase;
  int _modificationRevision = 0;
  int _editorLoadRevision = 0;
  int _packageLoadRevision = 0;

  NetworkProcurementReviewController({
    required this.getRequestsUseCase,
    required this.approveRequestUseCase,
    required this.rejectRequestUseCase,
    required this.previewRequestModificationUseCase,
    required this.getPackagesUseCase,
    required this.getRequestDetailsUseCase,
    this.getMyNetworksUseCase,
    this.getRequestStatusSummaryUseCase,
  });

  @override
  String get pageTitle => 'مراجعة طلبات التوريد';

  @override
  String get pageSubtitle =>
      'فحص واعتماد أو تعديل طلبات الكروت الواردة من نقاط البيع التابعة بدقة وسرعة.';

  @override
  IconData get pageIcon => Icons.fact_check_rounded;

  @override
  Widget? get headerAction => null;

  @override
  String get searchHint => 'بحث برقم الطلب، المعرف، أو اسم نقطة البيع...';

  @override
  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final pendingPres = EnumPresentationRegistry.resolveRequestStatus(
      RequestStatus.pending,
    );
    final approvedPres = EnumPresentationRegistry.resolveRequestStatus(
      RequestStatus.approved,
    );
    final rejectedPres = EnumPresentationRegistry.resolveRequestStatus(
      RequestStatus.rejected,
    );
    final cancelledPres = EnumPresentationRegistry.resolveRequestStatus(
      RequestStatus.cancelled,
    );

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: totalOrdersCount,
        icon: Icons.all_inbox_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: pendingPres.label,
        count: pendingOrdersCount,
        icon: pendingPres.icon ?? Icons.hourglass_top_rounded,
        accentColor: pendingPres.tone.color(context),
        statusKey: RequestStatus.pending.wireValue,
      ),
      CustomKpiCardData(
        label: approvedPres.label,
        count: approvedOrdersCount,
        icon: approvedPres.icon ?? Icons.check_circle_rounded,
        accentColor: approvedPres.tone.color(context),
        statusKey: RequestStatus.approved.wireValue,
      ),
      CustomKpiCardData(
        label: rejectedPres.label,
        count: rejectedOrdersCount,
        icon: rejectedPres.icon ?? Icons.cancel_rounded,
        accentColor: rejectedPres.tone.color(context),
        statusKey: RequestStatus.rejected.wireValue,
      ),
      CustomKpiCardData(
        label: cancelledPres.label,
        count: cancelledOrdersCount,
        icon: cancelledPres.icon ?? Icons.highlight_off_rounded,
        accentColor: cancelledPres.tone.color(context),
        statusKey: RequestStatus.cancelled.wireValue,
      ),
    ];
  }

  @override
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    return [
      const CustomSearchFilterOption<String?>(
        label: 'جميع الحالات',
        value: null,
        icon: Icons.all_inbox_rounded,
      ),
      for (final RequestStatus status in RequestStatus.values.where(
        (RequestStatus s) => s != RequestStatus.unknown,
      ))
        CustomSearchFilterOption<String?>(
          label: EnumPresentationRegistry.resolveRequestStatus(status).label,
          value: status.wireValue,
          icon:
              EnumPresentationRegistry.resolveRequestStatus(status).icon ??
              Icons.label_outline_rounded,
        ),
    ];
  }

  @override
  Widget? buildExtraFilters(BuildContext context) {
    if (authorizedNetworks.length <= 1) return null;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomDropdown<int>(
        label: 'تصفية بحسب الشبكة',
        searchEnabled: false,
        rxValue: selectedNetworkId,
        items: authorizedNetworks.map((net) {
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
  Widget buildCardActions(BuildContext context, RequestEntity request) {
    return ProcurementOrderCardActions(
      request: request,
      onDetails: () => openRequestDetails(request),
      isNetworkView: true,
      onApprove: (request.isPending && canApproveRequests)
          ? () => promptApproveRequest(request)
          : null,
      onModify: (request.isPending && canModifyRequests)
          ? () => openModificationSheet(request)
          : null,
      onReject: (request.isPending && canRejectRequests)
          ? () => promptRejectRequest(request)
          : null,
    );
  }

  // State: قائمة طلبات التوريد الواردة والترقيم
  @override
  final requests = <RequestEntity>[].obs;
  final statusSummary = Rxn<RequestStatusSummaryEntity>();
  @override
  final isLoading = true.obs;
  final isLoadingSummary = false.obs;
  @override
  final isLoadingMore = false.obs;
  final isProcessingDecision = false.obs;
  @override
  final errorMessage = RxnString();
  @override
  final loadMoreError = RxnString();
  final nextCursor = RxnString();
  @override
  final expandedRequestId = RxnInt();

  @override
  bool get hasMore => nextCursor.value != null;

  int get totalOrdersCount => statusSummary.value?.total ?? requests.length;
  int get pendingOrdersCount =>
      statusSummary.value?.pending ??
      requests.where((request) => request.isPending).length;
  int get approvedOrdersCount =>
      statusSummary.value?.approved ??
      requests.where((request) => request.isApproved).length;
  int get rejectedOrdersCount =>
      statusSummary.value?.rejected ??
      requests.where((request) => request.isRejected).length;
  int get cancelledOrdersCount =>
      statusSummary.value?.cancelled ??
      requests.where((request) => request.isCancelled).length;

  @override
  Future<void> refreshOrders() => Future.wait([
    loadRequests(isRefresh: true, clearOnStart: true),
    loadStatusSummary(),
  ]);

  @override
  void toggleAccordion(int requestId) {
    if (expandedRequestId.value == requestId) {
      expandedRequestId.value = null;
    } else {
      expandedRequestId.value = requestId;
    }
  }

  // فلاتر وبحث الطلبات
  @override
  final searchController = TextEditingController();
  @override
  final searchQuery = ''.obs;
  @override
  final statusFilter = RxnString(); // null = all, PENDING, APPROVED, REJECTED
  final selectedNetworkId = RxnInt();

  // شبكات المشغل التابعة
  final authorizedNetworks = <NetworkEntity>[].obs;

  final availablePackages = <PackageEntity>[].obs;
  final isLoadingPackages = false.obs;
  final isPreviewingModification = false.obs;
  final currentPreview = Rxn<RequestModificationPreviewEntity>();
  final lastApprovalResult = Rxn<RequestApprovalResultEntity>();
  final modificationLines = <RequestModificationLineEntity>[].obs;
  final editingRequestId = RxnInt();
  final editingRequest = Rxn<RequestEntity>();
  final isLoadingEditor = false.obs;
  final editorError = RxnString();
  final modificationNoteController = TextEditingController();
  final Map<int, TextEditingController> _modificationQuantityControllers = {};
  int _requestListRevision = 0;

  /// وحدة تحكم نصية متزامنة لكمية الباقة في مسودة التعديل
  TextEditingController modificationQuantityController(
    int packageId,
    int currentQuantity,
  ) {
    final controller = _modificationQuantityControllers.putIfAbsent(
      packageId,
      () => TextEditingController(text: currentQuantity.toString()),
    );
    if (controller.text != currentQuantity.toString() &&
        !controller.value.isComposingRangeValid) {
      controller.value = TextEditingValue(
        text: currentQuantity.toString(),
        selection: TextSelection.collapsed(
          offset: currentQuantity.toString().length,
        ),
      );
    }
    return controller;
  }

  /// التحقق من صلاحيات مراجعة واعتماد وتعديل طلبات التوريد لمشغل الشبكة
  bool get canApproveRequests =>
      PermissionService.to.can(AppPermissions.requestsApprove);
  bool get canRejectRequests =>
      PermissionService.to.can(AppPermissions.requestsReject);
  bool get canModifyRequests =>
      PermissionService.to.can(AppPermissions.requestsEdit);

  /// هل توجد تعديلات فعلية على مسودة الباقات مقارنة بالطلب الأصلي
  bool get hasModificationChanges {
    final original = editingRequest.value;
    if (original == null) return false;
    if (modificationLines.isEmpty) return false;

    // اختلاف عدد الباقات يعني إضافة باقة جديدة أو حذف باقة أصلية
    if (original.items.length != modificationLines.length) return true;

    // فحص كل بند أصلي: هل تغيرت كميته أو تم استبعاده
    for (final origItem in original.items) {
      final line = modificationLines.firstWhereOrNull(
        (l) => l.packageId == origItem.packageId,
      );
      if (line == null || line.voucherCount != origItem.voucherCount) {
        return true;
      }
    }

    return false;
  }

  /// الباقات غير المضافة بعد من الكتالوج
  List<PackageEntity> get unselectedAvailablePackages {
    final selectedIds = modificationLines.map((line) => line.packageId).toSet();
    return availablePackages
        .where((p) => !selectedIds.contains(p.packageId))
        .toList(growable: false);
  }

  /// استرجاع بيانات الباقة للعرض عند التعديل
  PackageEntity resolvePackageForModification(int packageId) {
    final fromCatalog = availablePackages.firstWhereOrNull(
      (p) => p.packageId == packageId,
    );
    if (fromCatalog != null) return fromCatalog;

    final fromRequest = editingRequest.value?.items.firstWhereOrNull(
      (i) => i.packageId == packageId,
    );
    if (fromRequest?.voucherPackage != null) {
      return fromRequest!.voucherPackage!;
    }

    return PackageEntity(
      packageId: packageId,
      networkId: editingRequest.value?.networkId ?? 0,
      packageName:
          fromRequest?.voucherPackage?.packageName ?? 'باقة #$packageId',
      packageColor: fromRequest?.voucherPackage?.packageColor ?? '#087B61',
      packageBalance: fromRequest?.voucherPackage?.packageBalance ?? 0,
      packageValidity: fromRequest?.voucherPackage?.packageValidity ?? 0,
      packageUptime: fromRequest?.voucherPackage?.packageUptime ?? 0,
      packageVoucherCount:
          fromRequest?.voucherPackage?.packageVoucherCount ?? 100,
      packageVoucherPrice: fromRequest?.voucherPrice ?? 0,
      packageDefaultCashDiscount: fromRequest?.itemDiscount ?? 0,
      packageDefaultCreditDiscount: 0,
      cashDiscountAmount: 0,
      creditDiscountAmount: 0,
      effectiveCashPrice: fromRequest?.voucherPrice ?? 0,
      effectiveCreditPrice: fromRequest?.voucherPrice ?? 0,
      status: true,
    );
  }

  /// التحقق مما إذا كان البند مضافاً حديثاً وغير موجود بالطلب الأصلي
  bool isItemNewlyAdded(int packageId) {
    final original = editingRequest.value;
    if (original == null) return false;
    return !original.items.any((i) => i.packageId == packageId);
  }

  Future<void> beginModification(RequestEntity request) async {
    if (!request.isPending) return;

    final requestId = request.requestId;
    final loadRevision = ++_editorLoadRevision;
    _packageLoadRevision++;
    _modificationRevision++;
    editingRequestId.value = requestId;
    editingRequest.value = request;
    isLoadingEditor.value = true;
    editorError.value = null;
    currentPreview.value = null;
    modificationLines.clear();
    availablePackages.clear();

    if (request.items.isNotEmpty) {
      modificationLines.assignAll(
        request.items.map(
          (item) => RequestModificationLineEntity(
            packageId: item.packageId,
            voucherCount: item.voucherCount,
          ),
        ),
      );
    }

    try {
      final detailedRequest = await getRequestDetailsUseCase(requestId);
      if (loadRevision != _editorLoadRevision ||
          editingRequestId.value != requestId) {
        return;
      }
      if (!detailedRequest.isPending) {
        clearModificationEditor();
        return;
      }

      editingRequest.value = detailedRequest;
      modificationLines.assignAll(
        detailedRequest.items.map(
          (item) => RequestModificationLineEntity(
            packageId: item.packageId,
            voucherCount: item.voucherCount,
          ),
        ),
      );
      modificationNoteController.text = detailedRequest.requestNote ?? '';
      await loadModificationPackages(
        detailedRequest.networkId,
        requestId: requestId,
        editorRevision: loadRevision,
      );
    } catch (error) {
      if (loadRevision != _editorLoadRevision ||
          editingRequestId.value != requestId) {
        return;
      }
      editorError.value = error is AppException
          ? error.message
          : error.toString();
      CustomSnackbar.show(
        title: 'تعذر تحميل تفاصيل الطلب',
        message: editorError.value!,
        type: SnackType.error,
      );
    } finally {
      if (loadRevision == _editorLoadRevision) {
        isLoadingEditor.value = false;
      }
    }
  }

  Future<void> loadModificationPackages(
    int networkId, {
    required int requestId,
    required int editorRevision,
  }) async {
    final packageRevision = ++_packageLoadRevision;
    isLoadingPackages.value = true;
    try {
      final result = await getPackagesUseCase(
        networkId: networkId,
        status: true,
        perPage: 100,
      );
      if (packageRevision != _packageLoadRevision ||
          editorRevision != _editorLoadRevision ||
          editingRequestId.value != requestId) {
        return;
      }
      availablePackages.assignAll(result.items);
    } catch (error) {
      if (packageRevision != _packageLoadRevision ||
          editorRevision != _editorLoadRevision ||
          editingRequestId.value != requestId) {
        return;
      }
      CustomSnackbar.show(
        title: 'تعذر تحميل الباقات',
        message: error is AppException ? error.message : error.toString(),
        type: SnackType.error,
      );
    } finally {
      if (packageRevision == _packageLoadRevision) {
        isLoadingPackages.value = false;
      }
    }
  }

  void setModificationQuantity(int packageId, int quantity) {
    if (quantity < 1) return;
    _modificationRevision++;
    final index = modificationLines.indexWhere(
      (line) => line.packageId == packageId,
    );
    if (index < 0) return;
    final current = modificationLines[index];
    modificationLines[index] = RequestModificationLineEntity(
      packageId: packageId,
      voucherCount: quantity,
      pricingToken: current.pricingToken,
    );
    final textCtrl = _modificationQuantityControllers[packageId];
    if (textCtrl != null && textCtrl.text != quantity.toString()) {
      textCtrl.value = TextEditingValue(
        text: quantity.toString(),
        selection: TextSelection.collapsed(offset: quantity.toString().length),
      );
    }
    currentPreview.value = null;
  }

  /// زيادة أو إنقاص كمية التعديل بمقدار ورقة كاملة وفق سعة الباقة (Zero Clamp)
  void stepModificationSheet(int packageId, {required bool isIncrement}) {
    final line = modificationLines.firstWhereOrNull(
      (l) => l.packageId == packageId,
    );
    if (line == null) return;
    final package = availablePackages.firstWhereOrNull(
      (p) => p.packageId == packageId,
    );
    final sheetSize = package?.packageVoucherCount ?? 0;
    final step = sheetSize > 0 ? sheetSize : 1;

    final target = isIncrement
        ? line.voucherCount + step
        : (line.voucherCount - step > 0 ? line.voucherCount - step : 1);

    setModificationQuantity(packageId, target);
  }

  /// زيادة أو إنقاص كمية التعديل بمقدار نصف ورقة
  void stepModificationHalfSheet(int packageId, {required bool isIncrement}) {
    final line = modificationLines.firstWhereOrNull(
      (l) => l.packageId == packageId,
    );
    if (line == null) return;
    final package = availablePackages.firstWhereOrNull(
      (p) => p.packageId == packageId,
    );
    final sheetSize = package?.packageVoucherCount ?? 0;
    final step = sheetSize > 1 ? (sheetSize / 2).ceil() : 1;

    final target = isIncrement
        ? line.voucherCount + step
        : (line.voucherCount - step > 0 ? line.voucherCount - step : 1);

    setModificationQuantity(packageId, target);
  }

  void addModificationPackage(int packageId, {int initialQuantity = 1}) {
    if (modificationLines.any((line) => line.packageId == packageId)) return;
    _modificationRevision++;
    modificationLines.add(
      RequestModificationLineEntity(
        packageId: packageId,
        voucherCount: initialQuantity,
      ),
    );
    currentPreview.value = null;
  }

  void removeModificationPackage(int packageId) {
    _modificationRevision++;
    modificationLines.removeWhere((line) => line.packageId == packageId);
    _modificationQuantityControllers[packageId]?.dispose();
    _modificationQuantityControllers.remove(packageId);
    currentPreview.value = null;
  }

  Future<bool> previewModification() async {
    final requestId = editingRequestId.value;
    if (requestId == null ||
        modificationLines.isEmpty ||
        isPreviewingModification.value ||
        isProcessingDecision.value) {
      return false;
    }
    currentPreview.value = null;
    isPreviewingModification.value = true;
    final revision = _modificationRevision;
    final submittedLines = modificationLines.toList(growable: false);
    try {
      final preview = await previewRequestModificationUseCase(
        requestId,
        submittedLines,
      );
      if (revision != _modificationRevision ||
          editingRequestId.value != requestId) {
        return false;
      }
      currentPreview.value = preview;
      return true;
    } catch (error) {
      currentPreview.value = null;
      CustomSnackbar.show(
        title: 'تعذرت معاينة التعديل',
        message: error is AppException ? error.message : error.toString(),
        type: SnackType.error,
      );
      return false;
    } finally {
      isPreviewingModification.value = false;
    }
  }

  Future<void> approvePreview({String? requestNote}) async {
    final preview = currentPreview.value;
    final requestId = editingRequestId.value;
    if (preview == null || requestId == null || !preview.hasModifications) {
      return;
    }
    final draft = modificationLines
        .map((line) => '${line.packageId}:${line.voucherCount}')
        .toSet();
    final reviewed = preview.items
        .map((line) => '${line.packageId}:${line.voucherCount}')
        .toSet();
    if (draft.length != reviewed.length || !draft.containsAll(reviewed)) {
      currentPreview.value = null;
      CustomSnackbar.show(
        title: 'المعاينة لم تعد مطابقة',
        message: 'تغيرت البنود بعد المعاينة. أعد المعاينة قبل الاعتماد.',
        type: SnackType.warning,
      );
    }
    return approveRequest(
      requestId,
      requestNote: requestNote,
      items: preview.approvalItems,
    );
  }

  void clearModificationEditor() {
    _modificationRevision++;
    _editorLoadRevision++;
    _packageLoadRevision++;
    isLoadingPackages.value = false;
    editingRequestId.value = null;
    editingRequest.value = null;
    currentPreview.value = null;
    modificationLines.clear();
    availablePackages.clear();
    modificationNoteController.clear();
    for (final c in _modificationQuantityControllers.values) {
      c.dispose();
    }
    _modificationQuantityControllers.clear();
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadRequests(isRefresh: true, clearOnStart: true),
      time: const Duration(milliseconds: 350),
    );

    loadNetworksAndRequests();
  }

  @override
  void onClose() {
    searchController.dispose();
    modificationNoteController.dispose();
    for (final c in _modificationQuantityControllers.values) {
      c.dispose();
    }
    _modificationQuantityControllers.clear();
    _requestListRevision++;
    super.onClose();
  }

  /// تحميل الشبكات التابعة للمشغل ثم جلب الطلبات الواردة
  Future<void> loadNetworksAndRequests() async {
    await loadAuthorizedNetworks();
    await Future.wait([
      loadRequests(isRefresh: true, clearOnStart: true),
      loadStatusSummary(),
    ]);
  }

  Future<void> loadStatusSummary() async {
    if (getRequestStatusSummaryUseCase == null) return;
    try {
      isLoadingSummary.value = true;
      final summary = await getRequestStatusSummaryUseCase!(
        networkId: selectedNetworkId.value,
      );
      statusSummary.value = summary;
    } catch (_) {
      // Fallback gracefully
    } finally {
      isLoadingSummary.value = false;
    }
  }

  /// جلب الشبكات المعتمدة التابعة لمشغل الشبكة
  Future<void> loadAuthorizedNetworks() async {
    if (getMyNetworksUseCase == null) return;
    try {
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);
      if (selectedNetworkId.value == null) {
        final networkIds = networks
            .map((n) => n.networkId)
            .toList(growable: false);
        final resolvedId = Get.isRegistered<WorkspaceService>()
            ? WorkspaceService.to.resolveActiveNetworkId(networkIds)
            : (networks.length == 1 ? networks.first.networkId : null);
        if (resolvedId != null) {
          selectedNetworkId.value = resolvedId;
          if (Get.isRegistered<WorkspaceService>()) {
            await WorkspaceService.to.saveActiveNetworkId(resolvedId);
          }
        }
      }
    } catch (_) {
      // Non-fatal
    }
  }

  /// تحميل طلبات التوريد الواردة من نقاط البيع
  Future<void> loadRequests({
    bool isRefresh = false,
    bool clearOnStart = false,
  }) async {
    final revision = ++_requestListRevision;
    if (clearOnStart || requests.isEmpty) {
      requests.clear();
    }
    isLoading.value = true;
    errorMessage.value = null;
    nextCursor.value = null;
    isLoadingMore.value = false;

    final networkId = selectedNetworkId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    final effectiveSearch = query.isEmpty ? null : query;

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        networkId: networkId,
        status: status,
        search: effectiveSearch,
        cursor: null,
      );
      if (revision != _requestListRevision) return;

      requests.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (error) {
      if (revision != _requestListRevision) return;
      errorMessage.value = error is AppException
          ? error.message
          : 'تعذر تحميل قائمة طلبات التوريد الواردة: $error';
    } finally {
      if (revision == _requestListRevision) {
        isLoading.value = false;
      }
    }
  }

  /// تحميل المزيد مع منع الصفحات المتأخرة من تلويث نتائج فلتر أحدث.
  @override
  Future<void> loadMoreRequests() async {
    final cursor = nextCursor.value;
    if (isLoadingMore.value || isLoading.value || cursor == null) {
      return;
    }

    final revision = _requestListRevision;
    final networkId = selectedNetworkId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    final effectiveSearch = query.isEmpty ? null : query;
    isLoadingMore.value = true;

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        networkId: networkId,
        status: status,
        search: effectiveSearch,
        cursor: cursor,
      );
      if (revision != _requestListRevision) return;

      final existingIds = requests.map((request) => request.requestId).toSet();
      final newItems = result.items
          .where((request) => !existingIds.contains(request.requestId))
          .toList(growable: false);

      requests.addAll(newItems);
      nextCursor.value = result.nextCursor;
      loadMoreError.value = null;
    } catch (error) {
      if (revision == _requestListRevision) {
        loadMoreError.value = AppException.sanitizeMessage(
          error,
          fallback: 'تعذر تحميل المزيد من طلبات التوريد.',
        );
      }
    } finally {
      if (revision == _requestListRevision) {
        isLoadingMore.value = false;
      }
    }
  }

  /// تغيير فلتر الحالة
  @override
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  /// إعادة تعيين الفلاتر والبحث
  @override
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  /// تغيير الشبكة المحددة
  Future<void> onNetworkFilterChanged(int? networkId) async {
    // CustomDropdown updates its ValueNotifier before invoking onChanged.
    // Always refresh here; comparing the current value would skip the request.
    selectedNetworkId.value = networkId;
    if (networkId != null && Get.isRegistered<WorkspaceService>()) {
      await WorkspaceService.to.saveActiveNetworkId(networkId);
    }
    await Future.wait([
      loadRequests(isRefresh: true, clearOnStart: true),
      loadStatusSummary(),
    ]);
  }

  /// مراجعة واعتماد طلب الكروت وتوليد الفاتورة آلياً
  Future<void> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) async {
    try {
      isProcessingDecision.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري اعتماد الطلب وتوليد فاتورة المبيعات...',
      );
      final approvalResult = await approveRequestUseCase(
        requestId,
        requestNote: requestNote,
        items: items,
      );
      lastApprovalResult.value = approvalResult;

      final approvedRequest = approvalResult.request;
      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = approvedRequest;
      }

      clearModificationEditor();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد الطلب وتوليد الفاتورة والتسوية بنجاح',
      );
      Get.back<void>();

      if (Get.context != null) {
        await CustomBottomSheet.show<void>(
          title: 'اكتمل اعتماد الطلب',
          subtitle: 'نتيجة الفاتورة كما أعادها الخادم',
          leadingIcon: Icons.receipt_long_rounded,
          scrollable: true,
          child: RequestApprovalResultSheet(result: approvalResult),
          stickyFooter: Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إغلاق',
                  onPressed: () => Get.back<void>(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.primary(
                  text: 'فتح الفاتورة',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () {
                    Get.back<void>();
                    Get.toNamed<void>(
                      AppRoutes.saleInvoiceDetails,
                      arguments: approvalResult.invoice.invoiceId,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'فشل اعتماد الطلب',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر اعتماد طلب الكروت: $e',
        type: SnackType.error,
      );
    } finally {
      isProcessingDecision.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// رفض طلب الكروت مع توثيق السبب الإلزامي
  Future<void> rejectRequest(int requestId, String rejectionReason) async {
    try {
      if (rejectionReason.trim().isEmpty) {
        CustomSnackbar.show(
          title: 'سبب الرفض إلزامي',
          message: 'يرجى كتابة سبب رفض الطلب لتوثيقه في السجل.',
          type: SnackType.warning,
        );
        return;
      }

      isProcessingDecision.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تسجيل رفض الطلب وتوثيق السبب...',
      );

      final rejected = await rejectRequestUseCase(
        requestId,
        rejectionReason.trim(),
      );

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = rejected;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب الكروت وتوثيق السبب بنجاح',
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'فشل رفض الطلب',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تسجيل رفض الطلب: $e',
        type: SnackType.error,
      );
    } finally {
      isProcessingDecision.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// القيمة الإجمالية المعتمدة لبند مسودة التعديل إن كان متطابقاً مع آخر معاينة
  double? authoritativeTotalForModificationLine(
    RequestModificationLineEntity line,
  ) {
    final previewItem = currentPreview.value?.items.firstWhereOrNull(
      (item) => item.packageId == line.packageId,
    );
    if (previewItem != null && previewItem.voucherCount == line.voucherCount) {
      return previewItem.itemTotalAmount;
    }
    return null;
  }

  /// فتح الفاتورة المرتبطة بالطلب
  @override
  Future<void> openInvoice(int invoiceId) async {
    await Get.toNamed<void>(AppRoutes.saleInvoiceDetails, arguments: invoiceId);
  }

  /// فتح تفاصيل طلب التوريد
  @override
  Future<void> openRequestDetails(RequestEntity request) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: request,
    );
  }

  /// فتح شاشة تعديل طلب التوريد
  Future<void> openModificationSheet(RequestEntity request) async {
    if (!request.isPending) return;

    unawaited(beginModification(request));

    await CustomBottomSheet.show<void>(
      title: 'مراجعة طلب ${request.displayReference}',
      subtitle: 'عدّل كميات الباقات أو أضف باقات جديدة، ثم قم بمعاينة الأسعار قبل الاعتماد.',
      leadingIcon: Icons.edit_note_rounded,
      scrollable: true,
      maxHeightFactor: 0.94,
      stickyFooter: const NetworkRequestModificationFooter(),
      child: const NetworkRequestModificationSheet(),
    );
    clearModificationEditor();
  }

  /// حوار اعتماد طلب التوريد
  Future<void> promptApproveRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showApprovalDialog(
      requestUuid: request.requestUuid ?? '-',
      onConfirm: (note) => approveRequest(
        request.requestId,
        requestNote: note,
      ),
    );
  }

  /// حوار رفض طلب التوريد
  Future<void> promptRejectRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showRejectionDialog(
      requestUuid: request.requestUuid ?? '-',
      onConfirm: (reason) => rejectRequest(request.requestId, reason),
    );
  }

  /// تأكيد واعتماد التعديل بعد المعاينة
  Future<void> confirmAndApproveModification() async {
    final preview = currentPreview.value;
    if (preview == null || !preview.hasModifications) return;

    await CustomBottomSheet.showConfirmation<void>(
      title: 'تأكيد اعتماد التعديل',
      message: 'سيتم اعتماد البنود المعروضة في آخر معاينة وإنشاء الفاتورة وفق أسعار النظام المعتمدة. لا يمكن تعديل الطلب بعد اعتماده.',
      confirmLabel: 'اعتماد وإنشاء الفاتورة',
      onConfirm: () async {
        await approvePreview(
          requestNote: modificationNoteController.text.trim().isEmpty
              ? null
              : modificationNoteController.text.trim(),
        );
        // if (success) Get.back<void>();
      },
    );
  }
}
