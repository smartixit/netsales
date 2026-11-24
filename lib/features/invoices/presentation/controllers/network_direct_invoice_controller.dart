import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
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
/// - إدارة سلة كائنات نموذجية موحدة [DirectInvoiceCartLineEntity] مع دعم الحسابات الورقية.
/// - تثبيت رمز العملة المعروض في واجهة Checkout على (ر.ي).
/// - بحث خادمي متقدم مع Debounce وحماية من الاستجابات المتأخرة عبر تتبع المراجعات (_revision).
/// - دعم الترقيم والتحميل الإضافي للباقات عبر المؤشرات (Cursor Pagination) ومنع التكرار (knownIds).
/// - متحكمات كمية منفصلة للباقات ودوال معيارية [setPackageVoucherCount], [adjustPackageQuantity], [removeCartLine].
/// - قياسات مالية تقديرية دقيقة للخصم النقدي/الآجل، والمقبوض كاش، والمتبقي الآجل.
/// - توليد مفتاح منع التكرار [IdempotencyHelper] المرتبط ببصمة البيانات والمنفذ التجاري.
class NetworkDirectInvoiceController extends GetxController {
  final CreateDirectSaleInvoiceUseCase createDirectSaleInvoiceUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetNetworkPosListUseCase? getNetworkPosListUseCase;

  NetworkDirectInvoiceController({
    required this.createDirectSaleInvoiceUseCase,
    this.getPackagesUseCase,
    this.getNetworkPosListUseCase,
  });

  final formKey = GlobalKey<FormState>();

  // 1. سياق نقاط البيع المرتبطة بالشبكة
  final posLinks = <NetworkPosLinkEntity>[].obs;
  final selectedPosId = RxnInt();
  final isLoadingPosList = false.obs;
  final posErrorMessage = RxnString();
  final expandedInvoiceContext = ''.obs;

  void togglePosContextExpansion() {
    expandedInvoiceContext.value = expandedInvoiceContext.value == 'pos'
        ? ''
        : 'pos';
  }

  bool get isPosContextExpanded => expandedInvoiceContext.value == 'pos';

  NetworkPosLinkEntity? get activePosLink =>
      posLinks.firstWhereOrNull((link) => link.posId == selectedPosId.value);

  NetworkPosLinkEntity? get selectedPosLink => activePosLink;

  // 2. باقات الشبكة والبحث والترقيم الخادمي
  final availablePackages = <PackageEntity>[].obs;
  final selectedPackage = Rxn<PackageEntity>();
  final selectedPackageId = RxnInt();
  final isLoadingPackages = false.obs;
  final isLoadingMorePackages = false.obs;
  final packageSearchController = TextEditingController();
  final packageSearchQuery = ''.obs;
  final packageNextCursor = RxnString();
  final packageErrorMessage = RxnString();
  final packageLoadMoreErrorMessage = RxnString();
  int _lifecycleRevision = 0;
  int _packageRevision = 0;
  bool _suppressPackageSearchListener = false;

  void _setSelectedPackage(PackageEntity? value) {
    selectedPackage.value = value;
    selectedPackageId.value = value?.packageId;
  }

  bool get isSelectedPackageInCart {
    final packageId = selectedPackage.value?.packageId;
    return packageId != null &&
        directInvoiceCart.any((line) => line.package.packageId == packageId);
  }

  // 4. سلة الفاتورة المباشرة ومتحكمات الكمية
  final directInvoiceCart = <DirectInvoiceCartLineEntity>[].obs;
  final Map<int, TextEditingController> _packageQuantityControllers = {};

  TextEditingController quantityControllerForPackage(int packageId) =>
      _packageQuantityControllers.putIfAbsent(
        packageId,
        TextEditingController.new,
      );

  bool get hasCartItems => directInvoiceCart.isNotEmpty;

  // للتوافق مع شاشات العرض القائمة
  List<DirectInvoiceCartLineEntity> get cart => directInvoiceCart;

  // 5. نوع البيع وشروط التسوية
  final selectedSaleType = SaleType.cash.obs;
  final paidAmountController = TextEditingController();
  final paidAmount = 0.0.obs;

  int get selectedSaleTypeIndex =>
      selectedSaleType.value == SaleType.cash ? 0 : 1;

  void setSaleTypeIndex(int index) {
    selectedSaleType.value = index == 0 ? SaleType.cash : SaleType.credit;
  }

  // 6. حالة الإرسال وبصمة مفتاح منع التكرار (Idempotency)
  final isSubmitting = false.obs;
  String? _pendingCreatePayloadSignature;
  String? _pendingCreateIdempotencyKey;

  String _resolveCreateIdempotencyKey(Map<String, dynamic> payload) {
    final signature = jsonEncode(payload);
    if (_pendingCreatePayloadSignature != signature ||
        _pendingCreateIdempotencyKey == null) {
      _pendingCreatePayloadSignature = signature;
      _pendingCreateIdempotencyKey = IdempotencyHelper.forSaleInvoice(
        selectedPosId.value,
      );
    }
    return _pendingCreateIdempotencyKey!;
  }

  void _clearPendingCreateIdempotencyKey() {
    _pendingCreatePayloadSignature = null;
    _pendingCreateIdempotencyKey = null;
  }

  int? get activeNetworkId {
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  /// عدد الباقات المختلفة المختارة في السلة
  int get cartPackagesCount => directInvoiceCart.length;

  /// إجمالي عدد الكروت في سلة الفاتورة
  int get checkoutTotalVouchers =>
      directInvoiceCart.fold<int>(0, (sum, line) => sum + line.voucherCount);

  /// رمز العملة الثابت المعروض في Checkout
  String get checkoutCurrency => 'ر.ي';

  /// إجمالي الفاتورة قبل الخصم وفق بيانات الباقات المحلية
  double get checkoutGrossAmount {
    return directInvoiceCart.fold<double>(
      0.0,
      (sum, line) => sum + line.lineGrossTotal,
    );
  }

  /// إجمالي الخصم بحسب نوع البيع المحدد (يعتمد الخادم سيادياً عند توفره)
  double get checkoutDiscountAmount {
    final isCash = selectedSaleType.value == SaleType.cash;
    return directInvoiceCart.fold<double>(
      0.0,
      (sum, line) => sum + line.lineDiscountTotal(isCash),
    );
  }

  /// صافي الفاتورة التقديري (يعتمد الخادم سيادياً عند توفره)
  double get checkoutNetAmount {
    final net = checkoutGrossAmount - checkoutDiscountAmount;
    return net > 0 ? net : 0.0;
  }

  /// المبلغ المقبوض كاش في البيع الآجل
  double get checkoutPaidAmount {
    if (selectedSaleType.value != SaleType.credit) return 0.0;
    final paid = paidAmount.value;
    final net = checkoutNetAmount;
    return paid > net ? net : paid;
  }

  /// المتبقي الآجل المطلوب قيده كدين على نقطة البيع
  double get checkoutRemainingCreditAmount {
    if (selectedSaleType.value != SaleType.credit) return 0.0;
    final net = checkoutNetAmount;
    final paid = checkoutPaidAmount;
    final remaining = net - paid;
    return remaining > 0 ? remaining : 0.0;
  }

  bool get canSubmitInvoice {
    if (selectedPosId.value == null || !hasCartItems || isSubmitting.value) {
      return false;
    }
    if (selectedSaleType.value == SaleType.credit &&
        paidAmount.value > checkoutNetAmount) {
      return false;
    }
    return true;
  }

  /// الكمية الحالية لباقة معينة في السلة
  int cartQuantityForPackage(int packageId) {
    return directInvoiceCart
            .firstWhereOrNull((line) => line.package.packageId == packageId)
            ?.voucherCount ??
        0;
  }

  /// تعيين كمية كروت محددة لباقة في السلة مع ضبط وحدة التحكم النصية
  void setPackageVoucherCount(PackageEntity package, int voucherCount) {
    final netId = activeNetworkId;
    if (netId != null && package.networkId != netId) {
      CustomSnackbar.show(
        title: 'الباقة لا تتبع الشبكة المحددة',
        message: 'اختر باقة من كتالوج الشبكة الحالية.',
        type: SnackType.error,
      );
      return;
    }

    final safeCount = voucherCount.clamp(0, 1000000);
    final quantityController = quantityControllerForPackage(package.packageId);
    final quantityText = safeCount == 0 ? '' : '$safeCount';
    if (quantityController.text != quantityText) {
      quantityController.value = TextEditingValue(
        text: quantityText,
        selection: TextSelection.collapsed(offset: quantityText.length),
      );
    }

    final existingIndex = directInvoiceCart.indexWhere(
      (line) => line.package.packageId == package.packageId,
    );
    final currentCount = existingIndex == -1
        ? 0
        : directInvoiceCart[existingIndex].voucherCount;
    if (safeCount == currentCount) return;

    if (safeCount == 0) {
      if (existingIndex != -1) {
        directInvoiceCart.removeAt(existingIndex);
        _refreshInvoicePresentation();
      }
      return;
    }

    if (package.packageVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'سعة الباقة غير صالحة',
        message: 'بيانات سعة الباقة غير صالحة لدى الشبكة.',
        type: SnackType.error,
      );
      return;
    }

    final line = DirectInvoiceCartLineEntity(
      package: package,
      voucherCount: safeCount,
      sheets: VoucherSheetCalculator.breakdown(
        safeCount,
        package.packageVoucherCount,
      ).totalSheetsFraction,
    );

    if (existingIndex == -1) {
      directInvoiceCart.add(line);
    } else {
      directInvoiceCart[existingIndex] = line;
    }
    _refreshInvoicePresentation();
  }

  /// تعديل سريع لكمية باقة بزيادة أو إنقاص محدد
  void adjustPackageQuantity(PackageEntity package, int delta) {
    if (delta == 0) return;
    setPackageVoucherCount(
      package,
      cartQuantityForPackage(package.packageId) + delta,
    );
  }

  /// للتوافق العكسي مع واجهات الاستدعاء السابقة
  void incrementQuantity(PackageEntity package) =>
      adjustPackageQuantity(package, 1);
  void decrementQuantity(PackageEntity package) =>
      adjustPackageQuantity(package, -1);

  /// حذف بند محدد من السلة
  void removeCartLine(int packageId) {
    final previousLength = directInvoiceCart.length;
    directInvoiceCart.removeWhere(
      (line) => line.package.packageId == packageId,
    );
    if (directInvoiceCart.length == previousLength) return;
    _refreshInvoicePresentation();
  }

  /// تفريغ السلة بالكامل
  void clearDirectInvoiceCart() {
    directInvoiceCart.clear();
    for (final controller in _packageQuantityControllers.values) {
      controller.clear();
    }
    _clearPendingCreateIdempotencyKey();
    _refreshInvoicePresentation();
  }

  void clearCart() => clearDirectInvoiceCart();

  void _refreshInvoicePresentation() {
    directInvoiceCart.refresh();
  }

  /// اختيار نقطة البيع المستلمة وتحديث الباقات
  Future<void> onPosSelected(int posId) async {
    if (selectedPosId.value == posId) {
      expandedInvoiceContext.value = '';
      return;
    }
    selectedPosId.value = posId;
    expandedInvoiceContext.value = '';
    clearDirectInvoiceCart();
    _setSelectedPackage(null);
    availablePackages.clear();
    await loadPackages();
  }

  void selectPos(int posId) => onPosSelected(posId);

  void onPackageSearchChanged(String value) {
    packageSearchQuery.value = value.trim();
  }

  void clearPackageSearch() {
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    _refreshPackageSearchResults();
  }

  void _refreshPackageSearchResults() {
    final netId = activeNetworkId;
    if (netId != null) {
      _fetchPackages(reset: true);
    }
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

    ever(selectedSaleType, (_) => _refreshInvoicePresentation());

    unawaited(loadInitialData());
  }

  @override
  void onClose() {
    packageSearchController.dispose();
    paidAmountController.dispose();
    for (final controller in _packageQuantityControllers.values) {
      controller.dispose();
    }
    _lifecycleRevision++;
    _packageRevision++;
    isLoadingPackages.value = false;
    isLoadingMorePackages.value = false;
    isLoadingPosList.value = false;
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadPosList(), loadPackages()]);
  }

  /// جلب قائمة نقاط البيع المرتبطة بالشبكة
  Future<void> loadPosList() async {
    final netId = activeNetworkId;
    if (netId == null || getNetworkPosListUseCase == null) return;

    final lifecycleRevision = _lifecycleRevision;
    isLoadingPosList.value = true;
    posErrorMessage.value = null;

    try {
      final paginated = await getNetworkPosListUseCase!(networkId: netId);
      if (lifecycleRevision != _lifecycleRevision) return;
      posLinks.assignAll(paginated.items);
      if (posLinks.isNotEmpty && selectedPosId.value == null) {
        selectedPosId.value = posLinks.first.posId;
      }
    } catch (e) {
      if (lifecycleRevision != _lifecycleRevision) return;
      posErrorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      if (lifecycleRevision == _lifecycleRevision) {
        isLoadingPosList.value = false;
      }
    }
  }

  /// جلب أول صفحة من كتالوج الباقات لنقطة البيع المختارة
  Future<void> loadPackages() async {
    final netId = activeNetworkId;
    if (netId == null) return;
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    packageNextCursor.value = null;
    packageLoadMoreErrorMessage.value = null;
    await _fetchPackages(reset: true);
  }

  /// تحميل المزيد من باقات الكتالوج (Cursor Pagination)
  Future<void> loadMorePackages() async {
    final netId = activeNetworkId;
    if (netId == null) return;
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
        search: packageSearchQuery.value.isEmpty
            ? null
            : packageSearchQuery.value,
        cursor: cursor,
        perPage: 20,
      );

      if (revision != _packageRevision || isClosed) return;

      if (reset) {
        availablePackages.assignAll(paginated.items);
        packageNextCursor.value = paginated.nextCursor;
      } else {
        final knownIds = availablePackages
            .map((item) => item.packageId)
            .toSet();
        availablePackages.addAll(
          paginated.items.where((item) => !knownIds.contains(item.packageId)),
        );
        packageNextCursor.value = paginated.nextCursor;
      }
    } catch (error) {
      if (revision != _packageRevision || isClosed) return;
      final message = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل كتالوج الباقات.',
      );
      if (reset) {
        packageErrorMessage.value = message;
        availablePackages.clear();
        packageNextCursor.value = null;
      } else {
        packageLoadMoreErrorMessage.value = message;
      }
    } finally {
      if (revision == _packageRevision && !isClosed) {
        isLoadingPackages.value = false;
        isLoadingMorePackages.value = false;
      }
    }
  }

  /// إرسال وإصدار الفاتورة المباشرة بعد اكتمال البيانات
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

    final itemsPayload = directInvoiceCart
        .where((line) => line.voucherCount > 0)
        .map(
          (line) => DirectSaleInvoiceItemInputEntity(
            packageId: line.packageId,
            voucherCount: line.voucherCount,
          ),
        )
        .toList(growable: false);

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

      final payloadMap = <String, dynamic>{
        'network_id': netId,
        'pos_id': posId,
        'sale_type': selectedSaleType.value.wireValue,
        'paid_amount':
            selectedSaleType.value == SaleType.credit && paidAmount.value > 0
            ? paidAmount.value
            : null,
        'items': itemsPayload
            .map(
              (item) => {
                'package_id': item.packageId,
                'voucher_count': item.voucherCount,
              },
            )
            .toList(growable: false),
      };

      final idempotencyKey = _resolveCreateIdempotencyKey(payloadMap);

      final createdInvoice = await createDirectSaleInvoiceUseCase(
        networkId: netId,
        posId: posId,
        saleType: selectedSaleType.value,
        items: itemsPayload,
        idempotencyKey: idempotencyKey,
        paidAmount:
            selectedSaleType.value == SaleType.credit && paidAmount.value > 0
            ? paidAmount.value
            : null,
      );

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الفاتورة رقم ${createdInvoice.displayReference}',
      );

      _clearPendingCreateIdempotencyKey();
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
