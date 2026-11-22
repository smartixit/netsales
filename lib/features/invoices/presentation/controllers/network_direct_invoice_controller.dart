import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_cart_line_entity.dart';
import 'package:netsales/features/invoices/domain/entities/direct_sale_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة إصدار فاتورة مبيعات مباشرة لنقطة بيع (NetworkDirectInvoiceController)
///
/// مطابق بنسبة 100% في الهيكلية والمنطق وأسلوب الكود لدورة حياة [PosNewProcurementOrderController]:
/// - إدارة سلة كائنات نموذجية موحدة [DirectInvoiceCartLineEntity].
/// - بحث خادمي متقدم مع Debounce وحماية من الاستجابات المتأخرة عبر الترقيم المعتمد.
/// - دعم الترقيم والتحميل الإضافي للباقات عبر المؤشرات (Cursor Pagination).
/// - متحكمات كمية منفصلة للباقات ودوال معيارية [setPackageVoucherCount], [incrementQuantity], [decrementQuantity].
/// - قياسات مالية تقديرية دقيقة للخصم النقدي/الآجل والصافي التقديري.
class NetworkDirectInvoiceController extends GetxController {
  NetworkDirectInvoiceController({
    required this.createDirectSaleInvoiceUseCase,
    this.getPackagesUseCase,
    this.getNetworkPosListUseCase,
  });

  final CreateDirectSaleInvoiceUseCase createDirectSaleInvoiceUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetNetworkPosListUseCase? getNetworkPosListUseCase;

  final formKey = GlobalKey<FormState>();

  // 1. سياق نقاط البيع المرتبطة بالشبكة
  final posLinks = <NetworkPosLinkEntity>[].obs;
  final selectedPosId = RxnInt();
  final isLoadingPosList = false.obs;
  final posErrorMessage = RxnString();
  final isPosContextExpanded = false.obs;

  // 2. باقات الشبكة والبحث والترقيم الخادمي
  final availablePackages = <PackageEntity>[].obs;
  final isLoadingPackages = false.obs;
  final isLoadingMorePackages = false.obs;
  final packageSearchController = TextEditingController();
  final packageSearchQuery = ''.obs;
  final packageNextCursor = RxnString();
  final packageErrorMessage = RxnString();
  final packageLoadMoreErrorMessage = RxnString();
  int _packageRevision = 0;
  bool _suppressPackageSearchListener = false;

  // 3. سلة الفاتورة المباشرة ومتحكمات الكمية
  final cart = <DirectInvoiceCartLineEntity>[].obs;
  final Map<int, TextEditingController> _packageQuantityControllers = {};

  // 4. نوع البيع (0 = نقدي، 1 = آجل)
  final selectedSaleTypeIndex = 0.obs;

  SaleType get selectedSaleType =>
      selectedSaleTypeIndex.value == 0 ? SaleType.cash : SaleType.credit;

  // 5. الدفعة النقدية المقبوضة كاش في البيع الآجل
  final paidAmountController = TextEditingController();
  final paidAmount = 0.0.obs;

  // 6. حالة الإرسال
  final isSubmitting = false.obs;

  int? get activeNetworkId {
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  NetworkPosLinkEntity? get selectedPosLink =>
      posLinks.firstWhereOrNull((link) => link.posId == selectedPosId.value);

  /// عدد الباقات المختلفة المختارة في السلة
  int get cartPackagesCount => cart.length;

  /// إجمالي عدد الكروت في سلة الفاتورة
  int get checkoutTotalVouchers =>
      cart.fold<int>(0, (sum, line) => sum + line.voucherCount);

  /// عملة التسعير المعتمدة
  String get checkoutCurrency => 'ر.ي';

  /// إجمالي الفاتورة قبل الخصم
  double get checkoutGrossAmount =>
      cart.fold<double>(0.0, (sum, line) => sum + line.lineGrossTotal);

  /// إجمالي الخصم بحسب نوع البيع المحدد
  double get checkoutDiscountAmount {
    final isCash = selectedSaleType == SaleType.cash;
    return cart.fold<double>(
      0.0,
      (sum, line) => sum + line.lineDiscountTotal(isCash),
    );
  }

  /// صافي الفاتورة التقديري
  double get checkoutNetAmount {
    final net = checkoutGrossAmount - checkoutDiscountAmount;
    return net > 0 ? net : 0.0;
  }

  /// المبلغ المقبوض كاش في البيع الآجل
  double get checkoutPaidAmount {
    if (selectedSaleType != SaleType.credit) return 0.0;
    final paid = paidAmount.value;
    final net = checkoutNetAmount;
    return paid > net ? net : paid;
  }

  /// المتبقي الآجل المطلوب قيده كدين على نقطة البيع
  double get checkoutRemainingCreditAmount {
    if (selectedSaleType != SaleType.credit) return 0.0;
    final net = checkoutNetAmount;
    final paid = checkoutPaidAmount;
    final remaining = net - paid;
    return remaining > 0 ? remaining : 0.0;
  }

  bool get canSubmitInvoice {
    if (selectedPosId.value == null ||
        cartPackagesCount <= 0 ||
        isSubmitting.value) {
      return false;
    }
    if (selectedSaleType == SaleType.credit &&
        paidAmount.value > checkoutNetAmount) {
      return false;
    }
    return true;
  }

  /// الحصول على أو إنشاء متحكم كمية للباقة
  TextEditingController quantityControllerForPackage(int packageId) {
    return _packageQuantityControllers.putIfAbsent(
      packageId,
      () {
        final currentCount = cartQuantityForPackage(packageId);
        return TextEditingController(
          text: currentCount > 0 ? '$currentCount' : '',
        );
      },
    );
  }

  /// كمية باقة معينة في السلة حالياً
  int cartQuantityForPackage(int packageId) {
    final line = cart.firstWhereOrNull((l) => l.packageId == packageId);
    return line?.voucherCount ?? 0;
  }

  /// تعيين كمية كروت محددة لباقة في السلة (مطابقة لـ PosNewProcurementOrderController)
  void setPackageVoucherCount(PackageEntity package, int nextQuantity) {
    final clamped = nextQuantity < 0 ? 0 : nextQuantity;
    final index = cart.indexWhere((l) => l.packageId == package.packageId);

    if (clamped == 0) {
      if (index >= 0) cart.removeAt(index);
    } else {
      if (index >= 0) {
        cart[index] = cart[index].copyWith(voucherCount: clamped);
      } else {
        cart.add(
          DirectInvoiceCartLineEntity(
            package: package,
            voucherCount: clamped,
          ),
        );
      }
    }

    final ctrl = _packageQuantityControllers[package.packageId];
    final textValue = clamped > 0 ? '$clamped' : '';
    if (ctrl != null && ctrl.text != textValue) {
      ctrl.text = textValue;
    }
  }

  void incrementQuantity(PackageEntity package) {
    final current = cartQuantityForPackage(package.packageId);
    setPackageVoucherCount(package, current + 1);
  }

  void decrementQuantity(PackageEntity package) {
    final current = cartQuantityForPackage(package.packageId);
    if (current > 0) {
      setPackageVoucherCount(package, current - 1);
    }
  }

  void clearCart() {
    cart.clear();
    for (final ctrl in _packageQuantityControllers.values) {
      ctrl.clear();
    }
  }

  void setSaleTypeIndex(int index) {
    selectedSaleTypeIndex.value = index;
  }

  void selectPos(int posId) {
    if (selectedPosId.value == posId) {
      isPosContextExpanded.value = false;
      return;
    }
    selectedPosId.value = posId;
    isPosContextExpanded.value = false;
    // إعادة جلب الباقات والتعرفات المحدثة الخاصة بنقطة البيع المختارة
    unawaited(loadPackages());
  }

  void togglePosContextExpansion() {
    isPosContextExpanded.value = !isPosContextExpanded.value;
  }

  void onPackageSearchChanged(String query) {
    packageSearchQuery.value = query.trim();
  }

  void clearPackageSearch() {
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    unawaited(_refreshPackageSearchResults());
  }

  Future<void> _refreshPackageSearchResults() async {
    final netId = activeNetworkId;
    if (netId == null) return;
    await _fetchPackages(reset: true);
  }

  @override
  void onInit() {
    super.onInit();
    packageSearchController.addListener(() {
      if (!_suppressPackageSearchListener) {
        packageSearchQuery.value = packageSearchController.text.trim();
      }
    });

    debounce(
      packageSearchQuery,
      (_) => _refreshPackageSearchResults(),
      time: const Duration(milliseconds: 350),
    );

    paidAmountController.addListener(() {
      final parsed = double.tryParse(paidAmountController.text.trim()) ?? 0.0;
      paidAmount.value = parsed >= 0 ? parsed : 0.0;
    });

    unawaited(loadInitialData());
  }

  @override
  void onClose() {
    for (final ctrl in _packageQuantityControllers.values) {
      ctrl.dispose();
    }
    packageSearchController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadPosList(), loadPackages()]);
  }

  Future<void> loadPosList() async {
    final netId = activeNetworkId;
    if (netId == null || getNetworkPosListUseCase == null) return;

    isLoadingPosList.value = true;
    posErrorMessage.value = null;
    try {
      final paginated = await getNetworkPosListUseCase!(networkId: netId);
      posLinks.assignAll(paginated.items);
      if (posLinks.isNotEmpty && selectedPosId.value == null) {
        selectedPosId.value = posLinks.first.posId;
      }
    } catch (e) {
      posErrorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingPosList.value = false;
    }
  }

  Future<void> loadPackages() async {
    await _fetchPackages(reset: true);
  }

  Future<void> loadMorePackages() async {
    await _fetchPackages(reset: false);
  }

  Future<void> _fetchPackages({required bool reset}) async {
    final netId = activeNetworkId;
    if (netId == null || getPackagesUseCase == null) return;

    final revision = reset ? ++_packageRevision : _packageRevision;

    if (reset) {
      isLoadingPackages.value = true;
      packageErrorMessage.value = null;
      packageLoadMoreErrorMessage.value = null;
      packageNextCursor.value = null;
    } else {
      if (isLoadingMorePackages.value ||
          isLoadingPackages.value ||
          packageNextCursor.value == null) {
        return;
      }
      isLoadingMorePackages.value = true;
      packageLoadMoreErrorMessage.value = null;
    }

    final cursor = reset ? null : packageNextCursor.value;

    try {
      final paginated = await getPackagesUseCase!(
        networkId: netId,
        posId: selectedPosId.value,
        status: true,
        search: packageSearchQuery.value.isEmpty ? null : packageSearchQuery.value,
        cursor: cursor,
        perPage: 20,
      );

      if (revision != _packageRevision || isClosed) return;

      if (reset) {
        availablePackages.assignAll(paginated.items);
      } else {
        availablePackages.addAll(paginated.items);
      }
      packageNextCursor.value = paginated.nextCursor;
    } catch (e) {
      if (revision != _packageRevision || isClosed) return;
      final msg = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل باقات الشبكة.',
      );
      if (reset) {
        packageErrorMessage.value = msg;
      } else {
        packageLoadMoreErrorMessage.value = msg;
      }
    } finally {
      if (revision == _packageRevision && !isClosed) {
        isLoadingPackages.value = false;
        isLoadingMorePackages.value = false;
      }
    }
  }

  Future<void> submitDirectInvoice() async {
    if (!canSubmitInvoice) return;

    final netId = activeNetworkId;
    final posId = selectedPosId.value;

    if (netId == null || posId == null) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'يرجى تحديد الشبكة ونقطة البيع المستلمة.',
        type: SnackType.error,
      );
      return;
    }

    final itemsPayload = cart
        .where((line) => line.voucherCount > 0)
        .map(
          (line) => DirectSaleInvoiceItemInputEntity(
            packageId: line.packageId,
            voucherCount: line.voucherCount,
          ),
        )
        .toList();

    if (itemsPayload.isEmpty) {
      CustomSnackbar.show(
        title: 'السلة فارغة',
        message: 'يرجى اختيار باقة واحدة على الأقل وتحديد كميتها.',
        type: SnackType.warning,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إصدار فاتورة المبيعات المباشرة...',
      );

      final idempotencyKey = IdempotencyHelper.forSaleInvoice(posId);

      final createdInvoice = await createDirectSaleInvoiceUseCase(
        networkId: netId,
        posId: posId,
        saleType: selectedSaleType,
        items: itemsPayload,
        idempotencyKey: idempotencyKey,
        paidAmount: selectedSaleType == SaleType.credit && paidAmount.value > 0
            ? paidAmount.value
            : null,
      );

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الفاتورة رقم ${createdInvoice.displayReference}',
      );

      Get.back<void>();
      await Get.toNamed<void>(
        AppRoutes.saleInvoiceDetails,
        arguments: {
          'invoice_id': createdInvoice.invoiceId,
          'invoice': createdInvoice,
        },
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      isSubmitting.value = false;
    }
  }
}
