import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم مراجعة واعتماد طلبات التوريد لمشغلي الشبكة (Network Procurement Review Controller)
class NetworkProcurementReviewController extends GetxController {
  final GetRequestsUseCase getRequestsUseCase;
  final ApproveRequestUseCase approveRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  NetworkProcurementReviewController({
    required this.getRequestsUseCase,
    required this.approveRequestUseCase,
    required this.rejectRequestUseCase,
    this.getMyNetworksUseCase,
  });

  // State: قائمة طلبات التوريد الواردة والترقيم
  final requests = <RequestEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isProcessingDecision = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  // فلاتر وبحث الطلبات
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString(); // null = all, PENDING, APPROVED, REJECTED
  final selectedNetworkId = RxnInt();

  // شبكات المشغل التابعة
  final authorizedNetworks = <NetworkEntity>[].obs;

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
      if (selectedNetworkId.value == null && networks.length == 1) {
        selectedNetworkId.value = networks.first.networkId;
      }
    } catch (_) {
      // Non-fatal
    }
  }

  /// تحميل طلبات التوريد الواردة من نقاط البيع
  Future<void> loadRequests({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;

    if (isRefresh) {
      nextCursor.value = null;
    }

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        networkId: selectedNetworkId.value,
        status: statusFilter.value,
        search: effectiveSearch,
        cursor: null,
      );

      requests.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      errorMessage.value = e is AppException
          ? e.message
          : 'تعذر تحميل قائمة طلبات التوريد الواردة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد من الطلبات عند التمرير
  Future<void> loadMoreRequests() async {
    if (isLoadingMore.value || isLoading.value || nextCursor.value == null) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        networkId: selectedNetworkId.value,
        status: statusFilter.value,
        search: effectiveSearch,
        cursor: nextCursor.value,
      );

      final existingIds = requests.map((r) => r.requestId).toSet();
      final newItems =
          result.items.where((r) => !existingIds.contains(r.requestId)).toList();

      requests.addAll(newItems);
      nextCursor.value = result.nextCursor;
    } catch (_) {
      // Non-fatal
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// تغيير فلتر الحالة
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true);
  }

  /// تغيير الشبكة المحددة
  void onNetworkFilterChanged(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    loadRequests(isRefresh: true);
  }

  /// مراجعة واعتماد طلب الكروت وتوليد الفاتورة آلياً
  Future<bool> approveRequest(
    int requestId, {
    String? requestNote,
  }) async {
    isProcessingDecision.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري اعتماد الطلب وتوليد فاتورة المبيعات...',
    );

    try {
      final approved = await approveRequestUseCase(
        requestId,
        requestNote: requestNote,
      );

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = approved;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد الطلب وتوليد الفاتورة والتسوية بنجاح',
      );
      CustomSnackbar.show(
        title: 'نجاح الاعتماد',
        message: 'تم اعتماد الطلب رقم #${approved.requestId} وتوليد فاتورة المبيعات.',
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
  Future<bool> rejectRequest(
    int requestId,
    String rejectionReason,
  ) async {
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
}

