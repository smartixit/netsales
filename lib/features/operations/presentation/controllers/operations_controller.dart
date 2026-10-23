import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
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

  OperationsController({
    required this.getSaleInvoicesUseCase,
    required this.getVoucherRequestsUseCase,
    required this.getSaleInvoiceDetailsUseCase,
    required this.getVoucherRequestDetailsUseCase,
    required this.approveVoucherRequestUseCase,
    required this.rejectVoucherRequestUseCase,
    required this.cancelVoucherRequestUseCase,
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

  /// حقل البحث الموحد
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    loadRequests();
  }

  @override
  void onClose() {
    searchController.dispose();
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
    if (!isRefresh) {
      isLoadingInvoices.value = true;
    }
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
    if (!isRefresh) {
      isLoadingRequests.value = true;
    }
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

  /// تنفيذ البحث عند تقديم النص
  void onSearchSubmitted(String _) {
    if (activeSegmentIndex.value == 0) {
      loadInvoices();
    } else {
      loadRequests();
    }
  }

  /// مسح نص البحث
  void clearSearch() {
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
  Future<void> rejectRequest(int id, {required String reason}) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري رفض طلب التوريد...');
      final updated = await rejectVoucherRequestUseCase(id, reason: reason);

      final index = requests.indexWhere((r) => r.requestId == id);
      if (index != -1) {
        requests[index] = updated;
      }
      if (selectedRequest.value?.requestId == id) {
        selectedRequest.value = updated;
      }

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

  double get totalInvoicesAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.invoiceTotalAmount);

  double get unpaidRemainingAmount =>
      invoices.fold(0.0, (sum, inv) => sum + inv.remainingAmount);

  int get pendingRequestsCount =>
      requests.where((req) => req.isPending).length;
}
