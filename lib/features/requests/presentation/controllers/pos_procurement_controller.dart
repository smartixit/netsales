import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
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
  final isLoadingPackages = false.obs;

  final quantityController = TextEditingController(text: '10');
  final notesController = TextEditingController();
  final selectedSaleType = SaleType.cash.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
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
    isLoadingNetworks.value = true;
    try {
      final paginated = await getPosNetworksListUseCase!(
        posId,
        status: true, // الشبكات المرتبطة النشطة فقط
      );
      linkedNetworks.assignAll(paginated.items);
      if (linkedNetworks.length == 1) {
        selectedNetworkId.value = linkedNetworks.first.networkId;
        await loadNetworkPackages(linkedNetworks.first.networkId);
      } else {
        selectedNetworkId.value = null;
        availablePackages.clear();
        selectedPackage.value = null;
      }
    } catch (_) {
      linkedNetworks.clear();
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// جلب كتالوج باقات الكروت المتاحة لدى الشبكة المحددة
  Future<void> loadNetworkPackages(int networkId) async {
    if (getPackagesUseCase == null) return;
    isLoadingPackages.value = true;
    try {
      final paginated = await getPackagesUseCase!(
        networkId: networkId,
        status: true, // الباقات النشطة فقط
      );
      availablePackages.assignAll(paginated.items);
      if (availablePackages.isNotEmpty) {
        selectedPackage.value = availablePackages.first;
      } else {
        selectedPackage.value = null;
      }
    } catch (_) {
      availablePackages.clear();
      selectedPackage.value = null;
    } finally {
      isLoadingPackages.value = false;
    }
  }

  /// اختيار الشبكة الموردة وتحديث الباقات
  void onNetworkSelected(int networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    loadNetworkPackages(networkId);
  }

  /// اختيار الباقة المطلوبة
  void onPackageSelected(PackageEntity package) {
    selectedPackage.value = package;
  }

  /// تحميل طلبات التوريد من الخادم مع ترقيم المؤشر
  Future<void> loadRequests({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;

    if (isRefresh) {
      nextCursor.value = null;
    }

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: selectedPosId.value,
        status: statusFilter.value,
        search: effectiveSearch,
        cursor: null,
      );

      requests.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      errorMessage.value = e is AppException
          ? e.message
          : 'تعذر تحميل قائمة طلبات التوريد: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد من الطلبات عند التمرير
  Future<void> loadMoreRequests() async {
    if (isLoadingMore.value || isLoading.value || nextCursor.value == null) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<RequestEntity> result = await getRequestsUseCase(
        posId: selectedPosId.value,
        status: statusFilter.value,
        search: effectiveSearch,
        cursor: nextCursor.value,
      );

      final existingIds = requests.map((r) => r.requestId).toSet();
      final newItems =
          result.items.where((r) => !existingIds.contains(r.requestId)).toList();

      requests.addAll(newItems);
      nextCursor.value = result.nextCursor;
    } catch (_) {
      // Non-fatal for load-more
    } finally {
      isLoadingMore.value = false;
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
    quantityController.text = '10';
    notesController.clear();
    selectedSaleType.value = SaleType.cash;

    if (linkedNetworks.length == 1) {
      selectedNetworkId.value = linkedNetworks.first.networkId;
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

    if (selectedPackage.value == null) {
      CustomSnackbar.show(
        title: 'تحديد الباقة مطلوب',
        message: 'يرجى اختيار باقة الكروت المراد طلبها.',
        type: SnackType.warning,
      );
      return false;
    }

    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (quantity <= 0) {
      CustomSnackbar.show(
        title: 'كمية غير صالحة',
        message: 'يرجى إدخال كمية كروت صحيحة (1 كارت على الأقل).',
        type: SnackType.warning,
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
        'items': [
          {
            'package_id': selectedPackage.value!.packageId,
            'voucher_count': quantity,
          }
        ],
      };

      final created = await createRequestUseCase(payload);
      requests.insert(0, created);

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

