import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/package_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/widgets/dialogs/package_action_dialogs.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة كتالوج باقات الكروت والأسعار التعاقدية للشبكة
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

  // ── الحالة التفاعلية للقائمة ──
  final packages = <PackageEntity>[].obs;
  final filteredPackages = <PackageEntity>[].obs;
  final selectedPackage = Rxn<PackageEntity>();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final isTogglingStatus = false.obs;
  final errorMessage = RxnString();
  final loadMoreError = RxnString();
  final nextCursor = RxnString();
  int _packageListRevision = 0;

  bool get hasMore => nextCursor.value != null;

  // ── حقول التصفية والبحث ──
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = RxnBool(); // null = all, true = active, false = inactive
  final selectedNetworkId = RxnInt();
  final expandedPackageId = RxnInt();

  // ── إدارة الشبكات المصرحة ──
  final authorizedNetworks = <NetworkEntity>[].obs;
  final isLoadingNetworks = false.obs;
  final formNetworkId = RxnInt();

  // ── إدارة النموذج (Form Management) ──
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final uptimeController = TextEditingController();
  final validityController = TextEditingController();
  final voucherCountController = TextEditingController(text: '51');
  final priceController = TextEditingController();
  final cashDiscountController = TextEditingController(text: '0.0');
  final creditDiscountController = TextEditingController(text: '0.0');

  // محددات الوحدات الفنية
  final selectedBalanceUnit = ValueNotifier<DataSizeUnit>(DataSizeUnit.megabytes);
  final selectedUptimeUnit = ValueNotifier<TimeDurationUnit>(TimeDurationUnit.hours);
  final selectedValidityUnit = ValueNotifier<TimeDurationUnit>(TimeDurationUnit.days);

  final selectedColorHex = '0xFF0D7A5F'.obs;
  final packageActiveStatus = true.obs;
  final isEditing = false.obs;
  final editingPackageId = RxnInt();

  // ── مؤشرات الحساب الإحصائي للـ KPI ──
  int get totalPackagesCount => packages.length;
  int get activePackagesCount => packages.where((p) => p.isActive).length;
  int get inactivePackagesCount => packages.where((p) => !p.isActive).length;

  // ── فحص الصلاحيات الأمنية ──
  bool get canCreatePackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesCreate);
  bool get canEditPackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesEdit);
  bool get canDeletePackage =>
      PermissionService.to.can(AppPermissions.voucherPackagesDelete);

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => _applyFiltersLocally(),
      time: const Duration(milliseconds: 300),
    );

    loadAuthorizedNetworks();
    loadPackages();
  }

  @override
  void onClose() {
    _packageListRevision++;
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

  // ── بناء بطاقات المؤشرات الإحصائية (CustomKpiCardData) ──
  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final activePres = EnumPresentationRegistry.resolvePackageStatus(
      PackageStatus.active,
    );
    final inactivePres = EnumPresentationRegistry.resolvePackageStatus(
      PackageStatus.inactive,
    );

    return [
      CustomKpiCardData(
        label: 'الكل',
        count: totalPackagesCount,
        icon: Icons.inventory_2_rounded,
        accentColor: colors.primary,
        statusKey: null,
      ),
      CustomKpiCardData(
        label: activePres.label,
        count: activePackagesCount,
        icon: activePres.icon ?? Icons.check_circle_rounded,
        accentColor: activePres.tone.color(context),
        statusKey: PackageStatus.active.wireValue,
      ),
      CustomKpiCardData(
        label: inactivePres.label,
        count: inactivePackagesCount,
        icon: inactivePres.icon ?? Icons.pause_circle_outline_rounded,
        accentColor: inactivePres.tone.color(context),
        statusKey: PackageStatus.inactive.wireValue,
      ),
    ];
  }

  // ── بناء خيارات التصفية لشريط البحث الموحد ──
  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    return [
      const CustomSearchFilterOption<String?>(
        label: 'جميع الحالات',
        value: null,
        icon: Icons.all_inbox_rounded,
      ),
      for (final PackageStatus status in PackageStatus.values.where(
        (PackageStatus s) => s.isKnown,
      ))
        CustomSearchFilterOption<String?>(
          label: EnumPresentationRegistry.resolvePackageStatus(status).label,
          value: status.wireValue,
          icon:
              EnumPresentationRegistry.resolvePackageStatus(status).icon ??
              Icons.label_outline_rounded,
        ),
    ];
  }

  String? get currentFilterKey {
    final val = statusFilter.value;
    if (val == null) return null;
    return val ? PackageStatus.active.wireValue : PackageStatus.inactive.wireValue;
  }

  void onFilterKeySelected(String? key) {
    if (key == null) {
      setStatusFilter(null);
    } else if (key == PackageStatus.active.wireValue) {
      setStatusFilter(true);
    } else if (key == PackageStatus.inactive.wireValue) {
      setStatusFilter(false);
    }
  }

  // ── جلب باقات الكروت ──
  Future<void> loadPackages({int? networkId, bool isRefresh = false}) async {
    final currentRevision = ++_packageListRevision;
    if (isRefresh) {
      nextCursor.value = null;
    }
    isLoading.value = true;
    errorMessage.value = null;

    final targetNetworkId = networkId ??
        selectedNetworkId.value ??
        (authorizedNetworks.isNotEmpty
            ? WorkspaceService.to.resolveActiveNetworkId(
                authorizedNetworks.map((n) => n.networkId).toList(),
              )
            : null);

    try {
      final PaginatedList<PackageEntity> result;
      if (targetNetworkId != null) {
        result = await getNetworkPackagesUseCase(
          targetNetworkId,
          cursor: isRefresh ? null : nextCursor.value,
        );
      } else {
        result = await getPackagesUseCase(
          cursor: isRefresh ? null : nextCursor.value,
        );
      }

      if (_packageListRevision != currentRevision) return;

      packages.assignAll(result.items);
      nextCursor.value = result.nextCursor;
      _applyFiltersLocally();
    } on AppException catch (e) {
      if (_packageListRevision != currentRevision) return;
      errorMessage.value = e.message;
    } catch (e) {
      if (_packageListRevision != currentRevision) return;
      errorMessage.value = 'تعذر تحميل باقات الكروت: $e';
    } finally {
      if (_packageListRevision == currentRevision) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMorePackages() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    loadMoreError.value = null;

    final targetNetworkId = selectedNetworkId.value ??
        (authorizedNetworks.isNotEmpty
            ? WorkspaceService.to.resolveActiveNetworkId(
                authorizedNetworks.map((n) => n.networkId).toList(),
              )
            : null);

    try {
      final PaginatedList<PackageEntity> result;
      if (targetNetworkId != null) {
        result = await getNetworkPackagesUseCase(
          targetNetworkId,
          cursor: nextCursor.value,
        );
      } else {
        result = await getPackagesUseCase(
          cursor: nextCursor.value,
        );
      }

      final existingIds = packages.map((p) => p.packageId).toSet();
      final newItems =
          result.items.where((p) => !existingIds.contains(p.packageId)).toList();

      packages.addAll(newItems);
      nextCursor.value = result.nextCursor;
      _applyFiltersLocally();
    } on AppException catch (e) {
      loadMoreError.value = e.message;
    } catch (e) {
      loadMoreError.value = 'تعذر تحميل المزيد من الباقات: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshCatalog() => loadPackages(isRefresh: true);

  void _applyFiltersLocally() {
    final query = searchQuery.value.trim().toLowerCase();
    final currentStatus = statusFilter.value;

    final filtered = packages.where((pkg) {
      if (currentStatus != null && pkg.status != currentStatus) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesName = pkg.packageName.toLowerCase().contains(query);
        final matchesId = pkg.packageId.toString().contains(query);
        if (!matchesName && !matchesId) return false;
      }
      return true;
    }).toList();

    filteredPackages.assignAll(filtered);
  }

  void setStatusFilter(dynamic status) {
    if (status is bool?) {
      statusFilter.value = status;
    } else if (status is String) {
      if (status == PackageStatus.active.wireValue) {
        statusFilter.value = true;
      } else if (status == PackageStatus.inactive.wireValue) {
        statusFilter.value = false;
      } else {
        statusFilter.value = null;
      }
    } else {
      statusFilter.value = null;
    }
    _applyFiltersLocally();
  }

  void toggleAccordion(int packageId) {
    if (expandedPackageId.value == packageId) {
      expandedPackageId.value = null;
    } else {
      expandedPackageId.value = packageId;
    }
  }

  void selectPackage(PackageEntity package) {
    selectedPackage.value = package;
  }

  Future<void> loadPackageDetails(int packageId) async {
    try {
      final details = await getPackageDetailsUseCase(packageId);
      selectedPackage.value = details;
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ في جلب التفاصيل',
        message: e.toString(),
        type: SnackType.error,
      );
    }
  }

  void openPackageDetails(PackageEntity package) {
    selectedPackage.value = package;
    Get.toNamed<void>(AppRoutes.packageDetails);
  }

  // ── إدارة الشبكات ──
  Future<void> loadAuthorizedNetworks() async {
    if (getMyNetworksUseCase == null) return;
    isLoadingNetworks.value = true;
    try {
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);
      if (formNetworkId.value == null && networks.isNotEmpty) {
        final activeId = WorkspaceService.to.resolveActiveNetworkId(
          networks.map((n) => n.networkId).toList(),
        );
        formNetworkId.value = activeId ?? networks.first.networkId;
      }
    } catch (_) {
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  // ── إدارة وحدات القياس الفنية ──
  void setBalanceUnit(DataSizeUnit newUnit) {
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
          : converted.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }
    selectedBalanceUnit.value = newUnit;
  }

  void setUptimeUnit(TimeDurationUnit newUnit) {
    if (selectedUptimeUnit.value == newUnit) return;
    final currentVal = double.tryParse(uptimeController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final converted = PackageSpecFormatter.convertDuration(
        currentVal,
        selectedUptimeUnit.value,
        newUnit,
      );
      uptimeController.text = converted % 1 == 0
          ? converted.toInt().toString()
          : converted.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }
    selectedUptimeUnit.value = newUnit;
  }

  void setValidityUnit(TimeDurationUnit newUnit) {
    if (selectedValidityUnit.value == newUnit) return;
    final currentVal = double.tryParse(validityController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final converted = PackageSpecFormatter.convertDuration(
        currentVal,
        selectedValidityUnit.value,
        newUnit,
      );
      validityController.text = converted % 1 == 0
          ? converted.toInt().toString()
          : converted.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }
    selectedValidityUnit.value = newUnit;
  }

  // ── إدارة نماذج الإنشاء والتعديل ──
  void initCreateForm({int? networkId}) {
    isEditing.value = false;
    editingPackageId.value = null;

    formNetworkId.value = networkId ??
        selectedNetworkId.value ??
        (authorizedNetworks.length == 1
            ? authorizedNetworks.first.networkId
            : null);

    nameController.clear();
    balanceController.clear();
    uptimeController.clear();
    validityController.clear();
    voucherCountController.text = '51';
    priceController.clear();
    cashDiscountController.text = '0.0';
    creditDiscountController.text = '0.0';

    selectedBalanceUnit.value = DataSizeUnit.megabytes;
    selectedUptimeUnit.value = TimeDurationUnit.hours;
    selectedValidityUnit.value = TimeDurationUnit.days;
    selectedColorHex.value = '0xFF0D7A5F';
    packageActiveStatus.value = true;
  }

  void initEditForm(PackageEntity pkg) {
    isEditing.value = true;
    editingPackageId.value = pkg.packageId;
    formNetworkId.value = pkg.networkId;

    nameController.text = pkg.packageName;

    // حل الوحدة الأنسب لرصيد البيانات بالبايت
    if (pkg.packageBalance > 0) {
      final bestDataUnit = DataSizeUnit.resolveBestUnit(pkg.packageBalance);
      selectedBalanceUnit.value = bestDataUnit;
      final val = PackageSpecFormatter.fromCanonicalBytes(pkg.packageBalance, bestDataUnit);
      balanceController.text = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(2);
    } else {
      selectedBalanceUnit.value = DataSizeUnit.megabytes;
      balanceController.clear();
    }

    // حل الوحدة الأنسب لوقت الاتصال بالدقائق
    if (pkg.packageUptime != null && pkg.packageUptime! > 0) {
      final bestUptimeUnit = TimeDurationUnit.resolveBestUnit(pkg.packageUptime!);
      selectedUptimeUnit.value = bestUptimeUnit;
      final val = PackageSpecFormatter.fromCanonicalMinutes(pkg.packageUptime!, bestUptimeUnit);
      uptimeController.text = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    } else {
      selectedUptimeUnit.value = TimeDurationUnit.hours;
      uptimeController.clear();
    }

    // حل الوحدة الأنسب لفترة الصلاحية بالدقائق
    if (pkg.packageValidity != null && pkg.packageValidity! > 0) {
      final bestValidityUnit = TimeDurationUnit.resolveBestUnit(pkg.packageValidity!);
      selectedValidityUnit.value = bestValidityUnit;
      final val = PackageSpecFormatter.fromCanonicalMinutes(pkg.packageValidity!, bestValidityUnit);
      validityController.text = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    } else {
      selectedValidityUnit.value = TimeDurationUnit.days;
      validityController.clear();
    }

    voucherCountController.text = pkg.packageVoucherCount.toString();
    priceController.text = pkg.packageVoucherPrice.toString();
    cashDiscountController.text = pkg.packageDefaultCashDiscount.toString();
    creditDiscountController.text = pkg.packageDefaultCreditDiscount.toString();

    selectedColorHex.value = pkg.packageColor ?? '0xFF0D7A5F';
    packageActiveStatus.value = pkg.status;
  }

  Future<bool> submitPackageForm() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!isEditing.value) {
      if (formNetworkId.value == null) {
        if (authorizedNetworks.length == 1) {
          formNetworkId.value = authorizedNetworks.first.networkId;
        } else if (authorizedNetworks.isEmpty) {
          final resolved = WorkspaceService.to.resolveActiveNetworkId([]);
          if (resolved != null) {
            formNetworkId.value = resolved;
          } else {
            CustomSnackbar.show(
              title: 'الشبكة مطلوبة',
              message: 'لم يتم العثور على شبكة معتمدة لربط الباقة بها.',
              type: SnackType.warning,
            );
            return false;
          }
        }
      }
    }

    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final cashDiscount =
        double.tryParse(cashDiscountController.text.trim()) ?? 0.0;
    final creditDiscount =
        double.tryParse(creditDiscountController.text.trim()) ?? 0.0;

    final rawBalance = double.tryParse(balanceController.text.trim());
    final canonicalBalanceBytes = (rawBalance != null && rawBalance > 0)
        ? PackageSpecFormatter.toCanonicalBytes(
            rawBalance,
            selectedBalanceUnit.value,
          )
        : 0;

    final rawUptime = double.tryParse(uptimeController.text.trim());
    final canonicalUptimeMinutes = (rawUptime != null && rawUptime > 0)
        ? PackageSpecFormatter.toCanonicalMinutes(
            rawUptime,
            selectedUptimeUnit.value,
          )
        : null;

    final rawValidity = double.tryParse(validityController.text.trim());
    final canonicalValidityMinutes = (rawValidity != null && rawValidity > 0)
        ? PackageSpecFormatter.toCanonicalMinutes(
            rawValidity,
            selectedValidityUnit.value,
          )
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
        'package_balance': canonicalBalanceBytes,
        'package_uptime': canonicalUptimeMinutes,
        'package_validity': canonicalValidityMinutes,
        'package_voucher_count':
            int.tryParse(voucherCountController.text.trim()) ?? 51,
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
          title: 'إنشاء الباقة',
          message: 'تمت إضافة باقة "${created.packageName}" بنجاح.',
          type: SnackType.success,
        );
      } else {
        final updated = await updatePackageUseCase(
          editingPackageId.value!,
          payload,
        );

        final index = packages.indexWhere(
          (p) => p.packageId == editingPackageId.value,
        );
        if (index != -1) {
          packages[index] = updated;
        }
        if (selectedPackage.value?.packageId == editingPackageId.value) {
          selectedPackage.value = updated;
        }
        filteredPackages.assignAll(packages);

        await CustomAnimationOverlay.showSuccess(
          message: 'تم حفظ تعديلات الباقة بنجاح',
        );
        CustomSnackbar.show(
          title: 'تعديل الباقة',
          message: 'تم تحديث بيانات باقة "${updated.packageName}" بنجاح.',
          type: SnackType.success,
        );
      }
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر حفظ الباقة',
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

  Future<void> savePackage() async {
    final success = await submitPackageForm();
    if (success) {
      Get.back<void>();
    }
  }

  // ── تبديل الحالة والحذف ──
  Future<void> togglePackageStatus(PackageEntity package) async {
    isTogglingStatus.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تغيير حالة تفعيل الباقة...',
    );

    try {
      final updated = await togglePackageStatusUseCase(package.packageId);

      final index = packages.indexWhere((p) => p.packageId == package.packageId);
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

  void promptToggleStatus(PackageEntity package) {
    PackageActionDialogs.showToggleStatusDialog(
      packageName: package.packageName,
      willDeactivate: package.isActive,
      onConfirm: () => togglePackageStatus(package),
    );
  }

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

  void promptDeletePackage(PackageEntity package) {
    PackageActionDialogs.showDeletePackageDialog(
      packageName: package.packageName,
      onConfirm: () async {
        final deleted = await deletePackage(package.packageId);
        if (deleted && Get.currentRoute == AppRoutes.packageDetails) {
          Get.back<void>();
        }
      },
    );
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    refreshCatalog();
  }
}
