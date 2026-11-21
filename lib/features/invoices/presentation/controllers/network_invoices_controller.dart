import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/base_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card_actions.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم استعراض وإدارة فواتير مبيعات الجملة في مساحة عمل الشبكة (Network Wholesale Invoices)
class NetworkInvoicesController extends BaseInvoicesController {
  NetworkInvoicesController({
    required this.getNetworkInvoicesUseCase,
    this.invoiceDocumentUseCase,
  });

  final GetNetworkInvoicesUseCase getNetworkInvoicesUseCase;
  final InvoiceDocumentUseCase? invoiceDocumentUseCase;

  @override
  final RxList<InvoiceEntity> invoices = <InvoiceEntity>[].obs;

  @override
  final RxBool isLoading = false.obs;

  @override
  final RxnString errorMessage = RxnString();

  @override
  final RxBool isLoadingMore = false.obs;

  @override
  final RxnString loadMoreError = RxnString();

  @override
  final RxnString paymentStatusFilter = RxnString();

  @override
  final RxnString selectedSaleType = RxnString();

  @override
  final RxString searchQuery = ''.obs;

  @override
  final TextEditingController searchController = TextEditingController();

  @override
  final RxnInt expandedInvoiceId = RxnInt();

  String? _nextCursor;

  @override
  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  int? get activeNetworkId {
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  bool get canCreateDirectInvoice {
    if (Get.isRegistered<PermissionService>()) {
      return PermissionService.instance.can(AppPermissions.salesCreate);
    }
    return true;
  }

  @override
  String get pageTitle => 'فواتير مبيعات الجملة';

  @override
  String get pageSubtitle =>
      'سجل الفواتير الصادرة لمنافذ البيع، متابعة التحصيل، وتدقيق المستحقات المالية فورياً.';

  @override
  IconData get pageIcon => Icons.point_of_sale_rounded;

  @override
  Widget? get headerAction => canCreateDirectInvoice
      ? CustomButton.primary(
          text: 'فاتورة مباشرة',
          icon: Icons.add_rounded,
          shape: AppButtonShape.pill,
          size: AppButtonSize.small,
          onPressed: () =>
              Get.toNamed<void>(AppRoutes.networkCreateSaleInvoice),
        )
      : null;

  @override
  String get searchHint => 'بحث برقم الفاتورة، المعرف، أو اسم نقطة البيع...';

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      final value = searchController.text.trim();
      if (searchQuery.value != value) {
        searchQuery.value = value;
      }
    });

    debounce<String>(searchQuery, (_) {
      loadInvoices(isRefresh: true);
    }, time: const Duration(milliseconds: 350));

    loadInvoices();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getNetworkInvoicesUseCase(
        networkId: activeNetworkId,
        paymentStatus: paymentStatusFilter.value,
        saleType: selectedSaleType.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      invoices.assignAll(result.items);
      _nextCursor = result.nextCursor;
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> loadMoreInvoices() async {
    if (!hasMore || isLoadingMore.value) return;

    isLoadingMore.value = true;
    loadMoreError.value = null;

    try {
      final result = await getNetworkInvoicesUseCase(
        networkId: activeNetworkId,
        paymentStatus: paymentStatusFilter.value,
        saleType: selectedSaleType.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        cursor: _nextCursor,
      );

      final existingIds = invoices.map((e) => e.invoiceId).toSet();
      final newItems = result.items
          .where((e) => !existingIds.contains(e.invoiceId))
          .toList();

      invoices.addAll(newItems);
      _nextCursor = result.nextCursor;
    } catch (e) {
      loadMoreError.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void setPaymentStatusFilter(String? status) {
    if (paymentStatusFilter.value == status) {
      paymentStatusFilter.value = null;
    } else {
      paymentStatusFilter.value = status;
    }
    loadInvoices(isRefresh: true);
  }

  @override
  void onSaleTypeChanged(String? saleType) {
    if (selectedSaleType.value == saleType) {
      selectedSaleType.value = null;
    } else {
      selectedSaleType.value = saleType;
    }
    loadInvoices(isRefresh: true);
  }

  @override
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    paymentStatusFilter.value = null;
    selectedSaleType.value = null;
    loadInvoices(isRefresh: true);
  }

  @override
  void toggleInvoiceExpansion(int invoiceId) {
    if (expandedInvoiceId.value == invoiceId) {
      expandedInvoiceId.value = null;
    } else {
      expandedInvoiceId.value = invoiceId;
    }
  }

  @override
  void openInvoiceDetails(InvoiceEntity invoice) {
    Get.toNamed<void>(
      AppRoutes.saleInvoiceDetails,
      arguments: {'invoice_id': invoice.invoiceId, 'invoice': invoice},
    );
  }

  @override
  Future<void> printInvoice(InvoiceEntity invoice) async {
    try {
      final docUseCase = invoiceDocumentUseCase;
      if (docUseCase != null) {
        await docUseCase.printInvoice(invoice);
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر الطباعة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  @override
  Future<void> shareInvoice(InvoiceEntity invoice) async {
    try {
      final docUseCase = invoiceDocumentUseCase;
      if (docUseCase != null) {
        await docUseCase.shareInvoice(invoice);
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر المشاركة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  @override
  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final paidPres = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      InvoicePaymentStatus.paid,
    );
    final partiallyPaidPres =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.partiallyPaid,
        );
    final unpaidPres = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      InvoicePaymentStatus.unpaid,
    );

    final totalCount = invoices.length;
    final paidCount = invoices.where((inv) => inv.isPaid).length;
    final partialCount = invoices.where((inv) => inv.isPartiallyPaid).length;
    final unpaidCount = invoices.where((inv) => inv.isUnpaid).length;

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: totalCount,
        icon: Icons.all_inbox_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: paidPres.label,
        count: paidCount,
        icon: paidPres.icon ?? Icons.check_circle_outline_rounded,
        accentColor: paidPres.tone.color(context),
        statusKey: InvoicePaymentStatus.paid.wireValue,
      ),
      CustomKpiCardData(
        label: partiallyPaidPres.label,
        count: partialCount,
        icon: partiallyPaidPres.icon ?? Icons.timelapse_rounded,
        accentColor: partiallyPaidPres.tone.color(context),
        statusKey: InvoicePaymentStatus.partiallyPaid.wireValue,
      ),
      CustomKpiCardData(
        label: unpaidPres.label,
        count: unpaidCount,
        icon: unpaidPres.icon ?? Icons.pending_actions_rounded,
        accentColor: unpaidPres.tone.color(context),
        statusKey: InvoicePaymentStatus.unpaid.wireValue,
      ),
    ];
  }

  @override
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    final paidPres = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      InvoicePaymentStatus.paid,
    );
    final partiallyPaidPres =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.partiallyPaid,
        );
    final unpaidPres = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      InvoicePaymentStatus.unpaid,
    );

    return [
      const CustomSearchFilterOption<String?>(
        value: null,
        label: 'كافة الحالات',
      ),
      CustomSearchFilterOption<String?>(
        value: InvoicePaymentStatus.paid.wireValue,
        label: paidPres.label,
        icon: Icons.check_circle_outline_rounded,
      ),
      CustomSearchFilterOption<String?>(
        value: InvoicePaymentStatus.partiallyPaid.wireValue,
        label: partiallyPaidPres.label,
        icon: Icons.timelapse_rounded,
      ),
      CustomSearchFilterOption<String?>(
        value: InvoicePaymentStatus.unpaid.wireValue,
        label: unpaidPres.label,
        icon: Icons.pending_actions_rounded,
      ),
    ];
  }

  @override
  Widget? buildExtraFilters(BuildContext context) {
    return null;
  }

  @override
  Widget buildCardActions(BuildContext context, InvoiceEntity invoice) {
    return InvoiceCardActions(
      invoice: invoice,
      isNetworkPerspective: true,
      onDetails: () => openInvoiceDetails(invoice),
      onPrint: () => printInvoice(invoice),
      onShare: () => shareInvoice(invoice),
    );
  }
}
