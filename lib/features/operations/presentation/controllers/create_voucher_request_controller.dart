import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/usecases/create_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم إنشاء طلب توريد الكروت (CreateVoucherRequestController)
/// ============================================================================
/// يدير حالة دورة حياة نموذج طلب التوريد: جلب باقات الشبكة، حساب المبالغ،
/// وإرسال الطلب عبر UseCases معزولة 100%.
class CreateVoucherRequestController extends GetxController {
  final GetVoucherPackagesUseCase getVoucherPackagesUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final CreateVoucherRequestUseCase createVoucherRequestUseCase;

  CreateVoucherRequestController({
    required this.getVoucherPackagesUseCase,
    required this.getNetworkPosListUseCase,
    required this.createVoucherRequestUseCase,
  });

  /// الحالات التفاعلية
  final ValueNotifier<int?> selectedNetworkId = ValueNotifier<int?>(null);
  final ValueNotifier<int?> selectedPosId = ValueNotifier<int?>(null);
  final RxnString networkName = RxnString();
  final RxString saleType = 'CASH'.obs;

  final RxMap<int, int> packageQuantities = <int, int>{}.obs;
  final RxList<VoucherPackageEntity> packages = <VoucherPackageEntity>[].obs;
  final RxList<NetworkPosEntity> linkedNetworks = <NetworkPosEntity>[].obs;

  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController notesController = TextEditingController();

  @override
  void onClose() {
    selectedNetworkId.dispose();
    selectedPosId.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// تهيئة المتحكم بالسياق الممرر
  Future<void> init({
    int? networkId,
    int? posId,
    String? networkNameArg,
  }) async {
    selectedNetworkId.value = networkId;
    selectedPosId.value = posId;
    networkName.value = networkNameArg;
    saleType.value = 'CASH';
    packageQuantities.clear();
    notesController.clear();

    await loadInitialData();
  }

  /// تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    isLoading.value = true;
    loadError.value = '';

    try {
      // إذا لم تكن الشبكة محددة، نجلب الشبكات المرتبطة بنقطة البيع
      if (selectedNetworkId.value == null && selectedPosId.value != null) {
        final fetched = await getNetworkPosListUseCase(
          posId: selectedPosId.value,
          status: true,
        );
        linkedNetworks.assignAll(fetched);
        if (linkedNetworks.isNotEmpty) {
          selectedNetworkId.value = linkedNetworks.first.networkId;
        }
      }

      if (selectedNetworkId.value != null) {
        await loadPackagesForNetwork(selectedNetworkId.value!);
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      loadError.value = 'تعذر استرجاع باقات الشبكة: $e';
      isLoading.value = false;
    }
  }

  /// جلب باقات شبكة معينة
  Future<void> loadPackagesForNetwork(int netId) async {
    try {
      final result = await getVoucherPackagesUseCase(
        networkId: netId,
        status: true,
      );
      packages.assignAll(result);
    } catch (e) {
      loadError.value = 'تعذر استرجاع باقات الشبكة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير الشبكة المختارة
  void onNetworkChanged(int? newNetId) {
    if (newNetId == null || newNetId == selectedNetworkId.value) return;

    selectedNetworkId.value = newNetId;
    packageQuantities.clear();
    packages.clear();
    isLoading.value = true;
    loadPackagesForNetwork(newNetId);
  }

  /// زيادة كمية باقة
  void incrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    packageQuantities[packageId] = current + 1;
  }

  /// إنقاص كمية باقة
  void decrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    if (current > 1) {
      packageQuantities[packageId] = current - 1;
    } else {
      packageQuantities.remove(packageId);
    }
  }

  /// إضافة كمية مسبقة
  void addPresetQuantity(int packageId, int amount) {
    final current = packageQuantities[packageId] ?? 0;
    packageQuantities[packageId] = current + amount;
  }

  /// تعيين كمية دقيقة
  void setExactQuantity(int packageId, int quantity) {
    if (quantity > 0) {
      packageQuantities[packageId] = quantity;
    } else {
      packageQuantities.remove(packageId);
    }
  }

  // DISPLAY-ONLY PREVIEW (quantity): backend recomputes totals.
  int get totalVoucherCount {
    return packageQuantities.values.fold(0, (sum, count) => sum + count);
  }

  // DISPLAY-ONLY PREVIEW: non-authoritative; backend recomputes from items.
  double get totalGrossAmount {
    double total = 0.0;
    for (final pkg in packages) {
      final qty = packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        total += pkg.packageVoucherPrice * qty; // DISPLAY-ONLY non-authoritative
      }
    }
    return total;
  }

  // DISPLAY-ONLY PREVIEW: non-authoritative; backend uses effective discount.
  double get totalDiscountAmount {
    double discount = 0.0;
    for (final pkg in packages) {
      final qty = packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        final percent = saleType.value == 'CASH'
            ? pkg.packageDefaultCashDiscount
            : pkg.packageDefaultCreditDiscount;
        final gross = pkg.packageVoucherPrice * qty;
        discount += gross * (percent / 100); // DISPLAY-ONLY non-authoritative
      }
    }
    return discount;
  }

  double get totalNetAmount => totalGrossAmount - totalDiscountAmount;

  /// إرسال طلب التوريد
  Future<VoucherRequestEntity?> submitRequest() async {
    if (selectedNetworkId.value == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'يرجى اختيار الشبكة المراد طلب الكروت منها أولاً',
        type: SnackType.warning,
      );
      return null;
    }

    if (totalVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه الطلب',
        message: 'يرجى تحديد كمية باقة واحدة على الأقل لتقديم الطلب',
        type: SnackType.warning,
      );
      return null;
    }

    if (selectedPosId.value == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'تعذر تحديد نقطة البيع الخاصة بحسابك لتقديم الطلب',
        type: SnackType.warning,
      );
      return null;
    }

    final items = <Map<String, dynamic>>[];
    for (final pkg in packages) {
      final qty = packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        // NOTE: only package_id + voucher_count sent; backend uses catalog price & effective discount.
        items.add({
          'package_id': pkg.packageId,
          'voucher_count': qty,
        });
      }
    }

    isSubmitting.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إرسال طلب توريد الكروت للشبكة...',
      );

      final newRequest = await createVoucherRequestUseCase(
        networkId: selectedNetworkId.value!,
        posId: selectedPosId.value!,
        saleType: saleType.value,
        items: items,
        requestNote: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      // تحديث قائمة طلبات التوريد في OperationsController إن وجد
      if (Get.isRegistered<OperationsController>()) {
        Get.find<OperationsController>().requests.insert(0, newRequest);
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إرسال طلب توريد الكروت للشبكة بنجاح',
      );

      return newRequest;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر إرسال الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
      return null;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
