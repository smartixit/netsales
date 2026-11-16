import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/update_request_use_case.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة طلبات التوريد والشراء لنقاط البيع (POS Procurement Controller)
class PosProcurementController extends GetxController {
  final GetRequestsUseCase getRequestsUseCase;
  final CreateRequestUseCase createRequestUseCase;
  final UpdateRequestUseCase? updateRequestUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final DeleteRequestUseCase? deleteRequestUseCase;
  final GetMyPosUseCase? getMyPosUseCase;
  final GetPosNetworksListUseCase? getPosNetworksListUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetEffectivePackageDiscountUseCase? getEffectivePackageDiscountUseCase;
  final GetProcurementQuoteUseCase? getProcurementQuoteUseCase;

  PosProcurementController({
    required this.getRequestsUseCase,
    required this.createRequestUseCase,
    this.updateRequestUseCase,
    required this.cancelRequestUseCase,
    this.deleteRequestUseCase,
    this.getMyPosUseCase,
    this.getPosNetworksListUseCase,
    this.getPackagesUseCase,
    this.getEffectivePackageDiscountUseCase,
    this.getProcurementQuoteUseCase,
  });

  // State: قائمة الطلبات والترقيم
  final requests = <RequestEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  /// معرف الطلب المفتوح في الـ Accordion حالياً (الطي الحصري الذكي)
  final RxnInt expandedRequestId = RxnInt();

  /// تبديل فتح/إغلاق الـ Accordion بحيث إذا فتحت بطاقة تُقفل الأخرى تلقائياً
  void toggleAccordion(int requestId) {
    if (expandedRequestId.value == requestId) {
      expandedRequestId.value = null;
    } else {
      expandedRequestId.value = requestId;
    }
  }

  /// حالة وضع التعديل (Edit Mode)
  final isEditing = false.obs;
  final editingRequestId = RxnInt();

  // فلاتر وبحث الطلبات
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString(); // null = all, PENDING, APPROVED, etc.

  // Guided procurement flow: build the request, then review and submit it.
  final currentOrderStep = 0.obs;

  void continueToOrderReview() {
    if (procurementCart.isEmpty) {
      CustomSnackbar.show(
        title: 'الطلب غير مكتمل',
        message: 'أضف باقة واحدة على الأقل قبل الانتقال إلى المراجعة.',
        type: SnackType.warning,
      );
      return;
    }
    currentOrderStep.value = 1;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void returnToOrderItems() {
    currentOrderStep.value = 0;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // State: معالج إنشاء طلب جديد (Wizard Form)
  final formKey = GlobalKey<FormState>();
  final myPosList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();

  /// نقطة البيع النشطة المحددة حالياً
  PosEntity? get activePos =>
      myPosList.firstWhereOrNull((p) => p.posId == selectedPosId.value);

  final linkedNetworks = <NetworkPosLinkEntity>[].obs;
  final selectedNetworkId = RxnInt();
  final isLoadingNetworks = false.obs;

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
  int _packageRevision = 0;
  bool _suppressPackageSearchListener = false;

  // الخصم الفعلي المعتمد للباقة المحددة لنقطة البيع الحالية
  final effectiveDiscount = Rxn<EffectivePackageDiscountEntity>();
  final isLoadingDiscount = false.obs;
  final discountError = RxnString();
  int _discountLoadRevision = 0;

  // عرض الأسعار الرسمي المعتمد سيادياً من الخادم لكامل سلة التوريد (Phase 3.1 Quote)
  final serverQuote = Rxn<ProcurementQuoteEntity>();
  final isLoadingQuote = false.obs;
  final quoteError = RxnString();
  int _quoteRevision = 0;

  final procurementCart = <ProcurementCartLineEntity>[].obs;

  bool get hasCartItems => procurementCart.isNotEmpty;

  /// يمنع إرسال الطلب بعرض سعر قديم أثناء تقارب نقرات الكمية.
  final isQuotePending = false.obs;
  final _cartQuoteChanges = 0.obs;
  Worker? _cartQuoteWorker;

  /// هل يملك الطلب عرض سعر حديثاً يطابق سياق الإرسال الحالي؟
  bool get hasCurrentServerQuote {
    if (getProcurementQuoteUseCase == null) return true;

    final quote = serverQuote.value;
    if (isQuotePending.value || isLoadingQuote.value || quote == null) {
      return false;
    }

    final matchesContext =
        quote.networkId == selectedNetworkId.value &&
        quote.posId == selectedPosId.value &&
        quote.saleType == selectedSaleType.value;
    if (!matchesContext) return false;

    final expiresAt = quote.expiresAt;
    return expiresAt == null || DateTime.now().isBefore(expiresAt);
  }

  bool get canSubmitOrder =>
      hasCartItems && !isSubmitting.value && missingPricingPackageName == null;

  void _setSelectedNetworkId(int? value) {
    selectedNetworkId.value = value;
  }

  void _setSelectedPackage(PackageEntity? value) {
    selectedPackage.value = value;
    selectedPackageId.value = value?.packageId;
  }

  bool get isSelectedPackageInCart {
    final packageId = selectedPackage.value?.packageId;
    return packageId != null &&
        procurementCart.any((line) => line.package.packageId == packageId);
  }

  /// حقل الإدخال بوحدة الكروت المباشرة؛ يحول إلى كروت ويرسل كـ voucher_count إلى Laravel.
  final quantityController = TextEditingController();
  final quantityInput = ''.obs;
  final notesController = TextEditingController();
  final selectedSaleType = SaleType.cash.obs;
  final isSubmitting = false.obs;

  int _requestListRevision = 0;
  String? _pendingCreatePayloadSignature;
  String? _pendingCreateIdempotencyKey;

  String _resolveCreateIdempotencyKey(Map<String, dynamic> payload) {
    final signature = jsonEncode(payload);
    if (_pendingCreatePayloadSignature != signature ||
        _pendingCreateIdempotencyKey == null) {
      _pendingCreatePayloadSignature = signature;
      _pendingCreateIdempotencyKey = IdempotencyHelper.forVoucherRequest(
        selectedNetworkId.value,
      );
    }
    return _pendingCreateIdempotencyKey!;
  }

  void _clearPendingCreateIdempotencyKey() {
    _pendingCreatePayloadSignature = null;
    _pendingCreateIdempotencyKey = null;
  }

  /// التحقق من صلاحيات طلبات التوريد لنقطة البيع
  bool get canCreateOrder =>
      PermissionService.to.can(AppPermissions.requestsCreate);
  bool get canCancelOrder =>
      PermissionService.to.can(AppPermissions.requestsEdit);

  /// سعة الورقة الواحدة للباقة المحددة حالياً.
  int get currentSheetSize => selectedPackage.value?.packageVoucherCount ?? 0;

  /// عدد الكروت المدخل مباشرة.
  int get requestedVoucherCount {
    final count = int.tryParse(quantityInput.value.trim());
    if (count == null || count <= 0) {
      return 0;
    }
    return count;
  }

  /// التحقق من صحة عدد الكروت المدخل بالاعتماد على FormValidators
  String? validateVoucherQuantity(String? value) {
    final formatError = FormValidators.positiveIntegerValidator(
      fieldName: 'عدد الكروت',
      min: 1,
    )(value);
    if (formatError != null) return formatError;

    final package = selectedPackage.value;
    if (package == null) {
      return 'اختر الباقة أولاً لتحديد الطلب.';
    }

    if (package.packageVoucherCount <= 0) {
      return 'سعة الورقة لهذه الباقة غير صالحة. راجع بيانات الباقة لدى الشبكة.';
    }

    return null;
  }

  /// التعيين المباشر لعدد الكروت
  void setVoucherCount(int count) {
    final safeCount = count < 0 ? 0 : count;
    final text = safeCount == 0 ? '' : safeCount.toString();
    quantityController.text = text;
    quantityController.selection = TextSelection.collapsed(
      offset: quantityController.text.length,
    );
    quantityInput.value = text;
  }

  /// الإدخال التراكمي لعدد الكروت (Additive Tapping)
  void addVoucherQuantity(int additionalCount) {
    if (additionalCount <= 0) return;
    final current = requestedVoucherCount;
    setVoucherCount(current + additionalCount);
  }

  /// زيادة ورقة واحدة كاملة وفق سعة الباقة المحددة
  void stepUpSheet() {
    final sheetSize = currentSheetSize;
    if (sheetSize <= 0) {
      addVoucherQuantity(1);
      return;
    }
    addVoucherQuantity(sheetSize);
  }

  /// إنقاص ورقة واحدة كاملة مع حماية من الأرقام السالبة (Zero Clamp)
  void stepDownSheet() {
    final sheetSize = currentSheetSize;
    final current = requestedVoucherCount;
    if (current <= 0) return;

    final decrement = sheetSize > 0 ? sheetSize : 1;
    final target = current - decrement;
    setVoucherCount(target > 0 ? target : 0);
  }

  /// تصفير كمية الكروت بنقرة واحدة
  void clearVoucherQuantity() {
    setVoucherCount(0);
  }

  /// تعيين كمية مبدئية لورقة واحدة عند اختيار الباقة إن كان الحقل فارغاً
  void setDefaultSheetIfEmpty() {
    if (quantityInput.value.trim().isEmpty || requestedVoucherCount == 0) {
      final sheetSize = currentSheetSize;
      if (sheetSize > 0) {
        setVoucherCount(sheetSize);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    packageSearchController.addListener(() {
      if (!_suppressPackageSearchListener) {
        packageSearchQuery.value = packageSearchController.text.trim();
      }
    });
    quantityController.addListener(() {
      quantityInput.value = quantityController.text;
    });

    debounce(
      searchQuery,
      (_) => loadRequests(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      packageSearchQuery,
      (_) => refreshNetworkPackages(),
      time: const Duration(milliseconds: 350),
    );

    // Live pricing is derived locally from signed POS catalogue snapshots.

    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    packageSearchController.dispose();
    quantityController.dispose();
    notesController.dispose();
    _cartQuoteWorker?.dispose();
    _requestListRevision++;
    super.onClose();
  }

  /// تحميل البيانات الأولية لنقاط البيع وقائمة الطلبات
  Future<void> loadInitialData() async {
    await loadMyPos();
    await loadRequests(isRefresh: true);
  }

  /// جلب وتحديد نقطة البيع النشطة التابعة للمستخدم الحالي
  Future<void> loadMyPos() async {
    if (getMyPosUseCase == null) return;
    try {
      final posList = await getMyPosUseCase!();
      myPosList.assignAll(posList);

      final resolvedId = WorkspaceService.to.resolveActivePosId(
        posList.map((p) => p.posId).toList(),
      );

      if (resolvedId != null) {
        selectedPosId.value = resolvedId;
        await loadLinkedNetworks(resolvedId);
      } else {
        selectedPosId.value = null;
        _setSelectedNetworkId(null);
        _setSelectedPackage(null);
        linkedNetworks.clear();
        availablePackages.clear();
      }
    } catch (_) {
      // Non-fatal, handled gracefully
    }
  }

  /// تغيير نقطة البيع النشطة صراحة من واجهة طلب التوريد
  Future<void> onPosSelected(int posId) async {
    if (selectedPosId.value == posId) return;

    final isAuthorized = myPosList.any((p) => p.posId == posId);
    if (!isAuthorized) return;

    selectedPosId.value = posId;
    await WorkspaceService.to.saveActivePosId(posId);

    // تصفير بيانات وسلة وسياق الشبكات والباقات والخصومات السابقة كلياً
    clearProcurementCart();
    _setSelectedPackage(null);
    _setSelectedNetworkId(null);
    effectiveDiscount.value = null;
    discountError.value = null;
    linkedNetworks.clear();
    availablePackages.clear();

    await loadLinkedNetworks(posId);
  }

  /// جلب قائمة الشبكات الموردة المرتبطة بنقطة البيع المحددة
  Future<void> loadLinkedNetworks(int posId) async {
    if (getPosNetworksListUseCase == null) return;

    _setSelectedNetworkId(null);
    _setSelectedPackage(null);
    linkedNetworks.clear();
    availablePackages.clear();
    isLoadingNetworks.value = true;
    isLoadingPackages.value = false;

    try {
      final paginated = await getPosNetworksListUseCase!(posId, status: true);
      if (selectedPosId.value != null && selectedPosId.value != posId) {
        return;
      }

      linkedNetworks.assignAll(paginated.items);
      if (linkedNetworks.length == 1) {
        final networkId = linkedNetworks.first.networkId;
        _setSelectedNetworkId(networkId);
        await loadNetworkPackages(networkId);
      }
    } catch (_) {
      if (selectedPosId.value != null && selectedPosId.value != posId) {
        return;
      }
      linkedNetworks.clear();
      availablePackages.clear();
      _setSelectedNetworkId(null);
      _setSelectedPackage(null);
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// جلب أول صفحة من كتالوج الشبكة مع بحث خادمي وحماية من الاستجابات القديمة.
  Future<void> loadNetworkPackages(int networkId) async {
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    packageNextCursor.value = null;
    packageLoadMoreErrorMessage.value = null;
    await _fetchNetworkPackages(networkId, reset: true);
  }

  Future<void> refreshNetworkPackages() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    await _fetchNetworkPackages(networkId, reset: true);
  }

  Future<void> _fetchNetworkPackages(
    int networkId, {
    required bool reset,
  }) async {
    if (getPackagesUseCase == null) return;
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
    }

    final cursor = reset ? null : packageNextCursor.value;
    try {
      final paginated = await getPackagesUseCase!(
        networkId: networkId,
        posId: selectedPosId.value,
        status: true,
        search: packageSearchQuery.value.isEmpty
            ? null
            : packageSearchQuery.value,
        cursor: cursor,
        perPage: 20,
      );
      if (revision != _packageRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }

      if (reset) {
        availablePackages.assignAll(paginated.items);
        packageNextCursor.value = paginated.nextCursor;
        // Cart quantities are independent from catalogue pagination and search.
        // Loading a catalogue page must never create or replace an order line.
      } else {
        final knownIds = availablePackages.map((item) => item.packageId).toSet();
        availablePackages.addAll(
          paginated.items.where(
            (item) => !knownIds.contains(item.packageId),
          ),
        );
        packageNextCursor.value = paginated.nextCursor;
      }
    } catch (error) {
      if (revision != _packageRevision) return;
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
      if (revision == _packageRevision) {
        isLoadingPackages.value = false;
        isLoadingMorePackages.value = false;
      }
    }
  }

  void onPackageSearchChanged(String value) {
    packageSearchQuery.value = value.trim();
  }

  void clearPackageSearch() {
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    refreshNetworkPackages();
  }

  Future<void> loadMorePackages() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    await _fetchNetworkPackages(networkId, reset: false);
  }

  /// اختيار الشبكة الموردة وتحديث الباقات
  void onNetworkSelected(int networkId) {
    _setSelectedNetworkId(networkId);
    clearProcurementCart();
    _setSelectedPackage(null);
    effectiveDiscount.value = null;
    discountError.value = null;
    availablePackages.clear();
    clearVoucherQuantity();
    loadNetworkPackages(networkId);
  }

  /// الكمية الحالية لباقة؛ السلة هي المصدر الوحيد للحقيقة.
  int cartQuantityForPackage(int packageId) {
    return procurementCart
            .firstWhereOrNull((line) => line.package.packageId == packageId)
            ?.voucherCount ??
        0;
  }

  /// يهيئ محرر الكمية دون التأثير على السلة حتى يضغط المستخدم «تطبيق».
  void preparePackageQuantityEdit(PackageEntity package, int currentCount) {
    _setSelectedPackage(package);
    setVoucherCount(currentCount);
  }

  /// يثبت كمية باقة مباشرة في السلة. الصفر يعني إزالة الباقة.
  void setPackageVoucherCount(PackageEntity package, int voucherCount) {
    if (package.networkId != selectedNetworkId.value) {
      CustomSnackbar.show(
        title: 'الباقة لا تتبع الشبكة المحددة',
        message: 'اختر باقة من كتالوج الشبكة الموردة الحالية.',
        type: SnackType.error,
      );
      return;
    }

    final safeCount = voucherCount < 0 ? 0 : voucherCount;
    final existingIndex = procurementCart.indexWhere(
      (line) => line.package.packageId == package.packageId,
    );
    final currentCount = existingIndex == -1
        ? 0
        : procurementCart[existingIndex].voucherCount;
    if (safeCount == currentCount) return;

    if (safeCount == 0) {
      if (existingIndex != -1) {
        procurementCart.removeAt(existingIndex);
        if (procurementCart.isEmpty) returnToOrderItems();
        _invalidateLocalPricingSnapshot();
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

    final line = ProcurementCartLineEntity(
      package: package,
      sheets: VoucherSheetCalculator.breakdown(
        safeCount,
        package.packageVoucherCount,
      ).totalSheetsFraction,
      voucherCount: safeCount,
    );
    if (existingIndex == -1) {
      procurementCart.add(line);
    } else {
      procurementCart[existingIndex] = line;
    }
    _invalidateLocalPricingSnapshot();
  }

  /// التحكم السريع في الكمية من بطاقة الكتالوج أو بطاقة السلة.
  void adjustPackageQuantity(PackageEntity package, int delta) {
    if (delta == 0) return;
    setPackageVoucherCount(
      package,
      cartQuantityForPackage(package.packageId) + delta,
    );
  }

  /// إبطال أي Quote قديم دون إرسال HTTP؛ إجمالي السلة مشتق محلياً من تعرفة POS.
  void _invalidateLocalPricingSnapshot() {
    _quoteRevision++;
    serverQuote.value = null;
    quoteError.value = null;
    isLoadingQuote.value = false;
    isQuotePending.value = false;
  }

  int _unitPriceMinor(PackageEntity package) =>
      (selectedSaleType.value == SaleType.cash
          ? package.procurementCashUnitPriceMinor
          : package.procurementCreditUnitPriceMinor) ??
      (((selectedSaleType.value == SaleType.cash
                  ? package.effectiveCashPrice
                  : package.effectiveCreditPrice) * 100).round());

  int _lineGrossMinor(ProcurementCartLineEntity line) =>
      (line.package.procurementBaseUnitPriceMinor ??
          (line.package.packageVoucherPrice * 100).round()) * line.voucherCount;

  int _lineDiscountMinor(ProcurementCartLineEntity line) {
    final rate = selectedSaleType.value == SaleType.cash
        ? line.package.procurementCashDiscountBasisPoints
        : line.package.procurementCreditDiscountBasisPoints;
    if (rate == null) return 0;
    final gross = _lineGrossMinor(line);
    return ((gross * rate) + 5000) ~/ 10000;
  }

  /// يطابق قاعدة Laravel: تقريب الخصم على إجمالي البند، لا على سعر الوحدة.
  int get liveOrderGrossMinor =>
      procurementCart.fold<int>(0, (sum, line) => sum + _lineGrossMinor(line));

  int get liveOrderDiscountMinor =>
      procurementCart.fold<int>(0, (sum, line) => sum + _lineDiscountMinor(line));

  int get liveOrderTotalMinor => liveOrderGrossMinor - liveOrderDiscountMinor;

  String? get missingPricingPackageName => procurementCart
      .where((line) => line.package.procurementPricingSnapshotToken == null ||
          (selectedSaleType.value == SaleType.cash
              ? line.package.procurementCashUnitPriceMinor
              : line.package.procurementCreditUnitPriceMinor) == null)
      .map((line) => line.package.packageName)
      .firstOrNull;

  void removeCartLine(int packageId) {
    final previousLength = procurementCart.length;
    procurementCart.removeWhere((line) => line.package.packageId == packageId);
    if (procurementCart.length == previousLength) return;

    if (procurementCart.isEmpty) returnToOrderItems();
    _invalidateLocalPricingSnapshot();
  }

  void clearProcurementCart() {
    procurementCart.clear();
    _quoteRevision++;
    isLoadingQuote.value = false;
    isQuotePending.value = false;
    serverQuote.value = null;
    quoteError.value = null;
    _clearPendingCreateIdempotencyKey();
  }

  /// جلب واحتساب عرض الأسعار الرسمي المعتمد سيادياً من الخادم لبنود السلة وطريقة الدفع المختارة
  Future<void> fetchServerQuote() async {
    final revision = ++_quoteRevision;
    isQuotePending.value = false;
    final networkId = selectedNetworkId.value;
    final posId = selectedPosId.value;
    final items = procurementCart.toList(growable: false);

    if (networkId == null ||
        posId == null ||
        items.isEmpty ||
        getProcurementQuoteUseCase == null) {
      isLoadingQuote.value = false;
      isQuotePending.value = false;
      serverQuote.value = null;
      quoteError.value = null;
      return;
    }

    serverQuote.value = null;
    isLoadingQuote.value = true;
    quoteError.value = null;

    try {
      final payload = <String, dynamic>{
        'network_id': networkId,
        'pos_id': posId,
        'sale_type': selectedSaleType.value.wireValue,
        'items': items
            .map(
              (line) => {
                'package_id': line.package.packageId,
                'voucher_count': line.voucherCount,
              },
            )
            .toList(growable: false),
      };

      final quote = await getProcurementQuoteUseCase!(payload);

      if (revision != _quoteRevision ||
          selectedNetworkId.value != networkId ||
          selectedPosId.value != posId) {
        return;
      }

      serverQuote.value = quote;
    } on AppException catch (e) {
      if (revision != _quoteRevision) return;
      quoteError.value = e.message;
      serverQuote.value = null;
    } catch (e) {
      if (revision != _quoteRevision) return;
      quoteError.value = 'تعذر جلب عرض الأسعار المعتمد: $e';
      serverQuote.value = null;
    } finally {
      if (revision == _quoteRevision) {
        isLoadingQuote.value = false;
      }
    }
  }

  /// تعديل كمية بند موجود في السلة مباشرة دون فتح محرر منفصل.
  void adjustCartLine(int packageId, int delta) {
    final index = procurementCart.indexWhere(
      (line) => line.package.packageId == packageId,
    );
    if (index == -1 || delta == 0) return;
    final line = procurementCart[index];
    final nextCount = line.voucherCount + delta;
    if (nextCount <= 0) {
      removeCartLine(packageId);
      return;
    }
    final sheetSize = line.package.packageVoucherCount;
    if (sheetSize <= 0) return;
    procurementCart[index] = ProcurementCartLineEntity(
      package: line.package,
      sheets: nextCount / sheetSize,
      voucherCount: nextCount,
    );
    _invalidateLocalPricingSnapshot();
  }

  void adjustCartLineBySheet(int packageId, int direction) {
    final line = procurementCart.firstWhereOrNull(
      (item) => item.package.packageId == packageId,
    );
    if (line == null || direction == 0) return;
    adjustCartLine(
      packageId,
      line.package.packageVoucherCount * direction,
    );
  }

  /// واجهة توافقية لقراءة الخصم التفصيلي؛ لا تُستخدم لتحديد كمية الطلب.
  /// كمية الطلب نفسها تُدار حصراً عبر procurementCart.
  void onPackageSelected(PackageEntity package) {
    _setSelectedPackage(package);
    setDefaultSheetIfEmpty();
    unawaited(loadEffectiveDiscount());
  }

  /// استرجاع الخصم الفعلي المعتمد للباقة المحددة لنقطة البيع الحالية من Laravel
  Future<void> loadEffectiveDiscount() async {
    final posId = selectedPosId.value;
    final networkId = selectedNetworkId.value;
    final packageId = selectedPackage.value?.packageId;

    effectiveDiscount.value = null;
    discountError.value = null;

    if (posId == null ||
        networkId == null ||
        packageId == null ||
        getEffectivePackageDiscountUseCase == null) {
      return;
    }

    final revision = ++_discountLoadRevision;
    isLoadingDiscount.value = true;

    try {
      final result = await getEffectivePackageDiscountUseCase!(
        networkId: networkId,
        posId: posId,
        packageId: packageId,
      );

      if (revision != _discountLoadRevision ||
          selectedPosId.value != posId ||
          selectedNetworkId.value != networkId ||
          selectedPackage.value?.packageId != packageId) {
        return;
      }

      effectiveDiscount.value = result;
    } catch (e) {
      if (revision != _discountLoadRevision) return;
      discountError.value = e is AppException ? e.message : e.toString();
    } finally {
      if (revision == _discountLoadRevision) {
        isLoadingDiscount.value = false;
      }
    }
  }

  /// تحميل طلبات التوريد من الخادم مع ترقيم المؤشر
  Future<void> loadRequests({bool isRefresh = false}) async {
    final revision = ++_requestListRevision;
    isLoading.value = true;
    errorMessage.value = null;

    nextCursor.value = null;
    isLoadingMore.value = false;

    final posId = selectedPosId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    final effectiveSearch = query.isEmpty ? null : query;

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: posId,
        status: status,
        search: effectiveSearch,
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

  /// تحميل المزيد دون السماح لاستجابة صفحة قديمة بتلويث نتائج التصفية الحالية.
  Future<void> loadMoreRequests() async {
    final cursor = nextCursor.value;
    if (isLoadingMore.value || isLoading.value || cursor == null) {
      return;
    }

    final revision = _requestListRevision;
    final posId = selectedPosId.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim();
    final effectiveSearch = query.isEmpty ? null : query;
    isLoadingMore.value = true;

    try {
      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: posId,
        status: status,
        search: effectiveSearch,
        cursor: cursor,
      );
      if (revision != _requestListRevision) return;

      final existingIds = requests.map((request) => request.requestId).toSet();
      final newItems = result.items
          .where((request) => !existingIds.contains(request.requestId))
          .toList(growable: false);

      requests.addAll(newItems);
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

  /// تغيير فلتر الحالة وإعادة التحميل من الخادم
  void setStatusFilter(String? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadRequests(isRefresh: true);
  }

  /// إعادة تعيين الفلاتر والبحث
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    loadRequests(isRefresh: true);
  }

  /// تهيئة نموذج طلب جديد
  void initNewOrderForm() {
    currentOrderStep.value = 0;
    isEditing.value = false;
    editingRequestId.value = null;
    clearProcurementCart();
    _setSelectedPackage(null);
    clearVoucherQuantity();
    notesController.clear();
    selectedSaleType.value = SaleType.cash;

    if (linkedNetworks.length == 1) {
      _setSelectedNetworkId(linkedNetworks.first.networkId);
      loadNetworkPackages(linkedNetworks.first.networkId);
    }
  }

  /// فتح شاشة تعديل طلب التوريد القائم المعلق
  Future<void> openEditOrder(RequestEntity request) async {
    isEditing.value = true;
    editingRequestId.value = request.requestId;
    selectedPosId.value = request.posId;
    selectedNetworkId.value = request.networkId;
    selectedSaleType.value = request.saleType;
    notesController.text = request.requestNote ?? '';
    clearProcurementCart();

    await loadNetworkPackages(request.networkId);

    for (final item in request.items) {
      final pkg = availablePackages
              .firstWhereOrNull((p) => p.packageId == item.packageId) ??
          item.voucherPackage ??
          PackageEntity(
            packageId: item.packageId,
            networkId: request.networkId,
            packageName:
                item.voucherPackage?.packageName ?? 'باقة #${item.packageId}',
            packageColor: item.voucherPackage?.packageColor,
            packageBalance: 0.0,
            packageVoucherCount:
                item.voucherPackage?.packageVoucherCount ?? 100,
            packageVoucherPrice: item.voucherPrice,
            packageDefaultCashDiscount: item.itemDiscount,
            packageDefaultCreditDiscount: item.itemDiscount,
            cashDiscountAmount: 0.0,
            creditDiscountAmount: 0.0,
            effectiveCashPrice: item.voucherPrice,
            effectiveCreditPrice: item.voucherPrice,
            status: true,
          );

      final sheetSize =
          pkg.packageVoucherCount > 0 ? pkg.packageVoucherCount : 100;
      final calculatedSheets = item.voucherCount / sheetSize;
      procurementCart.add(
        ProcurementCartLineEntity(
          package: pkg,
          sheets: calculatedSheets,
          voucherCount: item.voucherCount,
        ),
      );
    }

    _invalidateLocalPricingSnapshot();
    await Get.toNamed<void>(AppRoutes.newProcurementOrder);
  }

  /// إرسال تحديثات الطلب المعلق إلى الخادم
  Future<bool> updateOrder() async {
    final requestId = editingRequestId.value;
    if (requestId == null || updateRequestUseCase == null) {
      CustomSnackbar.show(
        title: 'خطأ في عملية التعديل',
        message: 'معرف الطلب المراد تعديله غير متوفر.',
        type: SnackType.error,
      );
      return false;
    }

    if (procurementCart.isEmpty) {
      CustomSnackbar.show(
        title: 'سلة التوريد فارغة',
        message: 'أضف باقة واحدة على الأقل إلى الطلب قبل إرسال التعديل.',
        type: SnackType.warning,
      );
      return false;
    }

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تحديث بيانات طلب التوريد...',
    );

    try {
      final token = serverQuote.value?.pricingToken;
      final payload = <String, dynamic>{
        'sale_type': selectedSaleType.value.wireValue,
        if (token != null && token.isNotEmpty) 'pricing_token': token,
        if (notesController.text.trim().isNotEmpty)
          'request_note': notesController.text.trim(),
        'items': procurementCart
            .map(
              (line) => {
                'package_id': line.package.packageId,
                'voucher_count': line.voucherCount,
              },
            )
            .toList(growable: false),
      };

      final updated = await updateRequestUseCase!(requestId, payload);
      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = updated;
      }

      isEditing.value = false;
      editingRequestId.value = null;
      clearProcurementCart();
      clearVoucherQuantity();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم حفظ تعديلات طلب التوريد بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم التحديث بنجاح',
        message: 'تم تحديث طلب التوريد رقم #${updated.requestUuid} بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل تعديل الطلب',
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
        message: 'تعذر تعديل طلب التوريد: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// حذف طلب توريد ملغي أو معلق من قبل نقطة البيع
  Future<bool> deleteRequest(int requestId) async {
    if (deleteRequestUseCase == null) {
      CustomSnackbar.show(
        title: 'العملية غير مدعومة',
        message: 'خاصية حذف الطلبات غير مهيأة.',
        type: SnackType.error,
      );
      return false;
    }

    await CustomAnimationOverlay.showLoading(
      message: 'جاري حذف طلب التوريد من السجل...',
    );

    try {
      await deleteRequestUseCase!(requestId);
      requests.removeWhere((r) => r.requestId == requestId);

      await CustomAnimationOverlay.showSuccess(
        message: 'تم حذف طلب التوريد بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف سجل الطلب بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر حذف الطلب',
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
        message: 'تعذر إتمام عملية الحذف: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إرسال وتقديم طلب التوريد الجديد إلى الخادم
  Future<bool> submitOrder() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }

    final posId = selectedPosId.value;
    if (posId == null) {
      CustomSnackbar.show(
        title: 'نقطة البيع مفقودة',
        message: 'يرجى اختيار نقطة البيع النشطة لتنفيذ الطلب باسمها.',
        type: SnackType.warning,
      );
      return false;
    }

    final isAuthorizedPos = myPosList.any((p) => p.posId == posId);
    if (!isAuthorizedPos) {
      CustomSnackbar.show(
        title: 'نقطة البيع غير صالحة',
        message: 'نقطة البيع المحددة لم تعد متاحة أو سارية في حسابك.',
        type: SnackType.error,
      );
      return false;
    }

    if (selectedNetworkId.value == null) {
      CustomSnackbar.show(
        title: 'تحديد الشبكة مطلوب',
        message: 'يرجى اختيار شبكة الإنترنت الموردة للكروت.',
        type: SnackType.warning,
      );
      return false;
    }

    final isLinkedNetwork = linkedNetworks.any(
      (link) => link.networkId == selectedNetworkId.value,
    );
    if (!isLinkedNetwork) {
      CustomSnackbar.show(
        title: 'تعارض في الشبكة الموردة',
        message: 'الشبكة المحددة غير مرتبطة بنقطة البيع الحالية.',
        type: SnackType.error,
      );
      return false;
    }

    if (procurementCart.isEmpty) {
      CustomSnackbar.show(
        title: 'سلة التوريد فارغة',
        message: 'أضف باقة واحدة على الأقل إلى الطلب قبل إرساله.',
        type: SnackType.warning,
      );
      return false;
    }

    if (procurementCart.any(
      (line) => line.package.networkId != selectedNetworkId.value,
    )) {
      CustomSnackbar.show(
        title: 'تعارض في الشبكة الموردة',
        message: 'تحتوي السلة على باقات لا تنتمي إلى الشبكة المحددة.',
        type: SnackType.error,
      );
      return false;
    }

    if (missingPricingPackageName != null) {
      CustomSnackbar.show(
        title: 'تعرفة الباقة غير متاحة',
        message: 'تعذر تحميل تعرفة ${missingPricingPackageName!} الخاصة بنقطة البيع. حدّث الكتالوج قبل الإرسال.',
        type: SnackType.warning,
      );
      return false;
    }

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تقديم طلب التوريد للشبكة...',
    );

    try {
      final token = serverQuote.value?.pricingToken;
      final payload = <String, dynamic>{
        'network_id': selectedNetworkId.value!,
        'pos_id': selectedPosId.value!,
        'sale_type': selectedSaleType.value.wireValue,
        if (token != null && token.isNotEmpty) 'pricing_token': token,
        if (notesController.text.trim().isNotEmpty)
          'request_note': notesController.text.trim(),
        'items': procurementCart
            .map(
              (line) => {
                'package_id': line.package.packageId,
                'voucher_count': line.voucherCount,
                'pricing_snapshot_token': line.package.procurementPricingSnapshotToken,
              },
            )
            .toList(growable: false),
      };

      final created = await createRequestUseCase(
        payload,
        idempotencyKey: _resolveCreateIdempotencyKey(payload),
      );
      requests.insert(0, created);
      clearProcurementCart();
      clearVoucherQuantity();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تقديم طلب الكروت بنجاح وهو قيد الانتظار',
      );
      CustomSnackbar.show(
        title: 'نجاح تقديم الطلب',
        message: 'تم إرسال الطلب رقم #${created.requestUuid} للشبكة بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      if (e.message.contains('أسعار') ||
          e.message.contains('pricing') ||
          e.message.contains('عرض الأسعار')) {
        _invalidateLocalPricingSnapshot();
      }
      CustomSnackbar.show(
        title: 'فشل تقديم الطلب',
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
        message: 'تعذر إرسال طلب التوريد: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إلغاء طلب توريد قيد الانتظار
  Future<bool> cancelRequest(int requestId) async {
    await CustomAnimationOverlay.showLoading(
      message: 'جاري إلغاء طلب التوريد...',
    );

    try {
      final cancelled = await cancelRequestUseCase(requestId);

      final index = requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        requests[index] = cancelled;
      } else {
        requests.add(cancelled);
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
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إلغاء الطلب',
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
        message: 'تعذر إلغاء الطلب: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// فتح شاشة تفاصيل طلب التوريد
  Future<void> openRequestDetails(RequestEntity request) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: request,
    );
  }

  /// التوجيه لشاشة إنشاء طلب توريد جديد
  Future<void> navigateToNewOrder() async {
    initNewOrderForm();
    await Get.toNamed<void>(AppRoutes.newProcurementOrder);
  }

  /// حوار إلغاء طلب التوريد
  Future<void> promptCancelRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showCancelDialog(
      requestId: request.requestId,
      onConfirm: () => cancelRequest(request.requestId),
    );
  }

  /// حوار حذف طلب التوريد الملغي أو المعلق
  Future<void> promptDeleteRequest(RequestEntity request) async {
    await ProcurementActionDialogs.showDeleteDialog(
      requestId: request.requestId,
      requestUuid: request.requestUuid,
      onConfirm: () => deleteRequest(request.requestId),
    );
  }

  /// تقديم طلب التوريد أو حفظ التعديلات والعودة في حال النجاح
  Future<void> submitOrderAndClose() async {
    final ok = isEditing.value ? await updateOrder() : await submitOrder();
    if (ok) Get.back<void>();
  }
}
