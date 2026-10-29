import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_package_discounts_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_discount_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم مركز باقات الكروت والخصومات المخصصة (PackagesController)
/// ============================================================================
/// يدير حالة التبديل بين الباقات والخصومات، مؤشرات الأداء الحيوية، والعمليات
/// الفورية وفق النمط المعماري القياسي الموحد المعتمد في OperationsController.
class PackagesController extends GetxController {
  final GetVoucherPackagesUseCase getVoucherPackagesUseCase;
  final CreateVoucherPackageUseCase createVoucherPackageUseCase;
  final UpdateVoucherPackageUseCase updateVoucherPackageUseCase;
  final ToggleVoucherPackageStatusUseCase toggleVoucherPackageStatusUseCase;
  final DeleteVoucherPackageUseCase deleteVoucherPackageUseCase;

  final GetVoucherPackageDiscountsUseCase getVoucherPackageDiscountsUseCase;
  final CreateVoucherPackageDiscountUseCase createVoucherPackageDiscountUseCase;
  final UpdateVoucherPackageDiscountUseCase updateVoucherPackageDiscountUseCase;
  final ToggleVoucherPackageDiscountStatusUseCase
      toggleVoucherPackageDiscountStatusUseCase;
  final DeleteVoucherPackageDiscountUseCase
      deleteVoucherPackageDiscountUseCase;
  final GetPosListUseCase getPosListUseCase;
  final GetNetworksUseCase getNetworksUseCase;

  PackagesController({
    required this.getVoucherPackagesUseCase,
    required this.createVoucherPackageUseCase,
    required this.updateVoucherPackageUseCase,
    required this.toggleVoucherPackageStatusUseCase,
    required this.deleteVoucherPackageUseCase,
    required this.getVoucherPackageDiscountsUseCase,
    required this.createVoucherPackageDiscountUseCase,
    required this.updateVoucherPackageDiscountUseCase,
    required this.toggleVoucherPackageDiscountStatusUseCase,
    required this.deleteVoucherPackageDiscountUseCase,
    required this.getPosListUseCase,
    required this.getNetworksUseCase,
  });

  /// القطاع النشط: 0 لباقات الكروت، 1 لخصومات نقاط البيع
  final RxInt activeSegmentIndex = 0.obs;

  // ── باقات الكروت ──
  final RxList<VoucherPackageEntity> packages = <VoucherPackageEntity>[].obs;
  final RxBool isLoadingPackages = false.obs;
  final RxString packagesError = ''.obs;

  // ── خصومات نقاط البيع المخصصة ──
  final RxList<VoucherPackageDiscountEntity> discounts =
      <VoucherPackageDiscountEntity>[].obs;
  final RxBool isLoadingDiscounts = false.obs;
  final RxString discountsError = ''.obs;

  // ── نقاط البيع والوكلاء المتاحون ──
  final RxList<PosEntity> posList = <PosEntity>[].obs;
  final RxBool isLoadingPosList = false.obs;

  // ── شبكات المزود المتاحة ──
  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxBool isLoadingNetworks = false.obs;

  // ── حالة تنفيذ الإجراءات ──
  final RxBool isSubmittingAction = false.obs;

  // ── البحث والتصفية ──
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'ALL'.obs; // ALL, ACTIVE, INACTIVE
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadNetworks();
    loadPackages();
    loadDiscounts();
    loadPosList();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  /// تبديل القطاع النشط
  void changeSegment(int index) {
    if (activeSegmentIndex.value != index) {
      activeSegmentIndex.value = index;
    }
  }

  /// تنفيذ البحث الحي بتهدئة تلقائية
  void onSearchChanged(String _) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppMotion.searchDebounce, () {
      if (activeSegmentIndex.value == 0) {
        loadPackages();
      } else {
        loadDiscounts();
      }
    });
  }

  /// تنفيذ البحث عند التقديم المباشر
  void onSearchSubmitted(String _) {
    _searchDebounceTimer?.cancel();
    if (activeSegmentIndex.value == 0) {
      loadPackages();
    } else {
      loadDiscounts();
    }
  }

  /// مسح نص البحث
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    searchController.clear();
    if (activeSegmentIndex.value == 0) {
      loadPackages();
    } else {
      loadDiscounts();
    }
  }

  // ==========================================================================
  // مؤشرات الأداء الحيوية (Computed KPIs)
  // ==========================================================================

  int get totalPackagesCount => packages.length;
  int get activePackagesCount =>
      packages.where((pkg) => pkg.isActive).length;

  // DISPLAY-ONLY (UI-only, non-authoritative): aggregate of the prices of the
  // packages currently loaded on the client. Not sent to the backend; backend
  // remains the authority for any authoritative average.
  double get averagePackagePrice {
    if (packages.isEmpty) return 0.0;
    final total = packages.fold<double>(
      0.0,
      (sum, pkg) => sum + pkg.packageVoucherPrice,
    );
    return total / packages.length;
  }

  int get totalDiscountsCount => discounts.length;
  int get activeDiscountsCount =>
      discounts.where((d) => d.isActive).length;

  // ==========================================================================
  // القوائم المفلترة (Filtered Lists)
  // ==========================================================================

  List<VoucherPackageEntity> get filteredPackages {
    final query = searchController.text.trim().toLowerCase();
    return packages.where((pkg) {
      final matchesQuery = query.isEmpty ||
          pkg.packageName.toLowerCase().contains(query) ||
          pkg.packageVoucherPrice.toString().contains(query);

      final matchesFilter = selectedFilter.value == 'ALL' ||
          (selectedFilter.value == 'ACTIVE' && pkg.isActive) ||
          (selectedFilter.value == 'INACTIVE' && !pkg.isActive);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<VoucherPackageDiscountEntity> get filteredDiscounts {
    final query = searchController.text.trim().toLowerCase();
    return discounts.where((disc) {
      final matchesQuery = query.isEmpty ||
          (disc.posName?.toLowerCase().contains(query) ?? false) ||
          (disc.packageName?.toLowerCase().contains(query) ?? false);

      final matchesFilter = selectedFilter.value == 'ALL' ||
          (selectedFilter.value == 'ACTIVE' && disc.isActive) ||
          (selectedFilter.value == 'INACTIVE' && !disc.isActive);

      return matchesQuery && matchesFilter;
    }).toList();
  }

  // ==========================================================================
  // عمليات باقات الكروت (Packages Actions)
  // ==========================================================================

  Future<void> loadNetworks() async {
    isLoadingNetworks.value = true;
    try {
      final result = await getNetworksUseCase(status: 'ACTIVE');
      networks.assignAll(result);
    } catch (_) {
      // إخفاق صامت والاعتماد على الخيارات المتاحة
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  Future<void> loadPackages({bool isRefresh = false}) async {
    isLoadingPackages.value = true;
    packagesError.value = '';

    try {
      final result = await getVoucherPackagesUseCase(
        search: searchController.text.trim().isEmpty
            ? null
            : searchController.text.trim(),
      );
      packages.assignAll(result);
    } catch (e) {
      packagesError.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: packagesError.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingPackages.value = false;
    }
  }

  /// تبديل حالة باقة الكروت بنقرة واحدة فورية
  Future<void> togglePackageStatus(int packageId) async {
    final index = packages.indexWhere((pkg) => pkg.packageId == packageId);
    if (index == -1) return;

    final oldPackage = packages[index];
    packages[index] = oldPackage.copyWith(status: !oldPackage.status);

    try {
      final updated = await toggleVoucherPackageStatusUseCase(packageId);
      packages[index] = updated;
      CustomSnackbar.show(
        title: 'تم التحديث',
        message: updated.status
            ? 'تم تفعيل باقة "${updated.packageName}" بنجاح'
            : 'تم إيقاف باقة "${updated.packageName}" مؤقتاً',
        type: SnackType.success,
      );
    } catch (e) {
      packages[index] = oldPackage;
      CustomSnackbar.show(
        title: 'فشل تبديل الحالة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  /// حذف باقة كروت
  Future<void> deletePackage(int packageId) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جارٍ حذف باقة الكروت...');
      await deleteVoucherPackageUseCase(packageId);
      packages.removeWhere((pkg) => pkg.packageId == packageId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم نقل باقة الكروت إلى سلة المحذوفات بنجاح.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل الحذف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إنشاء أو تعديل باقة كروت
  Future<bool> savePackage({
    int? packageId,
    required int networkId,
    required String packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    required double packageVoucherPrice,
    required double packageDefaultCashDiscount,
    required double packageDefaultCreditDiscount,
    bool? status,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: packageId != null && packageId > 0
            ? 'جارٍ حفظ تعديلات الباقة...'
            : 'جارٍ إنشاء باقة الكروت...',
      );

      if (packageId != null && packageId > 0) {
        final updated = await updateVoucherPackageUseCase(
          packageId: packageId,
          packageName: packageName,
          packageColor: packageColor,
          packageBalance: packageBalance,
          packageUptime: packageUptime,
          packageValidity: packageValidity,
          packageVoucherCount: packageVoucherCount,
          packageVoucherPrice: packageVoucherPrice,
          packageDefaultCashDiscount: packageDefaultCashDiscount,
          packageDefaultCreditDiscount: packageDefaultCreditDiscount,
          status: status,
        );
        final index =
            packages.indexWhere((p) => p.packageId == packageId);
        if (index != -1) {
          packages[index] = updated;
        }
        await CustomAnimationOverlay.showSuccess(
          message: 'تم تحديث بيانات باقة الكروت بنجاح.',
        );
      } else {
        final created = await createVoucherPackageUseCase(
          networkId: networkId,
          packageName: packageName,
          packageColor: packageColor,
          packageBalance: packageBalance,
          packageUptime: packageUptime,
          packageValidity: packageValidity,
          packageVoucherCount: packageVoucherCount,
          packageVoucherPrice: packageVoucherPrice,
          packageDefaultCashDiscount: packageDefaultCashDiscount,
          packageDefaultCreditDiscount: packageDefaultCreditDiscount,
          status: status,
        );
        packages.insert(0, created);
        await CustomAnimationOverlay.showSuccess(
          message: 'تمت إضافة باقة الكروت الجديدة بنجاح.',
        );
      }
      return true;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل الحفظ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  // ==========================================================================
  // عمليات خصومات نقاط البيع (Discounts Actions)
  // ==========================================================================

  Future<void> loadDiscounts({bool isRefresh = false}) async {
    isLoadingDiscounts.value = true;
    discountsError.value = '';

    try {
      final result = await getVoucherPackageDiscountsUseCase(
        search: searchController.text.trim().isEmpty
            ? null
            : searchController.text.trim(),
      );
      discounts.assignAll(result);
    } catch (e) {
      discountsError.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: discountsError.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoadingDiscounts.value = false;
    }
  }

  /// جلب قائمة نقاط البيع والوكلاء النشطين
  Future<void> loadPosList() async {
    isLoadingPosList.value = true;
    try {
      final result = await getPosListUseCase(status: 'ACTIVE');
      posList.assignAll(result);
    } catch (_) {
      // إخفاق صامت
    } finally {
      isLoadingPosList.value = false;
    }
  }

  /// تبديل حالة تفعيل خصم مخصص بنقرة واحدة
  Future<void> toggleDiscountStatus(int discountId) async {
    final index = discounts.indexWhere((d) => d.discountId == discountId);
    if (index == -1) return;

    final oldDiscount = discounts[index];
    discounts[index] = oldDiscount.copyWith(status: !oldDiscount.status);

    try {
      final updated =
          await toggleVoucherPackageDiscountStatusUseCase(discountId);
      discounts[index] = updated;
      CustomSnackbar.show(
        title: 'تم التحديث',
        message: updated.status
            ? 'تم تفعيل الخصم الاستثنائي لنقطة البيع'
            : 'تم إيقاف الخصم الاستثنائي (سيتم تطبيق الخصم الافتراضي للباقة)',
        type: SnackType.success,
      );
    } catch (e) {
      discounts[index] = oldDiscount;
      CustomSnackbar.show(
        title: 'فشل تبديل الحالة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  /// حذف خصم مخصص
  Future<void> deleteDiscount(int discountId) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(message: 'جارٍ حذف الخصم المخصص...');
      await deleteVoucherPackageDiscountUseCase(discountId);
      discounts.removeWhere((d) => d.discountId == discountId);
      await CustomAnimationOverlay.showSuccess(
        message: 'تم نقل سجل الخصم إلى سلة المحذوفات بنجاح.',
      );
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل الحذف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إنشاء أو تعديل خصم مخصص لنقطة بيع
  Future<bool> saveDiscount({
    int? discountId,
    required int networkId,
    required int posId,
    required int packageId,
    required double discountCash,
    required double discountCredit,
    bool? status,
  }) async {
    isSubmittingAction.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: discountId != null && discountId > 0
            ? 'جارٍ تحديث الخصم المخصص...'
            : 'جارٍ تسجيل الخصم المخصص...',
      );

      if (discountId != null && discountId > 0) {
        final updated = await updateVoucherPackageDiscountUseCase(
          discountId: discountId,
          discountCash: discountCash,
          discountCredit: discountCredit,
          status: status,
        );
        final index =
            discounts.indexWhere((d) => d.discountId == discountId);
        if (index != -1) {
          discounts[index] = updated;
        }
        await CustomAnimationOverlay.showSuccess(
          message: 'تم تحديث بيانات الخصم المخصص بنجاح.',
        );
      } else {
        final created = await createVoucherPackageDiscountUseCase(
          networkId: networkId,
          posId: posId,
          packageId: packageId,
          discountCash: discountCash,
          discountCredit: discountCredit,
          status: status,
        );
        discounts.insert(0, created);
        await CustomAnimationOverlay.showSuccess(
          message: 'تم حفظ الخصم المخصص لنقطة البيع بنجاح.',
        );
      }
      return true;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل الحفظ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// تحديث التصفية والبحث
  void updateFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
    }
  }
}
