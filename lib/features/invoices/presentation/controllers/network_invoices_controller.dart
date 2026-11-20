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
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم فواتير مبيعات الجملة لمشغل الشبكة (Network Wholesale Invoices Controller)
///
/// يدير حالة القائمة، الترقيم بالمؤشر، البحث المؤجل، الفلاتر المتعددة،
/// مؤشرات الأداء اللحظية (KPIs)، وتوسيع البطاقات الحصري.
class NetworkInvoicesController extends GetxController {
  final GetNetworkInvoicesUseCase getNetworkInvoicesUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  NetworkInvoicesController({
    required this.getNetworkInvoicesUseCase,
    this.getMyNetworksUseCase,
  });

  // ── الحالة الأساسية والترقيم ──
  final invoices = <InvoiceEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();

  // ── حالة التوسيع الحصرية للبطاقات ──
  final expandedInvoiceId = RxnInt();

  // ── فلاتر البحث والحالة ونوع البيع ──
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();
  final selectedSaleType = RxnString();
  final selectedNetworkId = RxnInt();
  final authorizedNetworks = <NetworkEntity>[].obs;

  final Set<int> _invoiceIds = {};
  int _requestIdCounter = 0;

  bool get hasMore => nextCursor.value != null;

  bool get canCreateInvoice =>
      PermissionService.to.can(AppPermissions.salesCreate);

  // ── مؤشرات الأداء المحسوبة (KPI Counters) ──
  int get totalInvoicesCount => invoices.length;

  int get paidInvoicesCount =>
      invoices.where((i) => i.isPaid).length;

  int get partiallyPaidInvoicesCount =>
      invoices.where((i) => i.isPartiallyPaid).length;

  int get unpaidInvoicesCount =>
      invoices.where((i) => i.isUnpaid).length;

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

    loadNetworksAndInvoices();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// التوسيع أو الطي الحصري لبطاقة الفاتورة
  void toggleInvoiceExpansion(int invoiceId) {
    if (expandedInvoiceId.value == invoiceId) {
      expandedInvoiceId.value = null;
    } else {
      expandedInvoiceId.value = invoiceId;
    }
  }

  /// تعيين فلتر حالة الفاتورة
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) {
      statusFilter.value = null;
    } else {
      statusFilter.value = status;
    }
    loadInvoices(isRefresh: true);
  }

  /// تعيين فلتر نوع المعاملة
  void onSaleTypeChanged(String? type) {
    if (selectedSaleType.value == type) return;
    selectedSaleType.value = type;
    loadInvoices(isRefresh: true);
  }

  /// تغيير فلتر الشبكة
  void onNetworkFilterChanged(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    if (networkId != null) {
      WorkspaceService.to.saveActiveNetworkId(networkId);
    }
    loadInvoices(isRefresh: true);
  }

  /// إعادة تعيين كافة الفلاتر والبحث
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    selectedSaleType.value = null;
    loadInvoices(isRefresh: true);
  }

  /// تحديث قائمة الفواتير
  Future<void> refreshInvoices() => loadInvoices(isRefresh: true);

  /// تحميل شبكات المشغل ثم جلب الفواتير
  Future<void> loadNetworksAndInvoices() async {
    if (getMyNetworksUseCase != null) {
      try {
        final networks = await getMyNetworksUseCase!();
        authorizedNetworks.assignAll(networks);
        final networkIds = networks
            .map((n) => n.networkId)
            .toList(growable: false);
        final resolvedId = WorkspaceService.to.resolveActiveNetworkId(
          networkIds,
        );
        selectedNetworkId.value = resolvedId;
        if (resolvedId != null) {
          await WorkspaceService.to.saveActiveNetworkId(resolvedId);
        }
      } catch (_) {
        // الاستمرار بالاعتماد على التحديد التلقائي من الخادم
      }
    }
    await loadInvoices(isRefresh: true);
  }

  /// جلب فواتير مبيعات الجملة مع حماية الطلبات المتأخرة
  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      errorMessage.value = null;
      nextCursor.value = null;
    }

    final currentRequestId = ++_requestIdCounter;

    try {
      final PaginatedList<InvoiceEntity> result =
          await getNetworkInvoicesUseCase(
            networkId: selectedNetworkId.value,
            saleType: selectedSaleType.value,
            paymentStatus: statusFilter.value,
            search: searchQuery.value,
            cursor: isRefresh ? null : nextCursor.value,
            perPage: 15,
          );

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
        errorMessage.value = 'تعذر استرجاع فواتير المبيعات: $e';
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

  /// الانتقال إلى واجهة إنشاء فاتورة مبيعات مباشرة
  void navigateToCreateInvoice() {
    Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice);
  }

  /// الانتقال إلى واجهة تفاصيل الفاتورة
  void openInvoiceDetails(InvoiceEntity invoice) {
    Get.toNamed<void>(AppRoutes.saleInvoiceDetails, arguments: invoice);
  }
}
