import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم فواتير المشتريات لنقطة البيع (POS Purchase Invoices Controller)
class PosInvoicesController extends GetxController {
  final GetPosInvoicesUseCase getPosInvoicesUseCase;

  PosInvoicesController({required this.getPosInvoicesUseCase});

  // State: قائمة فواتير المشتريات والترقيم بالمؤشر
  final invoices = <InvoiceEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  void openInvoiceDetails(InvoiceEntity invoice) {
    Get.toNamed<void>(
      AppRoutes.purchaseInvoiceDetails,
      arguments: invoice,
    );
  }

  // فلاتر البحث ونوع الشراء
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedSaleType = RxnString(); // null = all, CASH, CREDIT

  final Set<int> _invoiceIds = {};
  int _requestIdCounter = 0;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadInvoices(isRefresh: true),
      time: const Duration(milliseconds: 300),
    );

    loadInvoices(isRefresh: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// جلب فواتير مشتريات نقطة البيع
  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      errorMessage.value = null;
      nextCursor.value = null;
    }

    final currentRequestId = ++_requestIdCounter;

    try {
      final activePosId = WorkspaceService.to.savedActivePosId;
      final PaginatedList<InvoiceEntity> result = await getPosInvoicesUseCase(
        posId: activePosId,
        saleType: selectedSaleType.value,
        search: searchQuery.value,
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      // حماية ضد استجابات الطلبات المتأخرة
      if (currentRequestId != _requestIdCounter) return;

      if (isRefresh) {
        _invoiceIds.clear();
        invoices.clear();
      }

      for (final inv in result.items) {
        if (_invoiceIds.add(inv.invoiceId)) {
          invoices.add(inv);
        }
      }

      nextCursor.value = result.nextCursor;
      errorMessage.value = null;
    } on AppException catch (e) {
      if (currentRequestId == _requestIdCounter) {
        errorMessage.value = e.message;
        CustomSnackbar.show(
          title: 'خطأ في جلب الفواتير',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (currentRequestId == _requestIdCounter) {
        errorMessage.value = 'تعذر استرجاع فواتير المشتريات: $e';
      }
    } finally {
      if (currentRequestId == _requestIdCounter) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  /// تحميل الصفحة التالية من الفواتير بالمؤشر
  Future<void> loadMoreInvoices() async {
    if (isLoadingMore.value || !hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    await loadInvoices(isRefresh: false);
  }

  /// تغيير فلتر نوع المعاملة
  void onSaleTypeChanged(String? type) {
    if (selectedSaleType.value == type) return;
    selectedSaleType.value = type;
    loadInvoices(isRefresh: true);
  }

  /// إعادة تعيين الفلاتر
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedSaleType.value = null;
    loadInvoices(isRefresh: true);
  }
}
