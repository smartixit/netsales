import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم فواتير مبيعات الجملة لمشغل الشبكة (Network Wholesale Invoices Controller)
class NetworkInvoicesController extends GetxController {
  final GetNetworkInvoicesUseCase getNetworkInvoicesUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  NetworkInvoicesController({
    required this.getNetworkInvoicesUseCase,
    this.getMyNetworksUseCase,
  });

  // State: قائمة الفواتير والترقيم بالمؤشر
  final invoices = <InvoiceEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  bool get canCreateInvoice =>
      PermissionService.to.can(AppPermissions.salesCreate);

  void navigateToCreateInvoice() {
    Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice);
  }

  void openInvoiceDetails(InvoiceEntity invoice) {
    Get.toNamed<void>(
      AppRoutes.saleInvoiceDetails,
      arguments: invoice,
    );
  }

  // فلاتر البحث ونوع البيع
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedSaleType = RxnString(); // null = all, CASH, CREDIT
  final selectedNetworkId = RxnInt();

  // شبكات المشغل التابعة
  final authorizedNetworks = <NetworkEntity>[].obs;

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

    loadNetworksAndInvoices();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل شبكات المشغل ثم جلب الفواتير
  Future<void> loadNetworksAndInvoices() async {
    if (getMyNetworksUseCase != null) {
      try {
        final networks = await getMyNetworksUseCase!();
        authorizedNetworks.assignAll(networks);
        if (networks.isNotEmpty) {
          selectedNetworkId.value = networks.first.networkId;
        }
      } catch (_) {
        // الاستمرار بدون شبكة محددة ليعتمد الخادم Scoping التلقائي
      }
    }
    await loadInvoices(isRefresh: true);
  }

  /// جلب فواتير مبيعات الجملة
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
            search: searchQuery.value,
            cursor: isRefresh ? null : nextCursor.value,
            perPage: 15,
          );

      // حماية ضد استجابات الطلبات المتأخرة (Stale Request Protection)
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

  /// تحميل الصفحة التالية من الفواتير بالمؤشر (Cursor Load-More)
  Future<void> loadMoreInvoices() async {
    if (isLoadingMore.value || !hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    await loadInvoices(isRefresh: false);
  }

  /// تغيير فلتر نوع البيع
  void onSaleTypeChanged(String? type) {
    if (selectedSaleType.value == type) return;
    selectedSaleType.value = type;
    loadInvoices(isRefresh: true);
  }

  /// تغيير شبكة المشغل
  void onNetworkChanged(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
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
