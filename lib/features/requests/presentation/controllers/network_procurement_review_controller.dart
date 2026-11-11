import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/widgets/network_request_modification_sheet.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم مراجعة واعتماد طلبات التوريد لمشغلي الشبكة (Network Procurement Review Controller)
class NetworkProcurementReviewController extends GetxController {
  final GetRequestsUseCase getRequestsUseCase;
  final ApproveRequestUseCase approveRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;
  final PreviewRequestModificationUseCase previewRequestModificationUseCase;
  final GetPackagesUseCase getPackagesUseCase;
  final GetRequestDetailsUseCase getRequestDetailsUseCase;
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
  });

  // State: قائمة طلبات التوريد الواردة والترقيم
  final requests = <RequestEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isProcessingDecision = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  // فلاتر وبحث الطلبات
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString(); // null = all, PENDING, APPROVED, REJECTED
  final selectedNetworkId = RxnInt();

  // شبكات المشغل التابعة
  final authorizedNetworks = <NetworkEntity>[].obs;

  final availablePackages = <PackageEntity>[].obs;
  final isLoadingPackages = false.obs;
  final isPreviewingModification = false.obs;
  final currentPreview = Rxn<RequestModificationPreviewEntity>();
  final modificationLines = <RequestModificationLineEntity>[].obs;
  final editingRequestId = RxnInt();
  final modificationNoteController = TextEditingController();
  int _requestListRevision = 0;

  /// التحقق من صلاحيات مراجعة واعتماد وتعديل طلبات التوريد لمشغل الشبكة
  bool get canApproveRequests =>
      PermissionService.to.can(AppPermissions.requestsApprove);
  bool get canRejectRequests =>
      PermissionService.to.can(AppPermissions.requestsReject);
  bool get canModifyRequests =>
      PermissionService.to.can(AppPermissions.requestsEdit);

  Future<void> beginModification(RequestEntity request) async {
    if (!request.isPending) return;

    final requestId = request.requestId;
    final loadRevision = ++_editorLoadRevision;
    _packageLoadRevision++;
    _modificationRevision++;
    editingRequestId.value = requestId;
    currentPreview.value = null;
    modificationLines.clear();
    availablePackages.clear();

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
      editingRequestId.value = null;
      modificationLines.clear();
      currentPreview.value = null;
      CustomSnackbar.show(
        title: 'تعذر تحميل تفاصيل الطلب',
        message: error is AppException ? error.message : error.toString(),
        type: SnackType.error,
      );
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
    currentPreview.value = null;
  }

  /// زيادة أو إنقاص كمية التعديل بمقدار ورقة كاملة وفق سعة الباقة (Zero Clamp)
  void stepModificationSheet(int packageId, {required bool isIncrement}) {
    final line = modificationLines.firstWhereOrNull((l) => l.packageId == packageId);
    if (line == null) return;
    final package = availablePackages.firstWhereOrNull((p) => p.packageId == packageId);
    final sheetSize = package?.packageVoucherCount ?? 0;
    final step = sheetSize > 0 ? sheetSize : 1;

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

  Future<bool> approvePreview({String? requestNote}) async {
    final preview = currentPreview.value;
    final requestId = editingRequestId.value;
    if (preview == null || requestId == null || !preview.hasModifications) {
      return false;
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
      return false;
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
    currentPreview.value = null;
    modificationLines.clear();
    availablePackages.clear();
    modificationNoteController.clear();
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadRequests(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );

    loadNetworksAndRequests();
  }

  @override
  void onClose() {
    searchController.dispose();
    modificationNoteController.dispose();
    _requestListRevision++;
    super.onClose();
  }

  /// تحميل الشبكات التابعة للمشغل ثم جلب الطلبات الواردة
  Future<void> loadNetworksAndRequests() async {
    await loadAuthorizedNetworks();
    await loadRequests(isRefresh: true);
  }

  /// جلب الشبكات المعتمدة التابعة لمشغل الشبكة
  Future<void> loadAuthorizedNetworks() async {
    if (getMyNetworksUseCase == null) return;
    try {
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);
      if (selectedNetworkId.value == null) {
        final networkIds = networks.map((n) => n.networkId).toList(growable: false);
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
  Future<void> loadRequests({bool isRefresh = false}) async {
    final revision = ++_requestListRevision;
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
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true);
  }

  /// إعادة تعيين الفلاتر والبحث
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadRequests(isRefresh: true);
  }

  /// تغيير الشبكة المحددة
  Future<void> onNetworkFilterChanged(int? networkId) async {
    // CustomDropdown updates its ValueNotifier before invoking onChanged.
    // Always refresh here; comparing the current value would skip the request.
    selectedNetworkId.value = networkId;
    if (networkId != null && Get.isRegistered<WorkspaceService>()) {
      await WorkspaceService.to.saveActiveNetworkId(networkId);
    }
    await loadRequests(isRefresh: true);
  }

  /// مراجعة واعتماد طلب الكروت وتوليد الفاتورة آلياً
  Future<bool> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) async {
    isProcessingDecision.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري اعتماد الطلب وتوليد فاتورة المبيعات...',
    );

    try {
      final approved = await approveRequestUseCase(
        requestId,
        requestNote: requestNote,
        items: items,
      );

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = approved;
      }

      clearModificationEditor();
      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد الطلب وتوليد الفاتورة والتسوية بنجاح',
      );
      CustomSnackbar.show(
        title: 'نجاح الاعتماد',
        message:
            'تم اعتماد الطلب رقم #${approved.requestId} وتوليد فاتورة المبيعات.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل اعتماد الطلب',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر اعتماد طلب الكروت: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isProcessingDecision.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// رفض طلب الكروت مع توثيق السبب الإلزامي
  Future<bool> rejectRequest(int requestId, String rejectionReason) async {
    if (rejectionReason.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'سبب الرفض إلزامي',
        message: 'يرجى كتابة سبب رفض الطلب لتوثيقه في السجل.',
        type: SnackType.warning,
      );
      return false;
    }

    isProcessingDecision.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تسجيل رفض الطلب وتوثيق السبب...',
    );

    try {
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
      CustomSnackbar.show(
        title: 'تم الرفض',
        message: 'تم رفض الطلب رقم #${rejected.requestId} وإشعار نقطة البيع.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل رفض الطلب',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تسجيل رفض الطلب: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isProcessingDecision.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// فتح تفاصيل طلب التوريد
  Future<void> openRequestDetails(RequestEntity request) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: request,
    );
  }

  /// فتح شاشة تعديل طلب التوريد
  Future<void> openModificationSheet(RequestEntity request) async {
    await NetworkRequestModificationSheet.open(request);
  }

  /// حوار اعتماد طلب التوريد
  Future<void> promptApproveRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showApprovalDialog(
      requestId: request.requestId,
      onConfirm: (note) => approveRequest(
        request.requestId,
        requestNote: note,
      ),
    );
  }

  /// حوار رفض طلب التوريد
  Future<void> promptRejectRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showRejectionDialog(
      requestId: request.requestId,
      onConfirm: (reason) => rejectRequest(
        request.requestId,
        reason,
      ),
    );
  }

  /// تأكيد واعتماد التعديل بعد المعاينة
  Future<void> confirmAndApproveModification() async {
    final preview = currentPreview.value;
    if (preview == null || !preview.hasModifications) return;

    await CustomBottomSheet.showConfirmation<void>(
      title: 'تأكيد اعتماد التعديل',
      message:
          'سيتم اعتماد البنود المعروضة في آخر معاينة وإنشاء الفاتورة وفق أسعار النظام المعتمدة. لا يمكن تعديل الطلب بعد اعتماده.',
      confirmLabel: 'اعتماد وإنشاء الفاتورة',
      onConfirm: () async {
        final success = await approvePreview(
          requestNote: modificationNoteController.text.trim().isEmpty
              ? null
              : modificationNoteController.text.trim(),
        );
        if (success) Get.back<void>();
      },
    );
  }
}
