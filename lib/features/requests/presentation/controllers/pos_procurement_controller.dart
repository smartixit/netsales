import 'dart:async';

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
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_action_dialogs.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة طلبات التوريد والشراء لنقاط البيع (POS Procurement Controller)
class PosProcurementController extends GetxController {
  final GetRequestsUseCase getRequestsUseCase;
  final CreateRequestUseCase createRequestUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final GetMyPosUseCase? getMyPosUseCase;
  final GetPosNetworksListUseCase? getPosNetworksListUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetEffectivePackageDiscountUseCase? getEffectivePackageDiscountUseCase;
  final GetProcurementQuoteUseCase? getProcurementQuoteUseCase;

  PosProcurementController({
    required this.getRequestsUseCase,
    required this.createRequestUseCase,
    required this.cancelRequestUseCase,
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
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  // فلاتر وبحث الطلبات
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnString(); // null = all, PENDING, APPROVED, etc.

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
    quantityController.addListener(() {
      quantityInput.value = quantityController.text;
    });

    debounce(
      searchQuery,
      (_) => loadRequests(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );

    ever(selectedSaleType, (_) {
      if (procurementCart.isNotEmpty) {
        unawaited(fetchServerQuote());
      }
    });

    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    notesController.dispose();
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

  /// جلب كتالوج الباقات مع تجاهل أي استجابة تخص شبكة سابقة.
  Future<void> loadNetworkPackages(int networkId) async {
    if (getPackagesUseCase == null) return;

    isLoadingPackages.value = true;
    try {
      final paginated = await getPackagesUseCase!(
        networkId: networkId,
        status: true,
      );
      if (selectedNetworkId.value != null &&
          selectedNetworkId.value != networkId) {
        return;
      }

      availablePackages.assignAll(paginated.items);
      final initialPkg = availablePackages.isNotEmpty
          ? availablePackages.first
          : null;
      _setSelectedPackage(initialPkg);
      if (initialPkg != null) {
        setDefaultSheetIfEmpty();
        unawaited(loadEffectiveDiscount());
      }
    } catch (_) {
      if (selectedNetworkId.value != null &&
          selectedNetworkId.value != networkId) {
        return;
      }
      availablePackages.clear();
      _setSelectedPackage(null);
    } finally {
      isLoadingPackages.value = false;
    }
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

  void addOrUpdateCartLine() {
    final package = selectedPackage.value;
    final voucherCount = requestedVoucherCount;

    if (package == null) {
      CustomSnackbar.show(
        title: 'اختر الباقة أولاً',
        message: 'حدد الباقة التي تريد إضافتها إلى طلب التوريد.',
        type: SnackType.warning,
      );
      return;
    }
    if (voucherCount <= 0) {
      CustomSnackbar.show(
        title: 'كمية الكروت غير صالحة',
        message: 'أدخل عدداً صحيحاً من الكروت أكبر من صفر قبل إضافة الباقة.',
        type: SnackType.warning,
      );
      return;
    }
    if (package.networkId != selectedNetworkId.value) {
      CustomSnackbar.show(
        title: 'الباقة لا تتبع الشبكة المحددة',
        message: 'اختر باقة من كتالوج الشبكة الموردة الحالية.',
        type: SnackType.error,
      );
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

    final calculatedSheets = voucherCount / package.packageVoucherCount;
    final line = ProcurementCartLineEntity(
      package: package,
      sheets: calculatedSheets,
      voucherCount: voucherCount,
    );
    final index = procurementCart.indexWhere(
      (item) => item.package.packageId == package.packageId,
    );

    if (index == -1) {
      procurementCart.add(line);
      CustomSnackbar.show(
        title: 'أضيفت الباقة إلى الطلب',
        message:
            'تمت إضافة ${package.packageName} إلى سلة التوريد ($voucherCount كرت).',
        type: SnackType.success,
      );
    } else {
      procurementCart[index] = line;
      CustomSnackbar.show(
        title: 'تم تحديث كمية الباقة',
        message: 'تم تحديث كمية ${package.packageName} إلى $voucherCount كرت.',
        type: SnackType.success,
      );
    }
    unawaited(fetchServerQuote());
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void editCartLine(ProcurementCartLineEntity line) {
    _setSelectedPackage(line.package);
    setVoucherCount(line.voucherCount);
  }

  void removeCartLine(int packageId) {
    procurementCart.removeWhere((line) => line.package.packageId == packageId);
    if (procurementCart.isEmpty) {
      serverQuote.value = null;
      quoteError.value = null;
    } else {
      unawaited(fetchServerQuote());
    }
  }

  void clearProcurementCart() {
    procurementCart.clear();
    serverQuote.value = null;
    quoteError.value = null;
  }

  /// جلب واحتساب عرض الأسعار الرسمي المعتمد سيادياً من الخادم لبنود السلة وطريقة الدفع المختارة
  Future<void> fetchServerQuote() async {
    final networkId = selectedNetworkId.value;
    final posId = selectedPosId.value;
    final items = procurementCart.toList(growable: false);

    if (networkId == null ||
        posId == null ||
        items.isEmpty ||
        getProcurementQuoteUseCase == null) {
      serverQuote.value = null;
      quoteError.value = null;
      return;
    }

    final revision = ++_quoteRevision;
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

  /// اختيار الباقة المطلوبة
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
    } catch (_) {
      // Keep the already loaded page and allow an explicit retry.
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

  /// تهيئة نموذج طلب جديد
  void initNewOrderForm() {
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
              },
            )
            .toList(growable: false),
      };

      final created = await createRequestUseCase(payload);
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
        unawaited(fetchServerQuote());
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

  /// تقديم طلب التوريد والعودة في حال النجاح
  Future<void> submitOrderAndClose() async {
    final ok = await submitOrder();
    if (ok) Get.back<void>();
  }
}
