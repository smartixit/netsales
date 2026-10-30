import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/usecases/create_sale_invoice_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم إنشاء وإصدار فاتورة المبيعات المباشرة (CreateSaleInvoiceController)
/// ============================================================================
/// يدير حالة دورة حياة نموذج إصدار الفاتورة: جلب بيانات الشبكات والباقات،
/// الحسابات المالية التلقائية، وإصدار الفاتورة عبر UseCases معزولة 100%.
class CreateSaleInvoiceController extends GetxController {
  final GetNetworksUseCase getNetworksUseCase;
  final GetVoucherPackagesUseCase getVoucherPackagesUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final CreateSaleInvoiceUseCase createSaleInvoiceUseCase;

  CreateSaleInvoiceController({
    required this.getNetworksUseCase,
    required this.getVoucherPackagesUseCase,
    required this.getNetworkPosListUseCase,
    required this.createSaleInvoiceUseCase,
  });

  /// الحالات التفاعلية للنموذج
  final ValueNotifier<int?> selectedNetworkId = ValueNotifier<int?>(null);
  final ValueNotifier<int?> selectedPosId = ValueNotifier<int?>(null);
  final RxnString selectedPosName = RxnString();
  final RxString saleType = 'CASH'.obs;

  final RxMap<int, int> packageQuantities = <int, int>{}.obs;
  final RxList<NetworkEntity> networks = <NetworkEntity>[].obs;
  final RxList<VoucherPackageEntity> packages = <VoucherPackageEntity>[].obs;
  final RxList<NetworkPosEntity> linkedPosList = <NetworkPosEntity>[].obs;

  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController paidAmountController = TextEditingController();

  @override
  void onClose() {
    selectedNetworkId.dispose();
    selectedPosId.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  /// تهيئة المتحكم ببيانات السياق الممررة
  Future<void> init({
    int? networkId,
    int? preselectedPosId,
    String? preselectedPosName,
  }) async {
    selectedNetworkId.value = networkId;
    selectedPosId.value = preselectedPosId;
    selectedPosName.value = preselectedPosName;
    saleType.value = 'CASH';
    packageQuantities.clear();
    paidAmountController.clear();

    await loadInitialData();
  }

  /// تحميل البيانات الأولية للشبكات ونقاط البيع
  Future<void> loadInitialData() async {
    isLoading.value = true;
    loadError.value = '';

    try {
      // 1. جلب شبكات المزود المتاحة
      final fetchedNetworks = await getNetworksUseCase();
      networks.assignAll(fetchedNetworks);

      if (selectedNetworkId.value == null && networks.isNotEmpty) {
        selectedNetworkId.value = networks.first.networkId;
      }

      // 2. جلب بيانات الشبكة المحددة (الباقات ونقاط البيع)
      if (selectedNetworkId.value != null) {
        await loadDataForNetwork(selectedNetworkId.value!);
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      loadError.value = 'تعذر تحميل بيانات الإعداد: $e';
      isLoading.value = false;
    }
  }

  /// جلب باقات ونقاط بيع شبكة معينة
  Future<void> loadDataForNetwork(int netId) async {
    try {
      final fetchedPackages = await getVoucherPackagesUseCase(
        networkId: netId,
        status: true,
      );
      packages.assignAll(fetchedPackages);

      if (selectedPosId.value == null) {
        final fetchedPos = await getNetworkPosListUseCase(
          networkId: netId,
          status: true,
        );
        linkedPosList.assignAll(fetchedPos);
        if (linkedPosList.isNotEmpty) {
          selectedPosId.value = linkedPosList.first.posId;
          selectedPosName.value = linkedPosList.first.posName;
        }
      } else {
        final fetchedPos = await getNetworkPosListUseCase(
          networkId: netId,
          status: true,
        );
        linkedPosList.assignAll(fetchedPos);
      }
    } catch (e) {
      loadError.value = 'تعذر استرجاع بيانات الشبكة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير الشبكة المحددة
  void onNetworkChanged(int? newNetId) {
    if (newNetId == null || newNetId == selectedNetworkId.value) return;

    selectedNetworkId.value = newNetId;
    packageQuantities.clear();
    packages.clear();
    linkedPosList.clear();

    // Always reset POS selection when network changes (even if preselected),
    // because the preselected POS belongs to the previous network and is
    // invalid for the new network. loadDataForNetwork will auto-select the
    // first POS of the new network.
    selectedPosId.value = null;
    selectedPosName.value = null;

    isLoading.value = true;
    loadDataForNetwork(newNetId);
  }

  /// تغيير نقطة البيع المحددة
  void onPosChanged(int? newPosId) {
    if (newPosId == null) return;
    selectedPosId.value = newPosId;
    final found = linkedPosList.firstWhereOrNull((p) => p.posId == newPosId);
    if (found != null) {
      selectedPosName.value = found.posName;
    }
  }

  /// تغيير نوع البيع (نقدي / آجل)
  void setSaleType(String type) {
    saleType.value = type;
    syncPaidAmount();
  }

  /// زيادة كمية باقة معينة
  void incrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    packageQuantities[packageId] = current + 1;
    syncPaidAmount();
  }

  /// إنقاص كمية باقة معينة
  void decrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    if (current > 1) {
      packageQuantities[packageId] = current - 1;
    } else {
      packageQuantities.remove(packageId);
    }
    syncPaidAmount();
  }

  /// إضافة كمية محددة مسبقاً
  void addPresetQuantity(int packageId, int amount) {
    final current = packageQuantities[packageId] ?? 0;
    packageQuantities[packageId] = current + amount;
    syncPaidAmount();
  }

  /// تعيين كمية دقيقة للباقة
  void setExactQuantity(int packageId, int quantity) {
    if (quantity > 0) {
      packageQuantities[packageId] = quantity;
    } else {
      packageQuantities.remove(packageId);
    }
    syncPaidAmount();
  }

  /// مزامنة المبلغ المدفوع تلقائياً في البيع النقدي
  void syncPaidAmount() {
    if (saleType.value == 'CASH') {
      paidAmountController.text = AmountFormatter.formatValue(totalNetAmount);
    }
  }

  // DISPLAY-ONLY PREVIEW (quantity, not money): backend recomputes totals.
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

  // DISPLAY-ONLY PREVIEW: backend is authoritative for paid/remaining.
  // For cash, send null so backend sets paid = total (remaining = 0).
  double? get paidAmount {
    if (saleType.value == 'CASH') return null;
    final cleaned = AmountFormatter.clean(paidAmountController.text);
    return double.tryParse(cleaned);
  }

  double get remainingDebtAmount {
    if (saleType.value == 'CASH') return 0.0;
    final paid = paidAmount ?? 0.0;
    return (totalNetAmount - paid).clamp(0.0, double.infinity);
  }

  /// إرسال واعتماد فاتورة المبيعات
  Future<SaleInvoiceEntity?> submitInvoice() async {
    if (selectedNetworkId.value == null) {
      CustomSnackbar.show(
        title: 'تنبيه النطاق',
        message: 'يرجى اختيار الشبكة الموردة للكروت أولاً',
        type: SnackType.warning,
      );
      return null;
    }

    if (selectedPosId.value == null) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يرجى اختيار نقطة البيع المراد إصدار الفاتورة لها',
        type: SnackType.warning,
      );
      return null;
    }

    if (totalVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه الفوترة',
        message: 'يرجى تحديد كمية باقة واحدة على الأقل لإصدار الفاتورة',
        type: SnackType.warning,
      );
      return null;
    }

    final items = <Map<String, dynamic>>[];
    for (final pkg in packages) {
      final qty = packageQuantities[pkg.packageId] ?? 0;
      if (qty > 0) {
        // NOTE: only package_id + voucher_count are sent; backend uses catalog price
        // and effective discount (server-authoritative, display-only preview above).
        items.add({
          'package_id': pkg.packageId,
          'voucher_count': qty,
        });
      }
    }

    isSubmitting.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إصدار فاتورة المبيعات والتسوية...',
      );

      final newInvoice = await createSaleInvoiceUseCase(
        networkId: selectedNetworkId.value!,
        posId: selectedPosId.value!,
        saleType: saleType.value,
        items: items,
        paidAmount: paidAmount,
      );

      // تحديث قائمة العمليات إذا كان المتحكم مسجلاً
      if (Get.isRegistered<OperationsController>()) {
        Get.find<OperationsController>().invoices.insert(0, newInvoice);
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم إصدار فاتورة المبيعات وتسوية الرصيد بنجاح',
      );

      return newInvoice;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر إصدار الفاتورة',
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
