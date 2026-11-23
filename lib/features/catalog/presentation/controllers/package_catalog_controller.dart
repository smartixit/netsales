import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/package_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم قائمة كتالوج الباقات وإدارتها في مساحة عمل الشبكة (PackageCatalogController)
class PackageCatalogController extends GetxController {
  final GetPackagesUseCase getPackagesUseCase;
  final TogglePackageStatusUseCase togglePackageStatusUseCase;
  final DeletePackageUseCase deletePackageUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  PackageCatalogController({
    required this.getPackagesUseCase,
    required this.togglePackageStatusUseCase,
    required this.deletePackageUseCase,
    this.getMyNetworksUseCase,
  });

  // ── الحالة التفاعلية للقائمة ──
  final packages = <PackageEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isTogglingStatus = false.obs;
  final isDeleting = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  // ── إدارة البحث والتصفية ──
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnBool(); // null = all, true = active, false = inactive
  final selectedNetworkId = RxnInt();
  final expandedPackageId = RxnInt();
  Timer? _debounceTimer;
  int _catalogRevision = 0;

  // ── إدارة الشبكات المصرحة ──
  final authorizedNetworks = <NetworkEntity>[].obs;
  final isLoadingNetworks = false.obs;

  // ── التحقق من الصلاحيات عبر PermissionService.can ──
  bool get canCreatePackage =>
      PermissionService.instance.can(AppPermissions.voucherPackagesCreate);

  bool get canEditPackage =>
      PermissionService.instance.can(AppPermissions.voucherPackagesEdit);

  bool get canDeletePackage =>
      PermissionService.instance.can(AppPermissions.voucherPackagesDelete);

  String? get currentFilterKey {
    if (statusFilter.value == null) return null;
    return statusFilter.value! ? 'active' : 'inactive';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeWorkspace();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  /// تهيئة هوية الشبكة وجلب الباقات
  Future<void> _initializeWorkspace() async {
    final activeNetworkId = WorkspaceService.instance.savedActiveNetworkId;
    if (activeNetworkId != null) {
      selectedNetworkId.value = activeNetworkId;
    }

    if (getMyNetworksUseCase != null) {
      await _loadAuthorizedNetworks();
    }

    await fetchPackages(refresh: true);
  }

  /// جلب الشبكات المصرح للمستخدم إدارتها
  Future<void> _loadAuthorizedNetworks() async {
    if (getMyNetworksUseCase == null) return;
    try {
      isLoadingNetworks.value = true;
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);

      if (selectedNetworkId.value == null && networks.isNotEmpty) {
        selectedNetworkId.value = networks.first.networkId;
      }
    } catch (_) {
      // إخفاق صامت لتجنب حجب واجهة المستخدم
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// معالجة تغير نص البحث مع مؤقت تخميد (Debounce 300ms)
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = searchController.text.trim();
      if (searchQuery.value != query) {
        searchQuery.value = query;
        fetchPackages(refresh: true);
      }
    });
  }

  /// جلب باقات الكروت من الخادم مع دعم الترقيم بالمؤشر
  Future<void> fetchPackages({bool refresh = false}) async {
    final currentRev = ++_catalogRevision;

    if (refresh) {
      isLoading.value = true;
      errorMessage.value = null;
      nextCursor.value = null;
    } else {
      if (isLoadingMore.value || !hasMore) return;
      isLoadingMore.value = true;
      loadMoreError.value = null;
    }

    try {
      final result = await getPackagesUseCase(
        networkId: selectedNetworkId.value,
        status: statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        cursor: refresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (currentRev != _catalogRevision) return;

      if (refresh) {
        packages.assignAll(result.items);
      } else {
        packages.addAll(result.items);
      }

      nextCursor.value = result.nextCursor;
      errorMessage.value = null;
    } on AppException catch (e) {
      if (currentRev != _catalogRevision) return;
      if (refresh) {
        errorMessage.value = e.message;
      } else {
        loadMoreError.value = e.message;
        CustomSnackbar.show(
          title: 'خطأ أثناء تحميل المزيد',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (currentRev != _catalogRevision) return;
      final msg = 'تعذر استرجاع باقات الكروت: $e';
      if (refresh) {
        errorMessage.value = msg;
      } else {
        loadMoreError.value = msg;
      }
    } finally {
      if (currentRev == _catalogRevision) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  /// تحميل المزيد من الباقات عبر المؤشر
  Future<void> loadMorePackages() async {
    await fetchPackages(refresh: false);
  }

  /// تحديث القائمة بالكامل
  Future<void> refreshCatalog() async {
    await fetchPackages(refresh: true);
  }

  /// اختيار مفتاح الفلترة من شريط المؤشرات أو قائمة البحث
  void onFilterKeySelected(String? key) {
    if (key == null || key == 'all') {
      statusFilter.value = null;
    } else if (key == 'active') {
      statusFilter.value = true;
    } else if (key == 'inactive') {
      statusFilter.value = false;
    }
    fetchPackages(refresh: true);
  }

  /// تغيير الشبكة المحددة للفلترة
  void selectNetwork(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    fetchPackages(refresh: true);
  }

  /// تبديل توسيع بطاقة الباقة في الأكورديون
  void toggleExpanded(int packageId) {
    if (expandedPackageId.value == packageId) {
      expandedPackageId.value = null;
    } else {
      expandedPackageId.value = packageId;
    }
  }

  /// تبديل حالة تفعيل الباقة
  Future<void> togglePackageStatus(PackageEntity package) async {
    try {
      isTogglingStatus.value = true;
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحديث حالة الباقة...',
      );

      final updated = await togglePackageStatusUseCase(package.packageId);

      final index = packages.indexWhere(
        (p) => p.packageId == package.packageId,
      );
      if (index != -1) {
        packages[index] = updated;
      }

      CustomSnackbar.show(
        title: 'تم التحديث بنجاح',
        message: updated.isActive
            ? 'تم تفعيل باقة "${updated.packageName}" بنجاح'
            : 'تم تعطيل باقة "${updated.packageName}" بنجاح',
        type: SnackType.success,
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر تعديل الحالة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: e.toString(),
        type: SnackType.error,
      );
    } finally {
      isTogglingStatus.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// حذف باقة كروت من النظام
  Future<void> deletePackage(PackageEntity package) async {
    try {
      isDeleting.value = true;
      await CustomAnimationOverlay.showLoading(message: 'جاري حذف الباقة...');

      final success = await deletePackageUseCase(package.packageId);

      if (success) {
        packages.removeWhere((p) => p.packageId == package.packageId);
        if (expandedPackageId.value == package.packageId) {
          expandedPackageId.value = null;
        }

        CustomSnackbar.show(
          title: 'تم الحذف بنجاح',
          message: 'تم حذف باقة "${package.packageName}" بنجاح',
          type: SnackType.success,
        );
      }
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف الباقة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: e.toString(),
        type: SnackType.error,
      );
    } finally {
      isDeleting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// الانتقال لشاشة إنشاء باقة كروت
  void navigateToCreate() {
    Get.toNamed<void>(AppRoutes.packageForm);
  }

  /// الانتقال لشاشة تعديل باقة كروت
  void navigateToEdit(PackageEntity package) {
    Get.toNamed<void>(AppRoutes.packageForm, arguments: package);
  }

  /// الانتقال لشاشة تفاصيل باقة كروت
  void navigateToDetails(PackageEntity package) {
    Get.toNamed<void>(AppRoutes.packageDetails, arguments: package);
  }

  // ── بناء بطاقات المؤشرات القيادية متوافقة 100% مع معايير CustomKpiCardData ──
  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final totalCount = packages.length;
    final activeCount = packages.where((p) => p.isActive).length;
    final inactiveCount = packages.where((p) => !p.isActive).length;

    final activePres = EnumPresentationRegistry.resolvePackageStatus(
      PackageStatus.active,
    );
    final inactivePres = EnumPresentationRegistry.resolvePackageStatus(
      PackageStatus.inactive,
    );

    return [
      CustomKpiCardData(
        statusKey: 'all',
        label: 'إجمالي الباقات',
        count: totalCount,
        icon: Icons.inventory_2_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        statusKey: 'active',
        label: 'باقات نشطة',
        count: activeCount,
        icon: activePres.icon ?? Icons.check_circle_outline_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        statusKey: 'inactive',
        label: 'باقات معطلة',
        count: inactiveCount,
        icon: inactivePres.icon ?? Icons.pause_circle_outline_rounded,
        accentColor: colors.error,
      ),
    ];
  }

  // ── بناء خيارات التصفية السريعة ──
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    return [
      const CustomSearchFilterOption<String?>(
        value: null,
        label: 'جميع الحالات',
        icon: Icons.apps_rounded,
      ),
      const CustomSearchFilterOption<String?>(
        value: 'active',
        label: 'نشطة فقط',
        icon: Icons.check_circle_outline_rounded,
      ),
      const CustomSearchFilterOption<String?>(
        value: 'inactive',
        label: 'معطلة فقط',
        icon: Icons.pause_circle_outline_rounded,
      ),
    ];
  }
}
