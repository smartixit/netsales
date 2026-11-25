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
  final networkLoadError = RxnString();
  final List<Worker> _workers = <Worker>[];

  // المراقبة الحية للحسابات والمعاينة التفاعلية في الاستوديو
  final livePackageName = ''.obs;
  final liveVoucherCount = 51.obs;
  final liveBalanceInBytes = 0.obs;
  final liveUptimeInMinutes = Rxn<int>();
  final liveValidityInMinutes = Rxn<int>();
  final liveBasePrice = 0.0.obs;
  final liveCashDiscountRate = 0.0.obs;
  final liveCreditDiscountRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupLiveCalculations();
    _initializeForm();
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
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

  /// إعداد مستمعين لتحديث بيانات البطاقة المعروضة دون اشتقاق قيم مالية.
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
    _workers.add(ever(selectedBalanceUnit, (_) => updateBalance()));

    void updateUptime() {
      final raw = double.tryParse(uptimeController.text.trim());
      liveUptimeInMinutes.value = raw != null && raw >= 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              raw,
              selectedUptimeUnit.value,
            )
          : null;
    }

    uptimeController.addListener(updateUptime);
    _workers.add(ever(selectedUptimeUnit, (_) => updateUptime()));

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
    _workers.add(ever(selectedValidityUnit, (_) => updateValidity()));

    priceController.addListener(() {
      liveBasePrice.value = double.tryParse(priceController.text.trim()) ?? 0;
    });

    cashDiscountController.addListener(() {
      liveCashDiscountRate.value =
          double.tryParse(cashDiscountController.text.trim()) ?? 0;
    });

    creditDiscountController.addListener(() {
      liveCreditDiscountRate.value =
          double.tryParse(creditDiscountController.text.trim()) ?? 0;
    });
  }

  /// كيان عرض مؤقت للمعاينة؛ الحسابات هنا تقديرية للعرض فقط،
  /// ولا تُستخدم في الحفظ أو في أي قرار محاسبي.
  PackageEntity get livePreviewPackage {
    final count = liveVoucherCount.value > 0 ? liveVoucherCount.value : 1;
    // يطابق تقريب القيم المالية في VoucherPackageResource (منزلتان عشريتان).
    double roundMoney(double value) => (value * 100).roundToDouble() / 100;
    final rawPrice = liveBasePrice.value;
    final basePrice = rawPrice.isFinite && rawPrice >= 0
        ? roundMoney(rawPrice)
        : 0.0;
    final rawCashRate = liveCashDiscountRate.value;
    final rawCreditRate = liveCreditDiscountRate.value;
    final cashRate =
        rawCashRate.isFinite && rawCashRate >= 0 && rawCashRate <= 100
        ? roundMoney(rawCashRate)
        : 0.0;
    final creditRate =
        rawCreditRate.isFinite && rawCreditRate >= 0 && rawCreditRate <= 100
        ? roundMoney(rawCreditRate)
        : 0.0;
    final cashSavings = roundMoney(basePrice * cashRate / 100);
    final creditSavings = roundMoney(basePrice * creditRate / 100);

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
      packageDefaultCashDiscount: cashRate,
      packageDefaultCreditDiscount: creditRate,
      cashDiscountAmount: cashSavings,
      creditDiscountAmount: creditSavings,
      effectiveCashPrice: roundMoney(basePrice - (basePrice * cashRate / 100)),
      effectiveCreditPrice: roundMoney(
        basePrice - (basePrice * creditRate / 100),
      ),
      status: status.value,
      networkName: authorizedNetworks
          .firstWhereOrNull((net) => net.networkId == selectedNetworkId.value)
          ?.networkName,
    );
  }

  /// تهيئة النموذج واكتشاف حالة التعديل أو الإنشاء
  Future<void> _initializeForm() async {
    final dynamic args = Get.arguments;
    if (args is PackageEntity) {
      _populateFromPackage(args);
      return;
    }

    selectedNetworkId.value =
        WorkspaceService.instance.savedActiveNetworkId;

    await _loadAuthorizedNetworks();
  }

  /// إعادة محاولة جلب الشبكات المصرح للمستخدم إدارتها.
  Future<void> retryLoadNetworks() => _loadAuthorizedNetworks();

  /// جلب الشبكات المصرح للمستخدم إدارتها
  Future<void> _loadAuthorizedNetworks() async {
    final useCase = getMyNetworksUseCase;
    if (useCase == null) return;

    try {
      isLoadingNetworks.value = true;
      networkLoadError.value = null;
      final networks = await useCase();
      authorizedNetworks.assignAll(networks);

      if (selectedNetworkId.value == null && networks.isNotEmpty) {
        selectedNetworkId.value = networks.first.networkId;
      }
    } catch (error) {
      networkLoadError.value = AppException.sanitizeMessage(error);
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
      selectedBalanceUnit.value = DataSizeUnit.bytes;
      balanceController.text = '0';
      liveBalanceInBytes.value = 0;
    }

    // استخراج وقت الاستخدام بوحدته المناسبة
    if (package.packageUptime != null) {
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
    if (package.packageValidity != null) {
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
    liveCashDiscountRate.value = package.packageDefaultCashDiscount;
    creditDiscountController.text = package.packageDefaultCreditDiscount
        .toString();
    liveCreditDiscountRate.value = package.packageDefaultCreditDiscount;
    status.value = package.isActive;
  }

  /// تغيير وحدة رصيد البيانات دون تعديل الرقم الذي أدخله المستخدم.
  /// يعاد تفسير الرقم بالوحدة الجديدة عند تحديث القيمة المعيارية بالبايت.
  void setBalanceUnit(DataSizeUnit newUnit) {
    if (selectedBalanceUnit.value == newUnit) return;
    selectedBalanceUnit.value = newUnit;
  }

  /// تغيير وحدة وقت الاستخدام دون تعديل الرقم المدخل؛ الوحدة الجديدة هي المعتمدة.
  void setUptimeUnit(TimeDurationUnit newUnit) {
    if (selectedUptimeUnit.value == newUnit) return;
    selectedUptimeUnit.value = newUnit;
  }

  /// تغيير وحدة الصلاحية دون تحويل الرقم المدخل إلى قيمة عددية مختلفة.
  void setValidityUnit(TimeDurationUnit newUnit) {
    if (selectedValidityUnit.value == newUnit) return;
    selectedValidityUnit.value = newUnit;
  }

  /// إرسال النموذج وحفظ التعديلات أو إنشاء الباقة الجديدة
  Future<void> submitForm() async {
    try {
      if (selectedNetworkId.value == null) {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: 'يرجى تحديد شبكة الكروت التابعة للباقة أولاً.',
          type: SnackType.warning,
        );
        return;
      }
      if (!formKey.currentState!.validate()) return;
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
      final uptimeInMinutes = rawUptime != null && rawUptime >= 0
          ? PackageSpecFormatter.toCanonicalMinutes(
              rawUptime,
              selectedUptimeUnit.value,
            )
          : null;

      final rawValidity = double.tryParse(validityController.text.trim());
      final validityInMinutes = rawValidity != null && rawValidity >= 0
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
          clearPackageUptime: rawUptime == null,
          clearPackageValidity: rawValidity == null,
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

      await CustomAnimationOverlay.showSuccess(
        message: isEditing.value ? 'تم التعديل بنجاح' : 'تم الإنشاء بنجاح',
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
