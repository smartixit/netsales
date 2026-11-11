import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة كتالوج باقات الكروت والأسعار التعاقدية
class PackageCatalogController extends GetxController {
  final GetPackagesUseCase getPackagesUseCase;
  final GetNetworkPackagesUseCase getNetworkPackagesUseCase;
  final GetPackageDetailsUseCase getPackageDetailsUseCase;
  final CreatePackageUseCase createPackageUseCase;
  final UpdatePackageUseCase updatePackageUseCase;
  final TogglePackageStatusUseCase togglePackageStatusUseCase;
  final DeletePackageUseCase deletePackageUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  PackageCatalogController({
    required this.getPackagesUseCase,
    required this.getNetworkPackagesUseCase,
    required this.getPackageDetailsUseCase,
    required this.createPackageUseCase,
    required this.updatePackageUseCase,
    required this.togglePackageStatusUseCase,
    required this.deletePackageUseCase,
    this.getMyNetworksUseCase,
  });

  // State Variables
  final packages = <PackageEntity>[].obs;
  final filteredPackages = <PackageEntity>[].obs;
  final selectedPackage = Rxn<PackageEntity>();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final isTogglingStatus = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  bool get hasMore => nextCursor.value != null;

  // Filters & Server Search
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnBool(); // null = all, true = active, false = inactive
  final selectedNetworkId = RxnInt();

  // Network Selection State
  final authorizedNetworks = <NetworkEntity>[].obs;
  final isLoadingNetworks = false.obs;
  final formNetworkId = RxnInt();

  // Form Management
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final uptimeController = TextEditingController();
  final validityController = TextEditingController();
  final voucherCountController = TextEditingController();
  final priceController = TextEditingController();
  final cashDiscountController = TextEditingController();
  final creditDiscountController = TextEditingController();

  // Form Spec Units (ValueNotifiers for native CustomDropdown compatibility)
  final selectedBalanceUnit = ValueNotifier<DataUnit>(DataUnit.mb);
  final selectedUptimeUnit = ValueNotifier<UptimeUnit>(UptimeUnit.hours);
  final selectedValidityUnit = ValueNotifier<ValidityUnit>(ValidityUnit.days);

  final selectedColorHex = '0xFF0D7A5F'.obs;
  final packageActiveStatus = true.obs;
  final isEditing = false.obs;
  final editingPackageId = RxnInt();

  /// التحقق من صلاحيات إدارة الباقات
  bool get canCreatePackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesCreate);
  bool get canEditPackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesEdit);
  bool get canDeletePackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesDelete);

  @override
  void onInit() {
    super.onInit();

    // Debounced search via GetX debounce worker
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadPackages(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );

    loadAuthorizedNetworks();
    loadPackages();
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    balanceController.dispose();
    uptimeController.dispose();
    validityController.dispose();
    voucherCountController.dispose();
    priceController.dispose();
    cashDiscountController.dispose();
    creditDiscountController.dispose();
    selectedBalanceUnit.dispose();
    selectedUptimeUnit.dispose();
    selectedValidityUnit.dispose();
    super.onClose();
  }

  /// جلب الشبكات المعتمدة التابعة للمستخدم لتحديد شبكة إنشاء الباقة
  Future<void> loadAuthorizedNetworks() async {
    if (getMyNetworksUseCase == null) return;
    isLoadingNetworks.value = true;
    try {
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);
      final networkIds = networks.map((n) => n.networkId).toList(growable: false);
      final resolvedId = WorkspaceService.to.resolveActiveNetworkId(networkIds);
      if (formNetworkId.value == null && resolvedId != null) {
        formNetworkId.value = resolvedId;
      }
      if (selectedNetworkId.value == null && resolvedId != null) {
        selectedNetworkId.value = resolvedId;
      }
    } catch (_) {
      // Non-blocking, handled during submission validation
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// تحميل الباقات من الخادم مع ترقيم الصفحات القائم على المؤشر (Cursor Pagination)
  Future<void> loadPackages({int? networkId, bool isRefresh = false}) async {
    if (networkId != null) {
      selectedNetworkId.value = networkId;
    }

    isLoading.value = true;
    errorMessage.value = null;

    if (isRefresh) {
      nextCursor.value = null;
    }

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<PackageEntity> result;
      if (selectedNetworkId.value != null) {
        result = await getNetworkPackagesUseCase(
          selectedNetworkId.value!,
          status: statusFilter.value,
          search: effectiveSearch,
          cursor: null,
        );
      } else {
        result = await getPackagesUseCase(
          networkId: selectedNetworkId.value,
          status: statusFilter.value,
          search: effectiveSearch,
          cursor: null,
        );
      }

      packages.assignAll(result.items);
      filteredPackages.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      errorMessage.value = e is AppException
          ? e.message
          : 'تعذر تحميل باقات الكروت: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تحميل المزيد من الباقات عند التمرير لنهاية القائمة
  Future<void> loadMorePackages() async {
    if (isLoadingMore.value || isLoading.value || nextCursor.value == null) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final query = searchQuery.value.trim();
      final effectiveSearch = query.isEmpty ? null : query;

      final PaginatedList<PackageEntity> result;
      if (selectedNetworkId.value != null) {
        result = await getNetworkPackagesUseCase(
          selectedNetworkId.value!,
          status: statusFilter.value,
          search: effectiveSearch,
          cursor: nextCursor.value,
        );
      } else {
        result = await getPackagesUseCase(
          networkId: selectedNetworkId.value,
          status: statusFilter.value,
          search: effectiveSearch,
          cursor: nextCursor.value,
        );
      }

      // منع التكرار بناء على packageId
      final existingIds = packages.map((p) => p.packageId).toSet();
      final newItems = result.items
          .where((p) => !existingIds.contains(p.packageId))
          .toList();

      packages.addAll(newItems);
      filteredPackages.assignAll(packages);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      // Non-fatal for load-more; cursor remains so user can retry by scrolling
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// تحديث قائمة الكتالوج بالكامل
  Future<void> refreshCatalog() async {
    await loadPackages(isRefresh: true);
  }

  /// تحديد فلتر الحالة على الخادم (الكل / النشطة / المعطلة)
  void setStatusFilter(bool? status) {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    loadPackages(isRefresh: true);
  }

  /// اختيار باقة معينة وعرض تفاصيلها
  void selectPackage(PackageEntity package) {
    selectedPackage.value = package;
  }

  /// جلب تفاصيل أحدث للباقة المحددة
  Future<void> loadPackageDetails(int packageId) async {
    try {
      final details = await getPackageDetailsUseCase(packageId);
      selectedPackage.value = details;

      final index = packages.indexWhere((p) => p.packageId == packageId);
      if (index != -1) {
        packages[index] = details;
        filteredPackages.assignAll(packages);
      }
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'خطأ في جلب التفاصيل',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تحديث بيانات الباقة: $e',
        type: SnackType.error,
      );
    }
  }

  /// تغيير وحدة رصيد البيانات مع التحويل التلقائي للقيمة المدخلة
  void setBalanceUnit(DataUnit newUnit) {
    if (selectedBalanceUnit.value == newUnit) return;
    final currentVal = double.tryParse(balanceController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final converted = PackageSpecFormatter.convertData(
        currentVal,
        selectedBalanceUnit.value,
        newUnit,
      );
      balanceController.text = converted % 1 == 0
          ? converted.toInt().toString()
          : converted.toStringAsFixed(2);
    }
    selectedBalanceUnit.value = newUnit;
  }

  /// تغيير وحدة وقت الاستخدام مع التحويل التلقائي للقيمة المدخلة
  void setUptimeUnit(UptimeUnit newUnit) {
    if (selectedUptimeUnit.value == newUnit) return;
    final currentVal = double.tryParse(uptimeController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final converted = PackageSpecFormatter.convertUptime(
        currentVal,
        selectedUptimeUnit.value,
        newUnit,
      );
      uptimeController.text = converted % 1 == 0
          ? converted.toInt().toString()
          : converted.toStringAsFixed(2);
    }
    selectedUptimeUnit.value = newUnit;
  }

  /// تغيير وحدة فترة الصلاحية مع التحويل التلقائي للقيمة المدخلة
  void setValidityUnit(ValidityUnit newUnit) {
    if (selectedValidityUnit.value == newUnit) return;
    final currentVal = double.tryParse(validityController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final converted = PackageSpecFormatter.convertValidity(
        currentVal,
        selectedValidityUnit.value,
        newUnit,
      );
      validityController.text = converted % 1 == 0
          ? converted.toInt().toString()
          : converted.toStringAsFixed(2);
    }
    selectedValidityUnit.value = newUnit;
  }

  /// تهيئة نموذج الإنشاء
  void initCreateForm({int? networkId}) {
    isEditing.value = false;
    editingPackageId.value = null;

    formNetworkId.value =
        networkId ??
        selectedNetworkId.value ??
        (authorizedNetworks.length == 1
            ? authorizedNetworks.first.networkId
            : null);

    nameController.clear();
    balanceController.clear();
    uptimeController.clear();
    validityController.clear();
    voucherCountController.text = '1';
    priceController.clear();
    cashDiscountController.text = '0.0';
    creditDiscountController.text = '0.0';

    selectedBalanceUnit.value = DataUnit.mb;
    selectedUptimeUnit.value = UptimeUnit.hours;
    selectedValidityUnit.value = ValidityUnit.days;

    selectedColorHex.value = '0xFF0D7A5F';
    packageActiveStatus.value = true;
  }

  /// تهيئة نموذج التعديل لباقة قائمة مع اختيار الوحدات الأنسب
  void initEditForm(PackageEntity pkg) {
    isEditing.value = true;
    editingPackageId.value = pkg.packageId;
    formNetworkId.value = pkg.networkId;

    nameController.text = pkg.packageName;

    // وحدة وقيمة الرصيد
    if (pkg.packageBalance >= 1024 && pkg.packageBalance % 1024 == 0) {
      selectedBalanceUnit.value = DataUnit.gb;
      balanceController.text = (pkg.packageBalance / 1024).toInt().toString();
    } else {
      selectedBalanceUnit.value = DataUnit.mb;
      balanceController.text = pkg.packageBalance > 0
          ? (pkg.packageBalance % 1 == 0
                ? pkg.packageBalance.toInt().toString()
                : pkg.packageBalance.toString())
          : '';
    }

    // وحدة وقيمة وقت الاستخدام
    if (pkg.packageUptime != null &&
        pkg.packageUptime! >= 60 &&
        pkg.packageUptime! % 60 == 0) {
      selectedUptimeUnit.value = UptimeUnit.hours;
      uptimeController.text = (pkg.packageUptime! ~/ 60).toString();
    } else {
      selectedUptimeUnit.value = UptimeUnit.minutes;
      uptimeController.text = pkg.packageUptime != null
          ? pkg.packageUptime.toString()
          : '';
    }

    // وحدة وقيمة مدة الصلاحية
    if (pkg.packageValidity != null &&
        pkg.packageValidity! >= 24 &&
        pkg.packageValidity! % 24 == 0) {
      selectedValidityUnit.value = ValidityUnit.days;
      validityController.text = (pkg.packageValidity! ~/ 24).toString();
    } else {
      selectedValidityUnit.value = ValidityUnit.hours;
      validityController.text = pkg.packageValidity != null
          ? pkg.packageValidity.toString()
          : '';
    }

    voucherCountController.text = pkg.packageVoucherCount.toString();
    priceController.text = pkg.packageVoucherPrice.toString();
    cashDiscountController.text = pkg.packageDefaultCashDiscount.toString();
    creditDiscountController.text = pkg.packageDefaultCreditDiscount.toString();

    selectedColorHex.value = pkg.packageColor ?? '0xFF0D7A5F';
    packageActiveStatus.value = pkg.status;
  }

  /// إرسال وحفظ بيانات الباقة (إنشاء أو تعديل) مع التحقق الحتمي للشبكة والـ Overlay
  Future<bool> submitPackageForm() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // التحقق الحتمي من معرف الشبكة عند الإنشاء
    if (!isEditing.value) {
      if (formNetworkId.value == null) {
        if (authorizedNetworks.length == 1) {
          formNetworkId.value = authorizedNetworks.first.networkId;
        } else if (authorizedNetworks.isEmpty) {
          CustomSnackbar.show(
            title: 'تعذر إنشاء الباقة',
            message: 'لا توجد شبكة معتمدة تابعة لك لإنشاء الباقة فيها.',
            type: SnackType.error,
          );
          return false;
        } else {
          CustomSnackbar.show(
            title: 'تحديد الشبكة مطلوب',
            message: 'يرجى اختيار الشبكة التابعة للباقة أولاً.',
            type: SnackType.warning,
          );
          return false;
        }
      }
    }

    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final cashDiscount =
        double.tryParse(cashDiscountController.text.trim()) ?? 0.0;
    final creditDiscount =
        double.tryParse(creditDiscountController.text.trim()) ?? 0.0;

    // تحويل المواصفات الفنية إلى الوحدات المعيارية المخزنة بالخادم عبر Formatter
    final rawBalance = double.tryParse(balanceController.text.trim());
    final canonicalBalanceMb = rawBalance != null && rawBalance > 0
        ? PackageSpecFormatter.convertData(
            rawBalance,
            selectedBalanceUnit.value,
            DataUnit.mb,
          )
        : null;

    final rawUptime = double.tryParse(uptimeController.text.trim());
    final canonicalUptimeMinutes = rawUptime != null && rawUptime > 0
        ? PackageSpecFormatter.convertUptime(
            rawUptime,
            selectedUptimeUnit.value,
            UptimeUnit.minutes,
          ).toInt()
        : null;

    final rawValidity = double.tryParse(validityController.text.trim());
    final canonicalValidityHours = rawValidity != null && rawValidity > 0
        ? PackageSpecFormatter.convertValidity(
            rawValidity,
            selectedValidityUnit.value,
            ValidityUnit.hours,
          ).toInt()
        : null;

    isSaving.value = true;
    await CustomAnimationOverlay.showLoading(
      message: isEditing.value
          ? 'جاري تحديث بيانات الباقة...'
          : 'جاري إنشاء باقة الكروت...',
    );

    try {
      final payload = <String, dynamic>{
        'package_name': nameController.text.trim(),
        'package_color': selectedColorHex.value,
        'package_balance': canonicalBalanceMb?.toString(),
        'package_uptime': canonicalUptimeMinutes?.toString(),
        'package_validity': canonicalValidityHours?.toString(),
        'package_voucher_count':
            int.tryParse(voucherCountController.text.trim()) ?? 1,
        'package_voucher_price': price,
        'package_default_cash_discount': cashDiscount,
        'package_default_credit_discount': creditDiscount,
        'status': packageActiveStatus.value,
      };

      if (!isEditing.value) {
        payload['network_id'] = formNetworkId.value!;
        final created = await createPackageUseCase(payload);
        packages.insert(0, created);
        filteredPackages.assignAll(packages);
        selectedPackage.value = created;

        await CustomAnimationOverlay.showSuccess(
          message: 'تم إنشاء باقة الكروت بنجاح',
        );
        CustomSnackbar.show(
          title: 'نجاح العملية',
          message: 'تم إضافة باقة "${created.packageName}" للكتالوج.',
          type: SnackType.success,
        );
      } else {
        final id = editingPackageId.value!;
        final updated = await updatePackageUseCase(id, payload);
        final index = packages.indexWhere((p) => p.packageId == id);
        if (index != -1) {
          packages[index] = updated;
        }
        filteredPackages.assignAll(packages);
        selectedPackage.value = updated;

        await CustomAnimationOverlay.showSuccess(
          message: 'تم تحديث بيانات الباقة بنجاح',
        );
        CustomSnackbar.show(
          title: 'نجاح التحديث',
          message: 'تم تعديل باقة "${updated.packageName}" بنجاح.',
          type: SnackType.success,
        );
      }

      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل حفظ الباقة',
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
        message: 'تعذر إتمام عملية الحفظ: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isSaving.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// إرسال وحفظ بيانات الباقة وإغلاق الشاشة عند النجاح
  Future<void> savePackage() async {
    final success = await submitPackageForm();
    if (success) {
      Get.back<void>();
    }
  }

  /// تبديل حالة تفعيل الباقة (نشطة / معطلة) مع Overlay و Snackbar
  Future<void> togglePackageStatus(PackageEntity package) async {
    isTogglingStatus.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تغيير حالة تفعيل الباقة...',
    );

    try {
      final updated = await togglePackageStatusUseCase(package.packageId);

      final index = packages.indexWhere(
        (p) => p.packageId == package.packageId,
      );
      if (index != -1) {
        packages[index] = updated;
      }
      if (selectedPackage.value?.packageId == package.packageId) {
        selectedPackage.value = updated;
      }

      filteredPackages.assignAll(packages);

      final stateLabel = updated.status ? 'تفعيل' : 'تعطيل';
      await CustomAnimationOverlay.showSuccess(
        message: 'تم $stateLabel باقة "${updated.packageName}" بنجاح',
      );
      CustomSnackbar.show(
        title: 'تغيير الحالة',
        message: 'تم $stateLabel باقة "${updated.packageName}" بنجاح.',
        type: SnackType.success,
      );
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر تغيير الحالة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر تعديل حالة الباقة: $e',
        type: SnackType.error,
      );
    } finally {
      isTogglingStatus.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// حذف باقة كروت من النظام مع Overlay و Snackbar
  Future<bool> deletePackage(int packageId) async {
    isDeleting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري نقل الباقة إلى المحذوفات...',
    );

    try {
      final success = await deletePackageUseCase(packageId);
      if (success) {
        packages.removeWhere((p) => p.packageId == packageId);
        filteredPackages.assignAll(packages);
        if (selectedPackage.value?.packageId == packageId) {
          selectedPackage.value = null;
        }

        await CustomAnimationOverlay.showSuccess(
          message: 'تم نقل باقة الكروت إلى سلة المحذوفات بنجاح',
        );
        CustomSnackbar.show(
          title: 'حذف الباقة',
          message: 'تم حذف الباقة بنجاح من كتالوج الشبكة.',
          type: SnackType.success,
        );
        return true;
      }
      return false;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر حذف الباقة',
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
      isDeleting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// طلب تأكيد حذف الباقة وإغلاق شاشة التفاصيل عند إتمام الحذف
  void promptDeletePackage(PackageEntity package) {
    PackageDeleteConfirmDialog.show(
      packageName: package.packageName,
      onConfirm: () async {
        final deleted = await deletePackage(package.packageId);
        if (deleted) Get.back<void>();
      },
    );
  }
}
