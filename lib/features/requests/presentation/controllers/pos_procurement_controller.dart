import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/models/procurement_cart_line.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
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

  PosProcurementController({
    required this.getRequestsUseCase,
    required this.createRequestUseCase,
    required this.cancelRequestUseCase,
    this.getMyPosUseCase,
    this.getPosNetworksListUseCase,
    this.getPackagesUseCase,
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

  final linkedNetworks = <NetworkPosLinkEntity>[].obs;
  final selectedNetworkId = RxnInt();
  final isLoadingNetworks = false.obs;

  final availablePackages = <PackageEntity>[].obs;
  final selectedPackage = Rxn<PackageEntity>();
  final selectedPackageId = RxnInt();
  final isLoadingPackages = false.obs;
  final procurementCart = <ProcurementCartLine>[].obs;

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

  /// حقل الإدخال بوحدة الأوراق؛ يحول إلى عدد الكروت عند إرسال الطلب.
  final quantityController = TextEditingController(text: '1');
  final quantityInput = '1'.obs;
  final notesController = TextEditingController();
  final selectedSaleType = SaleType.cash.obs;
  final isSubmitting = false.obs;

  int _networkLoadRevision = 0;
  int _packageLoadRevision = 0;
  int _requestListRevision = 0;

  /// يحول الأوراق إلى voucher_count الذي يقبله عقد Laravel الحالي.
  /// هذا تحويل وحدة وليس حساباً مالياً.
  int get requestedVoucherCount {
    final sheets = double.tryParse(quantityInput.value.trim());
    final sheetSize = selectedPackage.value?.packageVoucherCount ?? 0;

    if (sheets == null || !sheets.isFinite || sheetSize <= 0) {
      return 0;
    }

    return VoucherSheetCalculator.cardsForSheets(sheets, sheetSize);
  }

  String? validateSheetQuantity(String? value) {
    final sheets = double.tryParse((value ?? '').trim());

    if (sheets == null || !sheets.isFinite || sheets <= 0) {
      return 'أدخل عدد أوراق صحيحاً أكبر من صفر.';
    }

    final package = selectedPackage.value;
    if (package == null) {
      return 'اختر الباقة أولاً حتى يمكن تحويل الأوراق إلى كروت.';
    }

    if (package.packageVoucherCount <= 0) {
      return 'سعة الورقة لهذه الباقة غير صالحة. راجع بيانات الباقة لدى الشبكة.';
    }

    if (VoucherSheetCalculator.cardsForSheets(
          sheets,
          package.packageVoucherCount,
        ) <
        1) {
      return 'الكمية المدخلة لا تنتج أي كروت.';
    }

    return null;
  }

  void setSheetCount(String value) {
    quantityController.text = value;
    quantityController.selection = TextSelection.collapsed(
      offset: quantityController.text.length,
    );
    quantityInput.value = value;
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

    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    notesController.dispose();
    _networkLoadRevision++;
    _packageLoadRevision++;
    _requestListRevision++;
    super.onClose();
  }

  /// تحميل البيانات الأولية لنقاط البيع وقائمة الطلبات
  Future<void> loadInitialData() async {
    await loadMyPos();
    await loadRequests(isRefresh: true);
  }

  /// جلب نقطة البيع التابعة للمستخدم الحالي
  Future<void> loadMyPos() async {
    if (getMyPosUseCase == null) return;
    try {
      final posList = await getMyPosUseCase!();
      myPosList.assignAll(posList);
      if (posList.isNotEmpty) {
        selectedPosId.value = posList.first.posId;
        await loadLinkedNetworks(posList.first.posId);
      }
    } catch (_) {
      // Non-fatal, handled gracefully
    }
  }

  /// جلب قائمة الشبكات الموردة المرتبطة بنقطة البيع المحددة
  Future<void> loadLinkedNetworks(int posId) async {
    if (getPosNetworksListUseCase == null) return;

    final revision = ++_networkLoadRevision;
    _packageLoadRevision++;
    _setSelectedNetworkId(null);
    _setSelectedPackage(null);
    linkedNetworks.clear();
    availablePackages.clear();
    isLoadingNetworks.value = true;
    isLoadingPackages.value = false;

    try {
      final paginated = await getPosNetworksListUseCase!(posId, status: true);
      if (revision != _networkLoadRevision || selectedPosId.value != posId) {
        return;
      }

      linkedNetworks.assignAll(paginated.items);
      if (linkedNetworks.length == 1) {
        final networkId = linkedNetworks.first.networkId;
        _setSelectedNetworkId(networkId);
        await loadNetworkPackages(networkId);
      }
    } catch (_) {
      if (revision != _networkLoadRevision || selectedPosId.value != posId) {
        return;
      }
      linkedNetworks.clear();
      availablePackages.clear();
      _setSelectedNetworkId(null);
      _setSelectedPackage(null);
    } finally {
      if (revision == _networkLoadRevision) {
        isLoadingNetworks.value = false;
      }
    }
  }

  /// جلب كتالوج الباقات مع تجاهل أي استجابة تخص شبكة سابقة.
  Future<void> loadNetworkPackages(int networkId) async {
    if (getPackagesUseCase == null) return;

    final revision = ++_packageLoadRevision;
    isLoadingPackages.value = true;
    try {
      final paginated = await getPackagesUseCase!(
        networkId: networkId,
        status: true,
      );
      if (revision != _packageLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }

      availablePackages.assignAll(paginated.items);
      _setSelectedPackage(
        availablePackages.isNotEmpty ? availablePackages.first : null,
      );
    } catch (_) {
      if (revision != _packageLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      availablePackages.clear();
      _setSelectedPackage(null);
    } finally {
      if (revision == _packageLoadRevision) {
        isLoadingPackages.value = false;
      }
    }
  }

  /// اختيار الشبكة الموردة وتحديث الباقات
  void onNetworkSelected(int networkId) {
    _networkLoadRevision++;
    _setSelectedNetworkId(networkId);
    clearProcurementCart();
    _setSelectedPackage(null);
    availablePackages.clear();
    setSheetCount('1');
    loadNetworkPackages(networkId);
  }

  void addOrUpdateCartLine() {
    final package = selectedPackage.value;
    final sheets = double.tryParse(quantityInput.value.trim());

    if (package == null) {
      CustomSnackbar.show(
        title: 'اختر الباقة أولاً',
        message: 'حدد الباقة التي تريد إضافتها إلى طلب التوريد.',
        type: SnackType.warning,
      );
      return;
    }
    if (sheets == null || !sheets.isFinite || sheets <= 0) {
      CustomSnackbar.show(
        title: 'كمية الأوراق غير صالحة',
        message: 'أدخل كمية أكبر من صفر قبل إضافة الباقة.',
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
        message: 'لا يمكن تحويل الأوراق إلى كروت لأن سعة الباقة غير صحيحة.',
        type: SnackType.error,
      );
      return;
    }

    final voucherCount = VoucherSheetCalculator.cardsForSheets(
      sheets,
      package.packageVoucherCount,
    );
    if (voucherCount <= 0) {
      CustomSnackbar.show(
        title: 'كمية غير صالحة',
        message: 'الكمية المدخلة لا تنتج أي كروت.',
        type: SnackType.warning,
      );
      return;
    }

    final line = ProcurementCartLine(
      package: package,
      sheets: sheets,
      voucherCount: voucherCount,
    );
    final index = procurementCart.indexWhere(
      (item) => item.package.packageId == package.packageId,
    );

    if (index == -1) {
      procurementCart.add(line);
      CustomSnackbar.show(
        title: 'أضيفت الباقة إلى الطلب',
        message: 'تمت إضافة ${package.packageName} إلى سلة التوريد.',
        type: SnackType.success,
      );
    } else {
      procurementCart[index] = line;
      CustomSnackbar.show(
        title: 'تم تحديث كمية الباقة',
        message: 'تم تحديث كمية ${package.packageName} في سلة التوريد.',
        type: SnackType.success,
      );
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void editCartLine(ProcurementCartLine line) {
    _setSelectedPackage(line.package);
    setSheetCount(_formatSheetQuantity(line.sheets));
  }

  void removeCartLine(int packageId) {
    procurementCart.removeWhere((line) => line.package.packageId == packageId);
  }

  void clearProcurementCart() {
    procurementCart.clear();
  }

  String _formatSheetQuantity(double sheets) {
    return sheets == sheets.roundToDouble()
        ? sheets.toInt().toString()
        : sheets.toString();
  }

  /// اختيار الباقة المطلوبة
  void onPackageSelected(PackageEntity package) {
    _setSelectedPackage(package);
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
    setSheetCount('1');
    notesController.clear();
    selectedSaleType.value = SaleType.cash;

    if (linkedNetworks.length == 1) {
      _setSelectedNetworkId(linkedNetworks.first.networkId);
      loadNetworkPackages(linkedNetworks.first.networkId);
    }
  }

  /// إرسال وتقديم طلب التوريد الجديد إلى الخادم
  Future<bool> submitOrder() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedPosId.value == null) {
      CustomSnackbar.show(
        title: 'نقطة البيع مفقودة',
        message: 'لا توجد نقطة بيع معتمدة مرتبطة بحسابك.',
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
              },
            )
            .toList(growable: false),
      };

      final created = await createRequestUseCase(payload);
      requests.insert(0, created);
      clearProcurementCart();
      setSheetCount('1');

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تقديم طلب الكروت بنجاح وهو قيد الانتظار',
      );
      CustomSnackbar.show(
        title: 'نجاح تقديم الطلب',
        message: 'تم إرسال الطلب رقم #${created.requestId} للشبكة بنجاح.',
        type: SnackType.success,
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
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
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إلغاء طلب الكروت بنجاح',
      );
      CustomSnackbar.show(
        title: 'تم الإلغاء',
        message: 'تم إلغاء الطلب رقم #${cancelled.requestId} بنجاح.',
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
}
