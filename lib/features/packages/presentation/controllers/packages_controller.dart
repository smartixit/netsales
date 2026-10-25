import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_effective_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_package_details_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_package_discounts_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_discount_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_use_case.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم مركز باقات الكروت والخصومات المخصصة (PackagesController)
/// ============================================================================
/// يدير حالة التبديل بين الباقات والخصومات، مؤشرات الأداء الحيوية، والعمليات
/// الفورية وفق المبدأ الحاكم (أقل احتكاك ممكن وتصفير الحسابات الذهنية).
class PackagesController extends GetxController {
  final GetVoucherPackagesUseCase getVoucherPackagesUseCase;
  final GetVoucherPackageDetailsUseCase getVoucherPackageDetailsUseCase;
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
  final GetEffectiveDiscountUseCase getEffectiveDiscountUseCase;
  final GetPosListUseCase getPosListUseCase;

  PackagesController({
    required this.getVoucherPackagesUseCase,
    required this.getVoucherPackageDetailsUseCase,
    required this.createVoucherPackageUseCase,
    required this.updateVoucherPackageUseCase,
    required this.toggleVoucherPackageStatusUseCase,
    required this.deleteVoucherPackageUseCase,
    required this.getVoucherPackageDiscountsUseCase,
    required this.createVoucherPackageDiscountUseCase,
    required this.updateVoucherPackageDiscountUseCase,
    required this.toggleVoucherPackageDiscountStatusUseCase,
    required this.deleteVoucherPackageDiscountUseCase,
    required this.getEffectiveDiscountUseCase,
    required this.getPosListUseCase,
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

  // ── نقاط البيع والوكلاء المتاحون (لاختيار الوكيل بدون إدخال أرقام معرفات يدوية) ──
  final RxList<PosEntity> posList = <PosEntity>[].obs;
  final RxBool isLoadingPosList = false.obs;

  // ── البحث والتصفية ──
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'ALL'.obs; // ALL, ACTIVE, INACTIVE

  @override
  void onInit() {
    super.onInit();
    loadPackages();
    loadDiscounts();
    loadPosList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تبديل القطاع النشط
  void changeSegment(int index) {
    if (activeSegmentIndex.value != index) {
      activeSegmentIndex.value = index;
    }
  }

  // ==========================================================================
  // مؤشرات الأداء الحيوية (Computed KPIs)
  // ==========================================================================

  int get totalPackagesCount => packages.length;
  int get activePackagesCount =>
      packages.where((pkg) => pkg.isActive).length;

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

  Future<void> loadPackages({bool isRefresh = false}) async {
    if (!isRefresh) isLoadingPackages.value = true;
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
    await CustomAnimationOverlay.showLoading();
    try {
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
    }
  }

  /// إنشاء باقة كروت جديدة
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
    await CustomAnimationOverlay.showLoading();
    try {
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
    }
  }

  // ==========================================================================
  // عمليات خصومات نقاط البيع (Discounts Actions)
  // ==========================================================================

  Future<void> loadDiscounts({bool isRefresh = false}) async {
    if (!isRefresh) isLoadingDiscounts.value = true;
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

  /// جلب قائمة نقاط البيع والوكلاء النشطين للاختيار الذكي
  Future<void> loadPosList() async {
    isLoadingPosList.value = true;
    try {
      final result = await getPosListUseCase(status: 'ACTIVE');
      posList.assignAll(result);
    } catch (_) {
      // Ignored or logged
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
    await CustomAnimationOverlay.showLoading();
    try {
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
    await CustomAnimationOverlay.showLoading();
    try {
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
    }
  }

  /// تحديث التصفية والبحث
  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }
}
