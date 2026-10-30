import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_sale_invoice_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/update_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/delete_voucher_request_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم مركز العمليات والمبيعات (OperationsController)
/// ============================================================================
/// يدير حالة التبديل بين فواتير المبيعات وطلبات الكروت، التصفية والبحث اللحظي،
/// واستدعاء حالات الاستخدام المعتمدة وفق قواعد الكود النظيف.
class OperationsController extends GetxController {
  final GetSaleInvoicesUseCase getSaleInvoicesUseCase;
  final GetVoucherRequestsUseCase getVoucherRequestsUseCase;
  final GetSaleInvoiceDetailsUseCase getSaleInvoiceDetailsUseCase;
  final GetVoucherRequestDetailsUseCase getVoucherRequestDetailsUseCase;
  final ApproveVoucherRequestUseCase approveVoucherRequestUseCase;
  final RejectVoucherRequestUseCase rejectVoucherRequestUseCase;
  final CancelVoucherRequestUseCase cancelVoucherRequestUseCase;
  final CreateVoucherRequestUseCase createVoucherRequestUseCase;
  final CreateSaleInvoiceUseCase createSaleInvoiceUseCase;
  final UpdateVoucherRequestUseCase updateVoucherRequestUseCase;
  final DeleteVoucherRequestUseCase deleteVoucherRequestUseCase;

  OperationsController({
    required this.getSaleInvoicesUseCase,
    required this.getVoucherRequestsUseCase,
    required this.getSaleInvoiceDetailsUseCase,
    required this.getVoucherRequestDetailsUseCase,
    required this.approveVoucherRequestUseCase,
    required this.rejectVoucherRequestUseCase,
    required this.cancelVoucherRequestUseCase,
    required this.createVoucherRequestUseCase,
    required this.createSaleInvoiceUseCase,
    required this.updateVoucherRequestUseCase,
    required this.deleteVoucherRequestUseCase,
  });

  /// القطاع النشط: 0 لفواتير المبيعات، 1 لطلبات الكروت
  final RxInt activeSegmentIndex = 0.obs;

  /// حالات فواتير المبيعات
  final RxList<SaleInvoiceEntity> invoices = <SaleInvoiceEntity>[].obs;
  final RxBool isLoadingInvoices = false.obs;
  final RxString invoicesErrorMessage = ''.obs;
  final RxString selectedInvoiceFilter = 'ALL'.obs; // ALL, CASH, CREDIT, UNPAID

  /// حالات طلبات توريد الكروت
  final RxList<VoucherRequestEntity> requests = <VoucherRequestEntity>[].obs;
  final RxBool isLoadingRequests = false.obs;
  final RxString requestsErrorMessage = ''.obs;
  final RxString selectedRequestFilter = 'ALL'.obs; // ALL, PENDING, APPROVED, REJECTED

  /// حالة تنفيذ إجراء الاعتماد أو الرفض
  final RxBool isSubmittingAction = false.obs;

  final Rx<SaleInvoiceEntity?> selectedInvoice = Rx<SaleInvoiceEntity?>(null);
  final RxBool isLoadingInvoiceDetails = false.obs;
  final RxString invoiceDetailsError = ''.obs;

  final Rx<VoucherRequestEntity?> selectedRequest = Rx<VoucherRequestEntity?>(null);
  final RxBool isLoadingRequestDetails = false.obs;
  final RxString requestDetailsError = ''.obs;

  /// معرف الفاتورة الموسعة حالياً في السجل المالي (حصري — كرت واحد فقط مفتوح في الوقت الواحد)
  final RxnInt expandedInvoiceId = RxnInt();

  /// تبديل حالة توسيع بنود الفاتورة حصرياً
  void toggleInvoiceExpansion(int invoiceId) {
    if (expandedInvoiceId.value == invoiceId) {
      expandedInvoiceId.value = null;
    } else {
      expandedInvoiceId.value = invoiceId;
    }
  }

  /// معرف طلب التوريد الموسع حالياً في السجل (حصري — كرت واحد فقط مفتوح في الوقت الواحد)
  final RxnInt expandedRequestId = RxnInt();

  /// تبديل حالة توسيع بنود طلب التوريد حصرياً
  void toggleRequestExpansion(int requestId) {
    if (expandedRequestId.value == requestId) {
      expandedRequestId.value = null;
    } else {
      expandedRequestId.value = requestId;
    }
  }

  /// حقل البحث الموحد ومؤقت التهدئة
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  /// حقل إدخال سبب الرفض المدار في دورة حياة المتحكم لمنع تسرب الذاكرة
  final TextEditingController rejectReasonController = TextEditingController();

  int? get currentInvoiceId =>
      selectedInvoice.value?.invoiceId ??
      (Get.arguments is int
          ? Get.arguments as int
          : int.tryParse(Get.parameters['id'] ?? ''));

  int? get currentRequestId =>
      selectedRequest.value?.requestId ??
      (Get.arguments is int
          ? Get.arguments as int
          : int.tryParse(Get.parameters['id'] ?? ''));

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    loadRequests();

    final route = Get.currentRoute;
    if (route == AppRoutes.saleInvoiceDetails && currentInvoiceId != null) {
      loadInvoiceDetails(currentInvoiceId!);
    } else if (route == AppRoutes.voucherRequestDetails &&
        currentRequestId != null) {
      loadRequestDetails(currentRequestId!);
    }
  }

  void openInvoiceDetails(int id) {
    loadInvoiceDetails(id);
    Get.toNamed(AppRoutes.saleInvoiceDetails, arguments: id);
  }

  void openRequestDetails(int id) {
    loadRequestDetails(id);
    Get.toNamed(AppRoutes.voucherRequestDetails, arguments: id);
  }

  Future<void> refreshCurrentInvoice() async {
    final id = currentInvoiceId;
    if (id != null) {
      await loadInvoiceDetails(id);
    }
  }

  Future<void> refreshCurrentRequest() async {
    final id = currentRequestId;
    if (id != null) {
      await loadRequestDetails(id);
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    rejectReasonController.dispose();
    super.onClose();
  }

  /// التبديل بين فواتير المبيعات وطلبات الكروت
  void changeSegment(int index) {
    if (activeSegmentIndex.value != index) {
      activeSegmentIndex.value = index;
    }
  }

  /// جلب فواتير مبيعات الكروت
  Future<void> loadInvoices({bool isRefresh = false}) async {
    isLoadingInvoices.value = true;
    invoicesErrorMessage.value = '';

    try {
      final String? saleTypeParam;
      if (selectedInvoiceFilter.value == 'CASH' ||
          selectedInvoiceFilter.value == 'CREDIT') {
        saleTypeParam = selectedInvoiceFilter.value;
      } else {
        saleTypeParam = null;
      }

      final result = await getSaleInvoicesUseCase(
        saleType: saleTypeParam,
        search: searchController.text.trim(),
      );

      // تطبيق تصفية الفواتير غير المسددة محلياً إن اختيرت
      if (selectedInvoiceFilter.value == 'UNPAID') {
        invoices.value = result.where((inv) => !inv.isFullyPaid).toList();
      } else {
        invoices.value = result;
      }
    } catch (e) {
      invoicesErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: invoicesErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingInvoices.value = false;
    }
  }

  /// جلب طلبات توريد الكروت
  Future<void> loadRequests({bool isRefresh = false}) async {
    isLoadingRequests.value = true;
    requestsErrorMessage.value = '';

    try {
      final String? statusParam;
      if (selectedRequestFilter.value != 'ALL') {
        statusParam = selectedRequestFilter.value;
      } else {
        statusParam = null;
      }

      final result = await getVoucherRequestsUseCase(
        status: statusParam,
        search: searchController.text.trim(),
      );

      requests.value = result;
    } catch (e) {
      requestsErrorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: requestsErrorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingRequests.value = false;
    }
  }

  /// تطبيق فلتر نوع الفاتورة
  void filterInvoices(String filter) {
    if (selectedInvoiceFilter.value != filter) {
      selectedInvoiceFilter.value = filter;
      loadInvoices();
    }
  }

  /// تطبيق فلتر حالة طلب الكروت
  void filterRequests(String filter) {
    if (selectedRequestFilter.value != filter) {
      selectedRequestFilter.value = filter;
      loadRequests();
    }
  }

  /// تنفيذ البحث الحي بتهدئة تلقائية تمنع الحمل الزائد وتظهر الـ Shimmer فورياً
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppMotion.slow, () {
      if (activeSegmentIndex.value == 0) {
        loadInvoices();
      } else {
        loadRequests();
      }
    });
  }

  /// تنفيذ البحث عند تقديم النص
  void onSearchSubmitted(String _) {
    _searchDebounceTimer?.cancel();
    if (activeSegmentIndex.value == 0) {
      loadInvoices();
    } else {
      loadRequests();
    }
  }

  /// مسح نص البحث
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    searchController.clear();
    if (activeSegmentIndex.value == 0) {
      loadInvoices();
    } else {
      loadRequests();
    }
  }

  /// اعتماد طلب توريد الكروت
  Future<void> approveRequest(int id, {String? notes}) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري اعتماد الطلب وتوليد الفاتورة...');
      final updated = await approveVoucherRequestUseCase(id, notes: notes);

      final index = requests.indexWhere((r) => r.requestId == id);
      if (index != -1) {
        requests[index] = updated;
      }
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = updated;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم اعتماد طلب الكروت وتوليد الفاتورة بنجاح',
      );

      // تحديث قائمة الفواتير لظهور الفاتورة المولدة حديثاً
      loadInvoices(isRefresh: true);
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر اعتماد الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// رفض طلب توريد الكروت
  Future<void> rejectRequest(int id, {String? reason}) async {
    isSubmittingAction.value = true;
    final finalReason = (reason != null && reason.trim().isNotEmpty)
        ? reason.trim()
        : (rejectReasonController.text.trim().isNotEmpty
            ? rejectReasonController.text.trim()
            : 'مرفوض من قبل الإدارة');

    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري رفض طلب التوريد...');
      final updated = await rejectVoucherRequestUseCase(id, reason: finalReason);

      final index = requests.indexWhere((r) => r.requestId == id);
      if (index != -1) {
        requests[index] = updated;
      }
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = updated;
      }

      rejectReasonController.clear();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم رفض طلب توريد الكروت بنجاح',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر رفض الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إحصائيات المؤشرات السريعة (Operations Mini KPIs)
  Future<void> loadInvoiceDetails(int id) async {
    isLoadingInvoiceDetails.value = true;
    invoiceDetailsError.value = '';
    try {
      selectedInvoice.value = await getSaleInvoiceDetailsUseCase(id);
    } catch (e) {
      invoiceDetailsError.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingInvoiceDetails.value = false;
    }
  }

  Future<void> loadRequestDetails(int id) async {
    isLoadingRequestDetails.value = true;
    requestDetailsError.value = '';
    try {
      selectedRequest.value = await getVoucherRequestDetailsUseCase(id);
    } catch (e) {
      requestDetailsError.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingRequestDetails.value = false;
    }
  }

  Future<void> cancelRequest(int id) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري إلغاء الطلب...');
      final updated = await cancelVoucherRequestUseCase(id);
      final index = requests.indexWhere((r) => r.requestId == id);
      if (index != -1) {
        requests[index] = updated;
      }
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = updated;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء طلب التوريد بنجاح',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// حذف طلب كروت قيد الانتظار أو ملغي
  Future<void> deleteRequest(int id, {String? requestUuid}) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري حذف الطلب...');
      await deleteVoucherRequestUseCase(id);
      requests.removeWhere((r) => r.requestId == id);
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = null;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم حذف طلب الكروت بنجاح',
      );
      if (Get.currentRoute == AppRoutes.voucherRequestDetails) {
        Get.back();
      }
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر حذف الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تعديل طلب كروت قيد الانتظار
  Future<bool> updateRequest(
    int id, {
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? requestNote,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري حفظ تعديلات الطلب...');
      final updated = await updateVoucherRequestUseCase(
        id,
        saleType: saleType,
        items: items,
        requestNote: requestNote,
      );
      final index = requests.indexWhere((r) => r.requestId == id);
      if (index != -1) {
        requests[index] = updated;
      }
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = updated;
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تعديل طلب الكروت بنجاح',
      );
      return true;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر تعديل الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<VoucherRequestEntity?> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري إرسال طلب توريد الكروت...');
      final newRequest = await createVoucherRequestUseCase(
        networkId: networkId,
        posId: posId,
        saleType: saleType,
        items: items,
        requestNote: requestNote,
      );

      requests.insert(0, newRequest);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إرسال طلب توريد الكروت بنجاح',
      );

      return newRequest;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر إرسال الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
      return null;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<SaleInvoiceEntity?> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري إصدار فاتورة المبيعات والتسوية...');
      final newInvoice = await createSaleInvoiceUseCase(
        networkId: networkId,
        posId: posId,
        saleType: saleType,
        items: items,
        paidAmount: paidAmount,
      );

      invoices.insert(0, newInvoice);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إصدار فاتورة المبيعات وتسوية الرصيد بنجاح',
      );

      return newInvoice;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر إصدار الفاتورة',
        message: cleanMessage,
        type: SnackType.error,
      );
      return null;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  // DISPLAY-ONLY aggregation of backend-fetched data (not authoritative; not sent).
  double get totalInvoicesAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.invoiceTotalAmount);

  double get totalPaidAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);

  // DISPLAY-ONLY aggregation of backend-fetched data (not authoritative; not sent).
  double get unpaidRemainingAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.remainingAmount);

  double get totalRequestsAmount =>
      requests.fold(0.0, (sum, req) => sum + req.requestTotalAmount);

  // DISPLAY-ONLY count of backend-fetched requests (not authoritative; not sent).
  int get pendingRequestsCount =>
      requests.where((req) => req.isPending).length;

  int get approvedRequestsCount =>
      requests.where((req) => req.isApproved).length;

  /// تجميع الفواتير بحسب سياق التاريخ عبر DateFormatter الموحد
  Map<String, List<SaleInvoiceEntity>> get groupedInvoices {
    final Map<String, List<SaleInvoiceEntity>> result = {};
    final now = DateTime.now();

    for (final inv in invoices) {
      final dt = DateFormatter.tryParse(inv.invoiceDate ?? inv.createdAt ?? '');

      final String groupKey;
      if (dt == null) {
        groupKey = 'معاملات سابقة';
      } else if (dt.isToday) {
        groupKey = 'اليوم';
      } else if (dt.isYesterday) {
        groupKey = 'أمس';
      } else if (DateFormatter.daysBetween(dt, now).abs() < 7) {
        groupKey = 'هذا الأسبوع';
      } else {
        groupKey = DateFormatter.monthName(dt);
      }

      result.putIfAbsent(groupKey, () => []).add(inv);
    }

    return result;
  }

  /// تجميع طلبات التوريد بحسب سياق التاريخ عبر DateFormatter الموحد
  Map<String, List<VoucherRequestEntity>> get groupedRequests {
    final Map<String, List<VoucherRequestEntity>> result = {};
    final now = DateTime.now();

    for (final req in requests) {
      final dt = DateFormatter.tryParse(req.requestDate ?? req.createdAt ?? '');

      final String groupKey;
      if (dt == null) {
        groupKey = 'طلبات سابقة';
      } else if (dt.isToday) {
        groupKey = 'اليوم';
      } else if (dt.isYesterday) {
        groupKey = 'أمس';
      } else if (DateFormatter.daysBetween(dt, now).abs() < 7) {
        groupKey = 'هذا الأسبوع';
      } else {
        groupKey = DateFormatter.monthName(dt);
      }

      result.putIfAbsent(groupKey, () => []).add(req);
    }

    return result;
  }
}
