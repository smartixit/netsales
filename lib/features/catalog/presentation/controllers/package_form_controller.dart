import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/create_package_input.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/entities/update_package_input.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إدارة نموذج إنشاء وتعديل باقة كروت الإنترنت (PackageFormController)
///
/// يدعم استوديو المحاكاة التفاعلية الحية (Live Voucher Studio):
/// - يراقب كل مدخل لحظياً ويوفر كيان [livePreviewPackage] يتفاعل فوراً مع شاشة المعاينة.
/// - يخزن البيانات بوحداتها المعيارية الدقيقة (البايت للسعة، والدقائق للمدد والزمن) عبر [PackageSpecFormatter].
/// - يقوم بحسابات المعاينة التقديرية الحية للشاشة فقط بدون ادعاء أي سلطة محاسبية نهائية.
class PackageFormController extends GetxController {
  final CreatePackageUseCase createPackageUseCase;
  final UpdatePackageUseCase updatePackageUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  PackageFormController({
    required this.createPackageUseCase,
    required this.updatePackageUseCase,
    this.getMyNetworksUseCase,
  });

  final formKey = GlobalKey<FormState>();

  // حقول الإدخال النصية
  final nameController = TextEditingController();
  final voucherCountController = TextEditingController(text: '51');
  final balanceController = TextEditingController();
  final uptimeController = TextEditingController();
  final validityController = TextEditingController();
  final priceController = TextEditingController();
  final cashDiscountController = TextEditingController(text: '0.0');
  final creditDiscountController = TextEditingController(text: '0.0');

  // الحالات التفاعلية
  final isEditing = false.obs;
  final packageId = Rxn<int>();
  final selectedNetworkId = Rxn<int>();
  final selectedColor = Rxn<String>();
  final status = true.obs;

  // محددات الوحدات القياسية المعتمدة
  final selectedBalanceUnit = DataSizeUnit.gigabytes.obs;
  final selectedUptimeUnit = TimeDurationUnit.hours.obs;
  final selectedValidityUnit = TimeDurationUnit.days.obs;

  // الحالات التشغيلية
  final isSaving = false.obs;
  final isLoadingNetworks = false.obs;
  final authorizedNetworks = <NetworkEntity>[].obs;

  // المراقبة الحية للحسابات والمعاينة التفاعلية في الاستوديو
  final livePackageName = ''.obs;
  final liveVoucherCount = 51.obs;
  final liveBalanceInBytes = 0.obs;
  final liveUptimeInMinutes = Rxn<int>();
  final liveValidityInMinutes = Rxn<int>();
  final liveBasePrice = 0.0.obs;
  final liveCashDiscount = 0.0.obs;
  final liveCreditDiscount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupLiveCalculations();
    _initializeForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    voucherCountController.dispose();
    balanceController.dispose();
    uptimeController.dispose();
    validityController.dispose();
    priceController.dispose();
    cashDiscountController.dispose();
    creditDiscountController.dispose();
    super.onClose();
  }

  /// إعداد مستمعين لتحديث كرت المعاينة ثلاثي الأبعاد ورادار الأرباح بشكل حي وفوري
  void _setupLiveCalculations() {
    nameController.addListener(() {
      livePackageName.value = nameController.text;
    });

    voucherCountController.addListener(() {
      liveVoucherCount.value =
          int.tryParse(voucherCountController.text.trim()) ?? 1;
    });

    void updateBalance() {
      final raw = double.tryParse(balanceController.text.trim()) ?? 0.0;
      liveBalanceInBytes.value = PackageSpecFormatter.toCanonicalBytes(
        raw,
        selectedBalanceUnit.value,
      );
    }

    balanceController.addListener(updateBalance);
    ever(selectedBalanceUnit, (_) => updateBalance());

    void updateUptime() {
      final raw = double.tryParse(uptimeController.text.trim());
      liveUptimeInMinutes.value = raw != null && raw > 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              raw,
              selectedUptimeUnit.value,
            )
          : null;
    }

    uptimeController.addListener(updateUptime);
    ever(selectedUptimeUnit, (_) => updateUptime());

    void updateValidity() {
      final raw = double.tryParse(validityController.text.trim());
      liveValidityInMinutes.value = raw != null && raw > 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              raw,
              selectedValidityUnit.value,
            )
          : null;
    }

    validityController.addListener(updateValidity);
    ever(selectedValidityUnit, (_) => updateValidity());

    priceController.addListener(() {
      liveBasePrice.value = double.tryParse(priceController.text) ?? 0.0;
    });
    cashDiscountController.addListener(() {
      liveCashDiscount.value =
          double.tryParse(cashDiscountController.text) ?? 0.0;
    });
    creditDiscountController.addListener(() {
      liveCreditDiscount.value =
          double.tryParse(creditDiscountController.text) ?? 0.0;
    });
  }

  /// كيان الباقة الحي المخصص للمعاينة التفاعلية المباشرة (Live Simulator Entity)
  PackageEntity get livePreviewPackage {
    final count = liveVoucherCount.value > 0 ? liveVoucherCount.value : 1;
    final basePrice = liveBasePrice.value;
    final cashPrice = estimatedCashPrice;
    final creditPrice = estimatedCreditPrice;
    final cashSavings = estimatedCashDiscountAmount;
    final creditSavings = estimatedCreditDiscountAmount;

    return PackageEntity(
      packageId: packageId.value ?? 0,
      networkId: selectedNetworkId.value ?? 0,
      packageName: livePackageName.value.trim().isNotEmpty
          ? livePackageName.value.trim()
          : 'اسم الباقة الجديدة',
      packageColor: selectedColor.value,
      packageBalance: liveBalanceInBytes.value,
      packageUptime: liveUptimeInMinutes.value,
      packageValidity: liveValidityInMinutes.value,
      packageVoucherCount: count,
      packageVoucherPrice: basePrice,
      packageDefaultCashDiscount: liveCashDiscount.value,
      packageDefaultCreditDiscount: liveCreditDiscount.value,
      cashDiscountAmount: cashSavings,
      creditDiscountAmount: creditSavings,
      effectiveCashPrice: cashPrice,
      effectiveCreditPrice: creditPrice,
      status: status.value,
      networkName: authorizedNetworks
          .firstWhereOrNull((net) => net.networkId == selectedNetworkId.value)
          ?.networkName,
    );
  }

  /// تهيئة النموذج واكتشاف حالة التعديل أو الإنشاء
  Future<void> _initializeForm() async {
    final activeTenantId = WorkspaceService.instance.savedActiveNetworkId;
    selectedNetworkId.value = activeTenantId;

    if (getMyNetworksUseCase != null) {
      await _loadAuthorizedNetworks();
    }

    final dynamic args = Get.arguments;
    if (args is PackageEntity) {
      _populateFromPackage(args);
    }
  }

  /// جلب الشبكات المصرح للمستخدم إدارتها
  Future<void> _loadAuthorizedNetworks() async {
    try {
      isLoadingNetworks.value = true;
      final networks = await getMyNetworksUseCase!();
      authorizedNetworks.assignAll(networks);

      if (selectedNetworkId.value == null && networks.isNotEmpty) {
        selectedNetworkId.value = networks.first.networkId;
      }
    } catch (_) {
      // التعامل الصامت مع أخطاء جلب الشبكات واستخدام المعرف النشط
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// تعبئة حقول النموذج من باقة قائمة في حالة التعديل
  void _populateFromPackage(PackageEntity package) {
    isEditing.value = true;
    packageId.value = package.packageId;
    selectedNetworkId.value = package.networkId;
    nameController.text = package.packageName;
    livePackageName.value = package.packageName;
    selectedColor.value = package.packageColor;

    // استخراج أفضل وحدة لعرض الرصيد بالاعتماد على الحجم الفعلي
    if (package.packageBalance > 0) {
      final bestUnit = DataSizeUnit.resolveBestUnit(package.packageBalance);
      selectedBalanceUnit.value = bestUnit;
      final valueInUnit = bestUnit.fromCanonicalBytes(package.packageBalance);
      balanceController.text = valueInUnit == valueInUnit.roundToDouble()
          ? valueInUnit.toInt().toString()
          : valueInUnit.toString();
      liveBalanceInBytes.value = package.packageBalance;
    } else {
      balanceController.text = '0';
      liveBalanceInBytes.value = 0;
    }

    // استخراج وقت الاستخدام بوحدته المناسبة
    if (package.packageUptime != null && package.packageUptime! > 0) {
      final bestUnit = TimeDurationUnit.resolveBestUnit(
        package.packageUptime!,
        defaultUnit: TimeDurationUnit.hours,
      );
      selectedUptimeUnit.value = bestUnit;
      final valInUnit = bestUnit.fromCanonicalMinutes(package.packageUptime!);
      uptimeController.text = valInUnit == valInUnit.roundToDouble()
          ? valInUnit.toInt().toString()
          : valInUnit.toString();
      liveUptimeInMinutes.value = package.packageUptime;
    }

    // استخراج فترة الصلاحية بوحدتها المناسبة
    if (package.packageValidity != null && package.packageValidity! > 0) {
      final bestUnit = TimeDurationUnit.resolveBestUnit(
        package.packageValidity!,
        defaultUnit: TimeDurationUnit.days,
      );
      selectedValidityUnit.value = bestUnit;
      final valInUnit = bestUnit.fromCanonicalMinutes(package.packageValidity!);
      validityController.text = valInUnit == valInUnit.roundToDouble()
          ? valInUnit.toInt().toString()
          : valInUnit.toString();
      liveValidityInMinutes.value = package.packageValidity;
    }

    voucherCountController.text = package.packageVoucherCount.toString();
    liveVoucherCount.value = package.packageVoucherCount;
    priceController.text = package.packageVoucherPrice.toString();
    liveBasePrice.value = package.packageVoucherPrice;
    cashDiscountController.text = package.packageDefaultCashDiscount.toString();
    liveCashDiscount.value = package.packageDefaultCashDiscount;
    creditDiscountController.text = package.packageDefaultCreditDiscount
        .toString();
    liveCreditDiscount.value = package.packageDefaultCreditDiscount;
    status.value = package.isActive;
  }

  // ── الحسابات التقديرية الحية للشاشة ──
  double get estimatedCashDiscountAmount =>
      liveBasePrice.value * (liveCashDiscount.value / 100.0);

  double get estimatedCreditDiscountAmount =>
      liveBasePrice.value * (liveCreditDiscount.value / 100.0);

  double get estimatedCashPrice =>
      (liveBasePrice.value - estimatedCashDiscountAmount).clamp(
        0.0,
        double.infinity,
      );

  double get estimatedCreditPrice =>
      (liveBasePrice.value - estimatedCreditDiscountAmount).clamp(
        0.0,
        double.infinity,
      );

  /// تغيير وحدة رصيد البيانات مع تحويل القيمة المدخلة تلقائياً
  void setBalanceUnit(DataSizeUnit newUnit) {
    if (selectedBalanceUnit.value == newUnit) return;
    final currentVal = double.tryParse(balanceController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final bytes = selectedBalanceUnit.value.toCanonicalBytes(currentVal);
      final inNewUnit = newUnit.fromCanonicalBytes(bytes);
      final formatted = inNewUnit == inNewUnit.roundToDouble()
          ? inNewUnit.toInt().toString()
          : inNewUnit.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
      balanceController.text = formatted;
    }
    selectedBalanceUnit.value = newUnit;
  }

  /// تغيير وحدة وقت الاستخدام مع تحويل القيمة المدخلة تلقائياً
  void setUptimeUnit(TimeDurationUnit newUnit) {
    if (selectedUptimeUnit.value == newUnit) return;
    final currentVal = double.tryParse(uptimeController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final minutes = selectedUptimeUnit.value.toCanonicalMinutes(currentVal);
      final inNewUnit = newUnit.fromCanonicalMinutes(minutes);
      final formatted = inNewUnit == inNewUnit.roundToDouble()
          ? inNewUnit.toInt().toString()
          : inNewUnit.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
      uptimeController.text = formatted;
    }
    selectedUptimeUnit.value = newUnit;
  }

  /// تغيير وحدة فترة الصلاحية مع تحويل القيمة المدخلة تلقائياً
  void setValidityUnit(TimeDurationUnit newUnit) {
    if (selectedValidityUnit.value == newUnit) return;
    final currentVal = double.tryParse(validityController.text.trim());
    if (currentVal != null && currentVal > 0) {
      final minutes = selectedValidityUnit.value.toCanonicalMinutes(currentVal);
      final inNewUnit = newUnit.fromCanonicalMinutes(minutes);
      final formatted = inNewUnit == inNewUnit.roundToDouble()
          ? inNewUnit.toInt().toString()
          : inNewUnit.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
      validityController.text = formatted;
    }
    selectedValidityUnit.value = newUnit;
  }

  /// إرسال النموذج وحفظ التعديلات أو إنشاء الباقة الجديدة
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedNetworkId.value == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى تحديد شبكة الكروت التابعة للباقة أولاً.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      isSaving.value = true;
      await CustomAnimationOverlay.showLoading(
        message: isEditing.value
            ? 'جاري حفظ تعديلات الباقة...'
            : 'جاري إنشاء باقة الكروت الجديدة...',
      );

      // تحويل القيم المدخلة للوحدات المعتمدة عبر PackageSpecFormatter
      final rawBalance = double.tryParse(balanceController.text.trim()) ?? 0.0;
      final balanceInBytes = PackageSpecFormatter.toCanonicalBytes(
        rawBalance,
        selectedBalanceUnit.value,
      );

      final rawUptime = double.tryParse(uptimeController.text.trim());
      final uptimeInMinutes = rawUptime != null && rawUptime > 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              rawUptime,
              selectedUptimeUnit.value,
            )
          : null;

      final rawValidity = double.tryParse(validityController.text.trim());
      final validityInMinutes = rawValidity != null && rawValidity > 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              rawValidity,
              selectedValidityUnit.value,
            )
          : null;

      final voucherCount =
          int.tryParse(voucherCountController.text.trim()) ?? 1;
      final voucherPrice = double.tryParse(priceController.text.trim()) ?? 0.0;
      final cashDiscount =
          double.tryParse(cashDiscountController.text.trim()) ?? 0.0;
      final creditDiscount =
          double.tryParse(creditDiscountController.text.trim()) ?? 0.0;

      if (isEditing.value) {
        final updateInput = UpdatePackageInput(
          packageName: nameController.text.trim(),
          packageColor: selectedColor.value,
          packageBalance: balanceInBytes,
          packageUptime: uptimeInMinutes,
          packageValidity: validityInMinutes,
          packageVoucherCount: voucherCount,
          packageVoucherPrice: voucherPrice,
          packageDefaultCashDiscount: cashDiscount,
          packageDefaultCreditDiscount: creditDiscount,
          status: status.value,
        );

        await updatePackageUseCase(packageId.value!, updateInput);
      } else {
        final createInput = CreatePackageInput(
          networkId: selectedNetworkId.value!,
          packageName: nameController.text.trim(),
          packageColor: selectedColor.value,
          packageBalance: balanceInBytes,
          packageUptime: uptimeInMinutes,
          packageValidity: validityInMinutes,
          packageVoucherCount: voucherCount,
          packageVoucherPrice: voucherPrice,
          packageDefaultCashDiscount: cashDiscount,
          packageDefaultCreditDiscount: creditDiscount,
          status: status.value,
        );

        await createPackageUseCase(createInput);
      }

      if (Get.isRegistered<PackageCatalogController>()) {
        unawaited(Get.find<PackageCatalogController>().refreshCatalog());
      }

      CustomSnackbar.show(
        title: isEditing.value ? 'تم التعديل بنجاح' : 'تم الإنشاء بنجاح',
        message: isEditing.value
            ? 'تم حفظ تعديلات باقة الكروت بنجاح.'
            : 'تمت إضافة باقة الكروت الجديدة للكتالوج بنجاح.',
        type: SnackType.success,
      );

      Get.back<void>();
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSaving.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
