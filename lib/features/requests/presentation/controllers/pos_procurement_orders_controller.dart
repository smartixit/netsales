import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns only the POS procurement request collection and its route navigation.
class PosProcurementOrdersController extends GetxController {
  PosProcurementOrdersController({
    required this.getRequestsUseCase,
    required this.getMyPosUseCase,
    required this.cancelRequestUseCase,
    required this.deleteRequestUseCase,
  });

  final GetRequestsUseCase getRequestsUseCase;
  final GetMyPosUseCase getMyPosUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final DeleteRequestUseCase deleteRequestUseCase;

  final requests = <RequestEntity>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();
  final myPosList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();
  final RxnInt expandedRequestId = RxnInt();

  int _requestListRevision = 0;

  bool get hasMore => nextCursor.value != null;

  int get totalOrdersCount => requests.length;

  int get pendingOrdersCount =>
      requests.where((request) => request.isPending).length;

  int get approvedOrdersCount =>
      requests.where((request) => request.isApproved).length;

  bool get canCreateOrder =>
      PermissionService.to.can(AppPermissions.requestsCreate);

  bool get canCancelOrder =>
      PermissionService.to.can(AppPermissions.requestsEdit);

  Future<void> refreshOrders() =>
      loadRequests(isRefresh: true, clearOnStart: true);

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
    await loadRequests(isRefresh: true, clearOnStart: true);
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

  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadRequests(isRefresh: true, clearOnStart: true);
  }

  void toggleAccordion(int requestId) {
    expandedRequestId.value = expandedRequestId.value == requestId
        ? null
        : requestId;
  }

  Future<bool> cancelRequest(int requestId) async {
    await CustomAnimationOverlay.showLoading(
      message: 'جاري إلغاء طلب التوريد...',
    );

    try {
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
      CustomSnackbar.show(
        title: 'تم الإلغاء',
        message: 'تم إلغاء الطلب رقم #${cancelled.requestUuid} بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إلغاء الطلب: $error',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<bool> deleteRequest(int requestId) async {
    await CustomAnimationOverlay.showLoading(
      message: 'جاري حذف طلب التوريد من السجل...',
    );

    try {
      await deleteRequestUseCase(requestId);
      requests.removeWhere((request) => request.requestId == requestId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم حذف طلب التوريد بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف سجل الطلب بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (error) {
      CustomSnackbar.show(
        title: 'تعذر حذف الطلب',
        message: error.message,
        type: SnackType.error,
      );
      return false;
    } catch (error) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية الحذف: $error',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> openRequestDetails(RequestEntity request) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: request,
    );
  }

  Future<void> navigateToNewOrder() async {
    await Get.toNamed<void>(AppRoutes.newProcurementOrder);
    await loadInitialData();
  }

  Future<void> openEditOrder(RequestEntity request) async {
    await Get.toNamed<void>(AppRoutes.newProcurementOrder, arguments: request);
    await loadInitialData();
  }

  Future<void> promptCancelRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showCancelDialog(
      requestId: request.requestId,
      onConfirm: () => cancelRequest(request.requestId),
    );
  }

  Future<void> promptDeleteRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showDeleteDialog(
      requestId: request.requestId,
      requestUuid: request.requestUuid,
      onConfirm: () => deleteRequest(request.requestId),
    );
  }
}
