import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discounts_for_pos_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/package_price_change_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/services/procurement_estimate_calculator.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/update_request_use_case.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns the POS procurement form, catalogue, signed pricing snapshots and submission lifecycle.
class PosNewProcurementOrderController extends GetxController {
  final CreateRequestUseCase createRequestUseCase;
  final UpdateRequestUseCase? updateRequestUseCase;
  final GetRequestDetailsUseCase? getRequestDetailsUseCase;
  final GetMyPosUseCase? getMyPosUseCase;
  final GetPosNetworksListUseCase? getPosNetworksListUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetEffectivePackageDiscountsForPosUseCase?
  getEffectivePackageDiscountsForPosUseCase;
  final GetProcurementQuoteUseCase? getProcurementQuoteUseCase;
  final ProcurementEstimateCalculator procurementEstimateCalculator;

  PosNewProcurementOrderController({
    required this.createRequestUseCase,
    this.updateRequestUseCase,
    this.getRequestDetailsUseCase,
    this.getMyPosUseCase,
    this.getPosNetworksListUseCase,
    this.getPackagesUseCase,
    this.getEffectivePackageDiscountsForPosUseCase,
    this.getProcurementQuoteUseCase,
    this.procurementEstimateCalculator = const ProcurementEstimateCalculator(),
  });

  /// حالة وضع التعديل (Edit Mode)
  final isEditing = false.obs;
  final editingRequestId = RxnInt();

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
    // تحديث استباقي صامت في الخلفية إذا كانت التعرفة بحاجة للتحديث
    if (needsPricingRefresh && !isRefreshingCartPricing.value) {
      unawaited(refreshNetworkPackages());
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
  final isLoadingMyPos = false.obs;

  /// عنوان الشاشة المنسق بحسب وضع الإنشاء أو التعديل
  String get screenTitle => isEditing.value
      ? 'تعديل طلب التوريد #${editingRequestId.value}'
      : 'طلب توريد جديد';

  /// نقطة البيع النشطة المحددة حالياً
  PosEntity? get activePos =>
      myPosList.firstWhereOrNull((p) => p.posId == selectedPosId.value);

  final linkedNetworks = <NetworkPosLinkEntity>[].obs;
  final selectedNetworkId = RxnInt();
  final isLoadingNetworks = false.obs;

  /// الشبكة المورّدة النشطة المحددة حالياً
  NetworkPosLinkEntity? get activeNetworkLink => linkedNetworks
      .firstWhereOrNull((link) => link.networkId == selectedNetworkId.value);

  /// يحدد بطاقة السياق المفتوحة حالياً لمنع تكدس خيارات الشبكة ونقطة البيع.
  final expandedProcurementContext = ''.obs;

  void togglePosContextExpansion() {
    if (isEditing.value) return;
    expandedProcurementContext.value = expandedProcurementContext.value == 'pos'
        ? ''
        : 'pos';
  }

  void toggleNetworkContextExpansion() {
    if (isEditing.value) return;
    expandedProcurementContext.value =
        expandedProcurementContext.value == 'network' ? '' : 'network';
  }

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

  final effectiveDiscountsByPackageId =
      <int, EffectivePackageDiscountEntity>{}.obs;
  final isLoadingPackageDiscounts = false.obs;
  final packageDiscountError = RxnString();
  int _packageDiscountRevision = 0;
  final isRefreshingCartPricing = false.obs;
  final cartPricingRefreshError = RxnString();
  int _cartPricingRefreshRevision = 0;

  EffectivePackageDiscountEntity? discountForPackage(int packageId) =>
      effectiveDiscountsByPackageId[packageId];

  // عرض الأسعار الرسمي المعتمد سيادياً من الخادم لكامل سلة التوريد (Phase 3.1 Quote)
  final serverQuote = Rxn<ProcurementQuoteEntity>();
  final isLoadingQuote = false.obs;
  final quoteError = RxnString();
  int _quoteRevision = 0;

  final procurementCart = <ProcurementCartLineEntity>[].obs;
  final Map<int, TextEditingController> _packageQuantityControllers = {};

  TextEditingController quantityControllerForPackage(int packageId) =>
      _packageQuantityControllers.putIfAbsent(
        packageId,
        TextEditingController.new,
      );

  bool get hasCartItems => procurementCart.isNotEmpty;

  /// يمنع إرسال الطلب بعرض سعر قديم أثناء تقارب نقرات الكمية.
  final isQuotePending = false.obs;

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
    if (!matchesContext || quote.items.length != procurementCart.length) {
      return false;
    }
    final matchesCart = procurementCart.every((line) {
      final quotedLine = quote.findLine(line.package.packageId);
      return quotedLine != null && quotedLine.voucherCount == line.voucherCount;
    });
    if (!matchesCart) return false;

    final expiresAt = quote.expiresAt;
    return expiresAt == null || DateTime.now().isBefore(expiresAt);
  }

  bool get hasCurrentProcurementSnapshots => procurementEstimateCalculator
      .hasCurrentSnapshots(procurementCart.map((line) => line.package));

  int? estimatedLineTotalMinor(PackageEntity package, int quantity) =>
      procurementEstimateCalculator.calculateLineTotalMinor(
        package,
        quantity,
        selectedSaleType.value,
      );

  (int, int, int)? get estimatedProcurementTotalsMinor =>
      procurementEstimateCalculator.calculateCartTotalsMinor(
        procurementCart,
        selectedSaleType.value,
      );

  /// هل تتوفر تقديرات مالية صالحة لسلة الطلب؟
  bool get hasEstimate => estimatedProcurementTotalsMinor != null;

  /// هل تحتاج أسعار السلة إلى تحديث التعرفة؟
  bool get needsPricingRefresh => !hasEstimate && hasCartItems;

  /// عدد الباقات المختلفة المختارة في السلة
  int get cartPackagesCount => procurementCart.length;

  /// إجمالي عدد الكروت في سلة الطلب الحالية
  int get checkoutTotalVouchers =>
      procurementCart.fold<int>(0, (sum, line) => sum + line.voucherCount);

  /// عملة تسعير الطلب المعتمدة
  String get checkoutCurrency => serverQuote.value?.currency ?? 'ر.ي';

  /// هل يتوفر عرض تسعير معتمد وخادم جاهز؟
  bool get isQuoteReady => hasCurrentServerQuote && serverQuote.value != null;

  /// إجمالي الطلب الإجمالي قبل الخصم لشريط إتمام الطلب
  double get checkoutGrossAmount {
    if (isQuoteReady) return serverQuote.value!.grossTotal;
    final estimate = estimatedProcurementTotalsMinor;
    return estimate != null ? estimate.$1 / 100.0 : 0.0;
  }

  /// إجمالي خصم الطلب لشريط إتمام الطلب
  double get checkoutDiscountAmount {
    if (isQuoteReady) return serverQuote.value!.discountTotal;
    final estimate = estimatedProcurementTotalsMinor;
    return estimate != null ? estimate.$2 / 100.0 : 0.0;
  }

  /// صافي الطلب التقديري لشريط إتمام الطلب
  double get checkoutNetAmount {
    if (isQuoteReady) return serverQuote.value!.netTotal;
    final estimate = estimatedProcurementTotalsMinor;
    return estimate != null ? estimate.$3 / 100.0 : 0.0;
  }

  /// فهرس محدد نوع البيع (0: نقدي، 1: آجل)
  int get selectedSaleTypeIndex => 0;

  /// تعيين نوع البيع عبر الفهرس
  void setSaleTypeIndex(int index) {
    selectedSaleType.value = SaleType.cash;
  }

  bool get canSubmitOrder =>
      hasCartItems && !isRefreshingCartPricing.value && !isSubmitting.value;

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

    packageSearchController.addListener(() {
      if (!_suppressPackageSearchListener) {
        packageSearchQuery.value = packageSearchController.text.trim();
      }
    });
    quantityController.addListener(() {
      quantityInput.value = quantityController.text;
    });

    debounce(
      packageSearchQuery,
      (_) => _refreshPackageSearchResults(),
      time: const Duration(milliseconds: 350),
    );

    // POS procurement estimates are derived locally from the current signed catalogue snapshot.
    ever(selectedSaleType, (_) => _refreshProcurementPresentation());

    _initializeForm();
  }

  @override
  void onClose() {
    packageSearchController.dispose();
    quantityController.dispose();
    notesController.dispose();
    for (final controller in _packageQuantityControllers.values) {
      controller.dispose();
    }
    _lifecycleRevision++;
    _packageRevision++;
    _packageDiscountRevision++;
    _cartPricingRefreshRevision++;
    _quoteRevision++;
    isRefreshingCartPricing.value = false;
    isLoadingPackages.value = false;
    isLoadingMorePackages.value = false;
    isLoadingPackageDiscounts.value = false;
    isLoadingQuote.value = false;
    isQuotePending.value = false;
    super.onClose();
  }

  /// جلب وتحديد نقطة البيع النشطة التابعة للمستخدم الحالي
  Future<void> loadMyPos({int? preferredPosId, int? preferredNetworkId}) async {
    if (getMyPosUseCase == null) return;

    final lifecycleRevision = _lifecycleRevision;
    isLoadingMyPos.value = true;
    late final List<PosEntity> posList;
    try {
      posList = await getMyPosUseCase!();
      if (lifecycleRevision != _lifecycleRevision) return;
      myPosList.assignAll(posList);
    } catch (_) {
      // Non-fatal; the context selector will present its empty state.
      myPosList.clear();
      return;
    } finally {
      isLoadingMyPos.value = false;
    }

    if (lifecycleRevision != _lifecycleRevision) return;
    final availablePosIds = posList.map((p) => p.posId).toList();
    final resolvedId =
        preferredPosId != null && availablePosIds.contains(preferredPosId)
        ? preferredPosId
        : WorkspaceService.to.resolveActivePosId(availablePosIds);

    if (resolvedId != null) {
      selectedPosId.value = resolvedId;
      await loadLinkedNetworks(
        resolvedId,
        preferredNetworkId: preferredNetworkId,
      );
      if (preferredNetworkId != null &&
          linkedNetworks.any((link) => link.networkId == preferredNetworkId)) {
        selectedNetworkId.value = preferredNetworkId;
      } else if (selectedNetworkId.value == null) {
        selectedNetworkId.value = linkedNetworks.firstOrNull?.networkId;
      }
    } else {
      selectedPosId.value = null;
      _setSelectedNetworkId(null);
      _setSelectedPackage(null);
      linkedNetworks.clear();
      availablePackages.clear();
    }
  }

  /// تغيير نقطة البيع النشطة صراحة من واجهة طلب التوريد
  Future<void> onPosSelected(int posId) async {
    if (isEditing.value) return;
    if (selectedPosId.value == posId) return;

    final isAuthorized = myPosList.any((p) => p.posId == posId);
    if (!isAuthorized) return;

    selectedPosId.value = posId;
    expandedProcurementContext.value = '';
    await WorkspaceService.to.saveActivePosId(posId);

    // تصفير بيانات وسلة وسياق الشبكات والباقات والخصومات السابقة كلياً
    clearProcurementCart();
    _setSelectedPackage(null);
    _setSelectedNetworkId(null);
    effectiveDiscountsByPackageId.clear();
    packageDiscountError.value = null;
    linkedNetworks.clear();
    availablePackages.clear();

    await loadLinkedNetworks(posId);
  }

  /// جلب قائمة الشبكات الموردة المرتبطة بنقطة البيع المحددة
  Future<void> loadLinkedNetworks(int posId, {int? preferredNetworkId}) async {
    if (getPosNetworksListUseCase == null) return;
    final lifecycleRevision = _lifecycleRevision;

    _setSelectedNetworkId(null);
    _setSelectedPackage(null);
    linkedNetworks.clear();
    availablePackages.clear();
    isLoadingNetworks.value = true;
    isLoadingPackages.value = false;

    try {
      final paginated = await getPosNetworksListUseCase!(
        posId: posId,
        status: true,
      );
      if (lifecycleRevision != _lifecycleRevision ||
          (selectedPosId.value != null && selectedPosId.value != posId)) {
        return;
      }

      linkedNetworks.assignAll(paginated.items);
      final preferredLink = preferredNetworkId == null
          ? linkedNetworks.firstOrNull
          : linkedNetworks.firstWhereOrNull(
              (link) => link.networkId == preferredNetworkId,
            );
      final selectedLink = preferredNetworkId != null
          ? preferredLink
          : linkedNetworks.firstOrNull;
      if (selectedLink != null) {
        _setSelectedNetworkId(selectedLink.networkId);
        await loadNetworkPackages(selectedLink.networkId);
      }
    } catch (_) {
      if (lifecycleRevision != _lifecycleRevision ||
          (selectedPosId.value != null && selectedPosId.value != posId)) {
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
    final lifecycleRevision = _lifecycleRevision;
    _suppressPackageSearchListener = true;
    packageSearchController.clear();
    packageSearchQuery.value = '';
    _suppressPackageSearchListener = false;
    packageNextCursor.value = null;
    packageLoadMoreErrorMessage.value = null;
    await _fetchNetworkPackages(networkId, reset: true);
    if (lifecycleRevision != _lifecycleRevision) return;
    await loadEffectivePackageDiscounts();
  }

  Future<List<PackagePriceChangeEntity>> refreshNetworkPackages() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return const [];

    final cartLines = procurementCart.toList(growable: false);
    if (cartLines.isEmpty) {
      await _fetchNetworkPackages(networkId, reset: true);
      return const [];
    }

    final posId = selectedPosId.value;
    final useCase = getPackagesUseCase;
    if (posId == null || useCase == null || isRefreshingCartPricing.value) {
      return const [];
    }

    final revision = ++_cartPricingRefreshRevision;
    final packageIds = cartLines
        .map((line) => line.package.packageId)
        .toSet()
        .toList(growable: false);
    final refreshedPackages = <int, PackageEntity>{};

    isRefreshingCartPricing.value = true;
    cartPricingRefreshError.value = null;

    // تسجيل الأسعار السابقة للباقات لمقارنة أي تغير سعري يطرأ بعد التحديث
    final oldLinePrices =
        <int, ({int baseMinor, int discountBp, int lineTotalMinor})>{};
    for (final line in cartLines) {
      final oldBase = line.package.procurementBaseUnitPriceMinor ?? 0;
      final oldDiscount = selectedSaleType.value == SaleType.cash
          ? (line.package.procurementCashDiscountBasisPoints ?? 0)
          : (line.package.procurementCreditDiscountBasisPoints ?? 0);
      final oldTotal =
          estimatedLineTotalMinor(line.package, line.voucherCount) ?? 0;
      oldLinePrices[line.package.packageId] = (
        baseMinor: oldBase,
        discountBp: oldDiscount,
        lineTotalMinor: oldTotal,
      );
    }

    try {
      // The API caps an ID-filtered request at 50 packages. Keep large carts
      // bounded without downloading unrelated catalogue pages.
      for (var offset = 0; offset < packageIds.length; offset += 50) {
        final batch = packageIds.skip(offset).take(50).toList(growable: false);
        final result = await useCase(
          networkId: networkId,
          posId: posId,
          status: true,
          packageIds: batch,
          perPage: batch.length,
        );

        if (revision != _cartPricingRefreshRevision ||
            selectedNetworkId.value != networkId ||
            selectedPosId.value != posId) {
          return const [];
        }

        for (final package in result.items) {
          if (batch.contains(package.packageId) &&
              package.networkId == networkId) {
            refreshedPackages[package.packageId] = package;
          }
        }
      }

      if (refreshedPackages.length != packageIds.length ||
          packageIds.any((id) => !refreshedPackages.containsKey(id))) {
        throw const AppException(
          'لم تصل تعرفة حديثة لكل الباقات المختارة. تحقق من حالة الباقات ثم أعد المحاولة.',
        );
      }

      // Do not apply a response to a cart that the user changed while it was
      // in flight. The next refresh will use the latest cart contents.
      if (!_matchesCartSnapshot(cartLines)) return const [];

      final refreshedLines = cartLines
          .map((line) {
            final package = refreshedPackages[line.package.packageId]!;
            if (package.packageVoucherCount <= 0) {
              throw const AppException(
                'تعذر تحديث التعرفة بسبب سعة باقة غير صالحة.',
              );
            }

            return ProcurementCartLineEntity(
              package: package,
              voucherCount: line.voucherCount,
              sheets: VoucherSheetCalculator.breakdown(
                line.voucherCount,
                package.packageVoucherCount,
              ).totalSheetsFraction,
            );
          })
          .toList(growable: false);

      if (!procurementEstimateCalculator.hasCurrentSnapshots(
        refreshedLines.map((line) => line.package),
      )) {
        throw const AppException(
          'استلم التطبيق بيانات أسعار غير مكتملة أو منتهية. أعد تحديث التعرفة.',
        );
      }

      // فحص واكتشاف أي تعديل طرأ على أسعار الباقات أو نسب الخصم
      final priceChanges = <PackagePriceChangeEntity>[];
      for (final line in cartLines) {
        final newPkg = refreshedPackages[line.package.packageId]!;
        final old = oldLinePrices[line.package.packageId];
        if (old != null) {
          final newBase = newPkg.procurementBaseUnitPriceMinor ?? 0;
          final newDiscount = selectedSaleType.value == SaleType.cash
              ? (newPkg.procurementCashDiscountBasisPoints ?? 0)
              : (newPkg.procurementCreditDiscountBasisPoints ?? 0);
          final newTotal =
              procurementEstimateCalculator.calculateLineTotalMinor(
                newPkg,
                line.voucherCount,
                selectedSaleType.value,
              ) ??
              0;

          if (old.baseMinor != newBase || old.discountBp != newDiscount) {
            priceChanges.add(
              PackagePriceChangeEntity(
                package: newPkg,
                oldBaseUnitPriceMinor: old.baseMinor,
                newBaseUnitPriceMinor: newBase,
                oldDiscountBasisPoints: old.discountBp,
                newDiscountBasisPoints: newDiscount,
                oldLineTotalMinor: old.lineTotalMinor,
                newLineTotalMinor: newTotal,
              ),
            );
          }
        }
      }

      cartPricingRefreshError.value = null;
      procurementCart.assignAll(refreshedLines);
      final refreshedAvailablePackages = availablePackages
          .map((package) => refreshedPackages[package.packageId] ?? package)
          .toList(growable: false);
      availablePackages.assignAll(refreshedAvailablePackages);
      final selectedPackageIdValue = selectedPackageId.value;
      if (selectedPackageIdValue != null) {
        final refreshedSelectedPackage =
            refreshedPackages[selectedPackageIdValue];
        if (refreshedSelectedPackage != null) {
          _setSelectedPackage(refreshedSelectedPackage);
        }
      }
      effectiveDiscountsByPackageId.clear();

      // A previous server quote is no longer relevant after the signed
      // package snapshots have been replaced.
      _quoteRevision++;
      serverQuote.value = null;
      quoteError.value = null;
      isLoadingQuote.value = false;
      isQuotePending.value = false;
      _refreshProcurementPresentation();

      unawaited(loadEffectivePackageDiscounts());
      return priceChanges;
    } catch (error) {
      if (revision != _cartPricingRefreshRevision) return const [];
      cartPricingRefreshError.value = AppException.sanitizeMessage(
        error,
        fallback: 'لم نتمكن من جلب التعرفة الحالية للباقات المختارة.',
      );
      return const [];
    } finally {
      if (revision == _cartPricingRefreshRevision) {
        isRefreshingCartPricing.value = false;
      }
    }
  }

  bool _matchesCartSnapshot(List<ProcurementCartLineEntity> snapshot) {
    if (procurementCart.length != snapshot.length) return false;

    for (var index = 0; index < snapshot.length; index++) {
      final current = procurementCart[index];
      final previous = snapshot[index];
      if (current.package.packageId != previous.package.packageId ||
          current.voucherCount != previous.voucherCount) {
        return false;
      }
    }

    return true;
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
        final knownIds = availablePackages
            .map((item) => item.packageId)
            .toSet();
        availablePackages.addAll(
          paginated.items.where((item) => !knownIds.contains(item.packageId)),
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
    _refreshPackageSearchResults();
  }

  /// Search changes refresh the visible catalogue only; cart pricing refresh
  /// is an explicit action and must not be triggered by typing.
  void _refreshPackageSearchResults() {
    final networkId = selectedNetworkId.value;
    if (networkId != null) {
      _fetchNetworkPackages(networkId, reset: true);
    }
  }

  Future<void> loadMorePackages() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    await _fetchNetworkPackages(networkId, reset: false);
  }

  /// اختيار الشبكة الموردة وتحديث الباقات
  void onNetworkSelected(int networkId) {
    if (isEditing.value) return;
    expandedProcurementContext.value = '';
    _setSelectedNetworkId(networkId);
    clearProcurementCart();
    _setSelectedPackage(null);
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

    final safeCount = voucherCount.clamp(0, 1000000);
    final quantityController = quantityControllerForPackage(package.packageId);
    final quantityText = safeCount == 0 ? '' : '$safeCount';
    if (quantityController.text != quantityText) {
      quantityController.value = TextEditingValue(
        text: quantityText,
        selection: TextSelection.collapsed(offset: quantityText.length),
      );
    }
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
        _refreshProcurementPresentation();
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
    _refreshProcurementPresentation();
  }

  /// التحكم السريع في الكمية من بطاقة الكتالوج أو بطاقة السلة.
  void adjustPackageQuantity(PackageEntity package, int delta) {
    if (delta == 0) return;
    setPackageVoucherCount(
      package,
      cartQuantityForPackage(package.packageId) + delta,
    );
  }

  /// Rebuilds reactive UI values without a network request.
  void _refreshProcurementPresentation() {
    procurementCart.refresh();
  }

  /// Loads every active custom discount for the current POS in one catalogue-level request.
  Future<void> loadEffectivePackageDiscounts() async {
    if (isClosed) return;
    final networkId = selectedNetworkId.value;
    final posId = selectedPosId.value;
    final useCase = getEffectivePackageDiscountsForPosUseCase;
    if (networkId == null || posId == null || useCase == null) {
      effectiveDiscountsByPackageId.clear();
      return;
    }

    final revision = ++_packageDiscountRevision;
    isLoadingPackageDiscounts.value = true;
    packageDiscountError.value = null;
    try {
      final discounts = await useCase(networkId: networkId, posId: posId);
      if (revision != _packageDiscountRevision ||
          selectedNetworkId.value != networkId ||
          selectedPosId.value != posId) {
        return;
      }
      effectiveDiscountsByPackageId.assignAll({
        for (final discount in discounts)
          if (discount.packageId != null) discount.packageId!: discount,
      });
      _refreshProcurementPresentation();
    } catch (error) {
      if (revision != _packageDiscountRevision) {
        return;
      }
      effectiveDiscountsByPackageId.clear();
      packageDiscountError.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل التعرفات الخاصة بنقطة البيع.',
      );
    } finally {
      if (revision == _packageDiscountRevision) {
        isLoadingPackageDiscounts.value = false;
      }
    }
  }

  void removeCartLine(int packageId) {
    final previousLength = procurementCart.length;
    procurementCart.removeWhere((line) => line.package.packageId == packageId);
    if (procurementCart.length == previousLength) return;

    if (procurementCart.isEmpty) returnToOrderItems();
    _refreshProcurementPresentation();
  }

  void clearProcurementCart() {
    _cartPricingRefreshRevision++;
    isRefreshingCartPricing.value = false;
    cartPricingRefreshError.value = null;
    procurementCart.clear();
    for (final controller in _packageQuantityControllers.values) {
      controller.clear();
    }
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
    _refreshProcurementPresentation();
  }

  void adjustCartLineBySheet(int packageId, int direction) {
    final line = procurementCart.firstWhereOrNull(
      (item) => item.package.packageId == packageId,
    );
    if (line == null || direction == 0) return;
    adjustCartLine(packageId, line.package.packageVoucherCount * direction);
  }

  /// The POS tariff catalogue is loaded once per network/POS context.
  /// Selecting a package is a local presentation operation only.
  void onPackageSelected(PackageEntity package) {
    _setSelectedPackage(package);
    setDefaultSheetIfEmpty();
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

  /// Initializes the form from route arguments or fetched request details; no list-controller state is shared.
  Future<void> _initializeForm() async {
    final lifecycleRevision = _lifecycleRevision;
    final rawArgs = Get.arguments;
    RequestEntity? request;
    if (rawArgs is RequestEntity) {
      request = rawArgs;
    } else if (rawArgs is int && getRequestDetailsUseCase != null) {
      try {
        request = await getRequestDetailsUseCase!(rawArgs);
      } catch (_) {
        request = null;
      }
    } else if (rawArgs is Map && rawArgs['request'] is RequestEntity) {
      request = rawArgs['request'] as RequestEntity;
    }

    if (request == null) {
      initNewOrderForm();
      await loadMyPos();
      return;
    }

    // If request items are missing or empty, fetch the authoritative request details
    if (request.items.isEmpty && getRequestDetailsUseCase != null) {
      try {
        final fullRequest = await getRequestDetailsUseCase!(request.requestId);
        if (fullRequest.items.isNotEmpty) {
          request = fullRequest;
        }
      } catch (_) {
        // Continue with available request data
      }
    }

    if (lifecycleRevision != _lifecycleRevision) return;

    final targetRequest = request;
    if (targetRequest == null) return;
    await populateFromRequest(targetRequest);
  }

  /// يملأ النموذج بالبيانات الكاملة للطلب المراد تعديله
  Future<void> populateFromRequest(RequestEntity request) async {
    final lifecycleRevision = _lifecycleRevision;

    isEditing.value = true;
    editingRequestId.value = request.requestId;
    selectedSaleType.value = SaleType.cash;
    notesController.text = request.requestNote ?? '';

    // تصفير السلة ووحدات التحكم السابقة
    clearProcurementCart();
    for (final controller in _packageQuantityControllers.values) {
      controller.clear();
    }

    await loadMyPos(
      preferredPosId: request.posId,
      preferredNetworkId: request.networkId,
    );
    if (lifecycleRevision != _lifecycleRevision) return;

    for (final item in request.items) {
      final pkg =
          availablePackages.firstWhereOrNull(
            (package) => package.packageId == item.packageId,
          ) ??
          item.voucherPackage ??
          PackageEntity(
            packageId: item.packageId,
            networkId: request.networkId,
            packageName:
                item.voucherPackage?.packageName ?? 'باقة #${item.packageId}',
            packageColor: item.voucherPackage?.packageColor,
            packageBalance: 0,
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

      // التأكد من وجود الباقة في قائمة الباقات المعروضة حتى يظهر كرتها في الواجهة
      if (!availablePackages.any((p) => p.packageId == pkg.packageId)) {
        availablePackages.add(pkg);
      }

      // تعبئة حقل الكمية الخاص بالباقة مباشرة
      final qtyCtrl = quantityControllerForPackage(pkg.packageId);
      final countText = '${item.voucherCount}';
      qtyCtrl.value = TextEditingValue(
        text: countText,
        selection: TextSelection.collapsed(offset: countText.length),
      );

      final sheetSize = pkg.packageVoucherCount > 0
          ? pkg.packageVoucherCount
          : 100;
      procurementCart.add(
        ProcurementCartLineEntity(
          package: pkg,
          sheets: item.voucherCount / sheetSize,
          voucherCount: item.voucherCount,
        ),
      );
    }

    if (procurementCart.isNotEmpty) {
      final firstLine = procurementCart.first;
      _setSelectedPackage(firstLine.package);
      setVoucherCount(firstLine.voucherCount);
    }

    _refreshProcurementPresentation();
    unawaited(fetchServerQuote());
  }

  /// إرسال تحديثات الطلب المعلق إلى الخادم
  Future<void> updateOrder() async {
    try {
      final requestId = editingRequestId.value;
      if (requestId == null || updateRequestUseCase == null) {
        CustomSnackbar.show(
          title: 'خطأ في عملية التعديل',
          message: 'معرف الطلب المراد تعديله غير متوفر.',
          type: SnackType.error,
        );
      }

      if (procurementCart.isEmpty) {
        CustomSnackbar.show(
          title: 'سلة التوريد فارغة',
          message: 'أضف باقة واحدة على الأقل إلى الطلب قبل إرسال التعديل.',
          type: SnackType.warning,
        );
      }

      isSubmitting.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحديث بيانات طلب التوريد...',
      );

      final payload = <String, dynamic>{
        'sale_type': selectedSaleType.value.wireValue,
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

      await updateRequestUseCase!(requestId!, payload);
      isEditing.value = false;
      editingRequestId.value = null;
      clearProcurementCart();
      clearVoucherQuantity();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم حفظ تعديلات طلب التوريد بنجاح',
      );
      Get.back<void>();
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'فشل تعديل الطلب',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تعديل طلب التوريد: $e',
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إرسال وتقديم طلب التوريد الجديد إلى الخادم
  Future<void> submitOrder() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    try {
      isSubmitting.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تقديم طلب التوريد للشبكة...',
      );

      final posId = selectedPosId.value;
      if (posId == null) {
        CustomSnackbar.show(
          title: 'نقطة البيع مفقودة',
          message: 'يرجى اختيار نقطة البيع النشطة لتنفيذ الطلب باسمها.',
          type: SnackType.warning,
        );
        return;
      }

      final isAuthorizedPos = myPosList.any((p) => p.posId == posId);
      if (!isAuthorizedPos) {
        CustomSnackbar.show(
          title: 'نقطة البيع غير صالحة',
          message: 'نقطة البيع المحددة لم تعد متاحة أو سارية في حسابك.',
          type: SnackType.error,
        );
        return;
      }

      if (selectedNetworkId.value == null) {
        CustomSnackbar.show(
          title: 'تحديد الشبكة مطلوب',
          message: 'يرجى اختيار شبكة الإنترنت الموردة للكروت.',
          type: SnackType.warning,
        );
        return;
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
        return;
      }

      if (procurementCart.isEmpty) {
        CustomSnackbar.show(
          title: 'سلة التوريد فارغة',
          message: 'أضف باقة واحدة على الأقل إلى الطلب قبل إرساله.',
          type: SnackType.warning,
        );
        return;
      }

      if (procurementCart.any(
        (line) => line.package.networkId != selectedNetworkId.value,
      )) {
        CustomSnackbar.show(
          title: 'تعارض في الشبكة الموردة',
          message: 'تحتوي السلة على باقات لا تنتمي إلى الشبكة المحددة.',
          type: SnackType.error,
        );
        return;
      }

      // 1. التحديث التلقائي الصامت للتعرفة في حال انتهاء صلاحية الـ Snapshot
      if (!hasCurrentProcurementSnapshots) {
        final preRefreshTotal = checkoutNetAmount;
        final priceChanges = await refreshNetworkPackages();
        if (cartPricingRefreshError.value != null ||
            !hasCurrentProcurementSnapshots) {
          CustomSnackbar.show(
            title: 'تعذر تحديث التعرفة',
            message:
                cartPricingRefreshError.value ??
                'تعذر الحصول على تعرفة موقعة وحديثة من الخادم قبل الإرسال.',
            type: SnackType.error,
          );
          return;
        }

        // إذا طرأ تغير فعلي على الأسعار، نتوقف ونعرض للمستخدم ديالوج المقارنة للاعتراض أو الموافقة المستنيرة
        if (priceChanges.isNotEmpty && Get.context != null) {
          if (CustomAnimationOverlay.isShowing) {
            await CustomAnimationOverlay.hide();
          }
          final accepted =
              await ProcurementActionDialogs.showPriceChangeNoticeDialog(
                context: Get.context!,
                priceChanges: priceChanges,
                oldTotal: preRefreshTotal,
                newTotal: checkoutNetAmount,
                currency: checkoutCurrency,
              );
          if (!accepted) {
            return;
          }
          await CustomAnimationOverlay.showLoading(
            message: 'جاري تقديم طلب التوريد بالتعرفة المعتمدة...',
          );
        }
      }

      final payload = <String, dynamic>{
        'network_id': selectedNetworkId.value!,
        'pos_id': selectedPosId.value!,
        'sale_type': selectedSaleType.value.wireValue,
        if (notesController.text.trim().isNotEmpty)
          'request_note': notesController.text.trim(),
        'items': procurementCart
            .map(
              (line) => {
                'package_id': line.package.packageId,
                'voucher_count': line.voucherCount,
                'pricing_snapshot_token':
                    line.package.procurementPricingSnapshotToken,
              },
            )
            .toList(growable: false),
      };

      await createRequestUseCase(
        payload,
        idempotencyKey: _resolveCreateIdempotencyKey(payload),
      );
      clearProcurementCart();
      clearVoucherQuantity();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تقديم طلب الكروت بنجاح وهو قيد الانتظار',
      );
      Get.back<void>();
    } on AppException catch (e) {
      if (e.message.contains('تعرفة') ||
          e.message.contains('pricing') ||
          e.message.contains('سعر') ||
          e.message.contains('أسعار')) {
        packageErrorMessage.value = e.message;
      }

      CustomSnackbar.show(
        title: 'فشل تقديم الطلب',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إرسال طلب التوريد: $e',
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// Submits the current form and closes only after a successful server response.
  Future<void> submitOrderAndClose() async {
    isEditing.value ? await updateOrder() : await submitOrder();
  }
}
