import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_status_summary_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/base_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns only the POS procurement request collection and its route navigation.
class PosProcurementOrdersController extends BaseProcurementOrdersController {
  PosProcurementOrdersController({
    required this.getRequestsUseCase,
    required this.getMyPosUseCase,
    required this.cancelRequestUseCase,
    required this.deleteRequestUseCase,
    this.getRequestStatusSummaryUseCase,
  });

  final GetRequestsUseCase getRequestsUseCase;
  final GetMyPosUseCase getMyPosUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final DeleteRequestUseCase deleteRequestUseCase;
  final GetRequestStatusSummaryUseCase? getRequestStatusSummaryUseCase;

  @override
  String get pageTitle => 'طلبات التوريد';

  @override
  String get pageSubtitle =>
      'متابعة وإدارة طلبات كروت الشبكات، حالات الاعتماد، وتفاصيل الكميات فورياً.';

  @override
  IconData get pageIcon => Icons.receipt_long_rounded;

  @override
  Widget? get headerAction => canCreateOrder
      ? CustomButton.primary(
          text: 'طلب توريد جديد +',
          icon: Icons.add_shopping_cart_rounded,
          shape: AppButtonShape.pill,
          size: AppButtonSize.small,
          onPressed: navigateToNewOrder,
        )
      : null;

  @override
  String get searchHint => 'بحث برقم الطلب، المعرف، أو اسم الشبكة...';

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
  Widget? buildExtraFilters(BuildContext context) => null;

  @override
  Widget buildCardActions(BuildContext context, RequestEntity request) {
    return ProcurementOrderCardActions(
      request: request,
      onDetails: () => openRequestDetails(request),
      isNetworkView: false,
      onEdit: (request.isPending && canCreateOrder)
          ? () => openEditOrder(request)
          : null,
      onCancel: (request.isPending && canCancelOrder)
          ? () => promptCancelRequest(request)
          : null,
      onDelete: (request.isCancelled && canCancelOrder)
          ? () => promptDeleteRequest(request)
          : null,
    );
  }

  @override
  final requests = <RequestEntity>[].obs;
  final statusSummary = Rxn<RequestStatusSummaryEntity>();
  @override
  final isLoading = true.obs;
  final isLoadingSummary = false.obs;
  @override
  final isLoadingMore = false.obs;
  @override
  final errorMessage = RxnString();
  @override
  final loadMoreError = RxnString();
  final nextCursor = RxnString();
  final myPosList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();

  @override
  final searchController = TextEditingController();
  @override
  final searchQuery = ''.obs;
  @override
  final statusFilter = RxnString();
  @override
  final RxnInt expandedRequestId = RxnInt();

  int _requestListRevision = 0;

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

  bool get canCreateOrder =>
      PermissionService.to.can(AppPermissions.requestsCreate);

  bool get canCancelOrder =>
      PermissionService.to.can(AppPermissions.requestsEdit);

  @override
  Future<void> refreshOrders() => Future.wait([
    loadRequests(isRefresh: true, clearOnStart: true),
    loadStatusSummary(),
  ]);

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
    loadInitialData();
  }

  @override
  void onClose() {
    _requestListRevision++;
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadMyPos();
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
        posId: selectedPosId.value,
      );
      statusSummary.value = summary;
    } catch (_) {
      // Fallback to local counts gracefully
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> loadMyPos() async {
    try {
      final posList = await getMyPosUseCase();
      myPosList.assignAll(posList);
      selectedPosId.value = WorkspaceService.to.resolveActivePosId(
        posList.map((pos) => pos.posId).toList(growable: false),
      );
    } catch (_) {
      myPosList.clear();
      selectedPosId.value = null;
    }
  }

  Future<void> loadRequests({
    bool isRefresh = false,
    bool clearOnStart = false,
  }) async {
    final revision = ++_requestListRevision;
    if (clearOnStart) {
      requests.clear();
    }
    isLoading.value = true;
    errorMessage.value = null;
    loadMoreError.value = null;
    nextCursor.value = null;
    isLoadingMore.value = false;

    final posId = selectedPosId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: posId,
        status: status,
        search: query.isEmpty ? null : query,
        cursor: null,
      );
      if (revision != _requestListRevision) return;
      requests.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (error) {
      if (revision != _requestListRevision) return;
      errorMessage.value = error is AppException
          ? error.message
          : 'تعذر تحميل قائمة طلبات التوريد: $error';
    } finally {
      if (revision == _requestListRevision) {
        isLoading.value = false;
      }
    }
  }

  @override
  Future<void> loadMoreRequests() async {
    final cursor = nextCursor.value;
    if (isLoadingMore.value || isLoading.value || cursor == null) return;

    final revision = _requestListRevision;
    final posId = selectedPosId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    isLoadingMore.value = true;

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: posId,
        status: status,
        search: query.isEmpty ? null : query,
        cursor: cursor,
      );
      if (revision != _requestListRevision) return;

      final existingIds = requests.map((request) => request.requestId).toSet();
      requests.addAll(
        result.items
            .where((request) => !existingIds.contains(request.requestId))
            .toList(growable: false),
      );
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

  @override
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  @override
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  @override
  void toggleAccordion(int requestId) {
    expandedRequestId.value = expandedRequestId.value == requestId
        ? null
        : requestId;
  }

  Future<void> cancelRequest(int requestId) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إلغاء طلب التوريد...',
      );
      final cancelled = await cancelRequestUseCase(requestId);
      final index = requests.indexWhere(
        (request) => request.requestId == requestId,
      );
      if (index == -1) {
        requests.add(cancelled);
      } else {
        requests[index] = cancelled;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء طلب الكروت بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إلغاء الطلب: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> deleteRequest(int requestId) async {
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري حذف طلب التوريد من السجل...',
      );
      await deleteRequestUseCase(requestId);
      requests.removeWhere((request) => request.requestId == requestId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم حذف طلب التوريد بنجاح',
      );
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر حذف الطلب',
        message: error.message,
        type: SnackType.error,
      );
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية الحذف: $error',
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  @override
  Future<void> openInvoice(int invoiceId) async {
    await Get.toNamed<void>(
      AppRoutes.purchaseInvoiceDetails,
      arguments: invoiceId,
    );
  }

  @override
  Future<void> openRequestDetails(RequestEntity request) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: request,
    );
  }

  Future<void> navigateToNewOrder() async {
    if (Get.isRegistered<PosNewProcurementOrderController>()) {
      await Get.delete<PosNewProcurementOrderController>();
    }
    await Get.toNamed<void>(AppRoutes.newProcurementOrder);
    await loadInitialData();
  }

  Future<void> openEditOrder(RequestEntity request) async {
    if (Get.isRegistered<PosNewProcurementOrderController>()) {
      await Get.delete<PosNewProcurementOrderController>();
    }
    await Get.toNamed<void>(AppRoutes.newProcurementOrder, arguments: request);
    await loadInitialData();
  }

  Future<void> promptCancelRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showCancelDialog(
      requestUuid: request.requestUuid ?? '-',
      onConfirm: () => cancelRequest(request.requestId),
    );
  }

  Future<void> promptDeleteRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showDeleteDialog(
      requestUuid: request.requestUuid ?? '-',
      onConfirm: () => deleteRequest(request.requestId),
    );
  }
}
