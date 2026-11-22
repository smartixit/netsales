import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/direct_sale_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة إصدار فاتورة مبيعات مباشرة لنقطة بيع (NetworkDirectInvoiceController)
class NetworkDirectInvoiceController extends GetxController {
  NetworkDirectInvoiceController({
    required this.createDirectSaleInvoiceUseCase,
    this.getPackagesUseCase,
    this.getNetworkPosListUseCase,
  });

  final CreateDirectSaleInvoiceUseCase createDirectSaleInvoiceUseCase;
  final GetPackagesUseCase? getPackagesUseCase;
  final GetNetworkPosListUseCase? getNetworkPosListUseCase;

  final formKey = GlobalKey<FormState>();

  // روابط نقاط البيع التابعة للشبكة
  final posLinks = <NetworkPosLinkEntity>[].obs;
  final selectedPosId = RxnInt();
  final isLoadingPosList = false.obs;
  final isPosContextExpanded = false.obs;

  // باقات الشبكة وسلة الفاتورة
  final packages = <PackageEntity>[].obs;
  final isLoadingPackages = false.obs;
  final packageSearchQuery = ''.obs;
  final packageSearchController = TextEditingController();

  // كميات الباقات ووحدات التحكم
  final packageQuantities = <int, int>{}.obs;
  final quantityControllers = <int, TextEditingController>{};

  // نوع البيع (0 = نقدي، 1 = آجل)
  final selectedSaleTypeIndex = 0.obs;

  SaleType get selectedSaleType => SaleType.cash;

  // الدفعة النقدية المقبوضة كاش في البيع الآجل
  final paidAmountController = TextEditingController();
  final paidAmount = 0.0.obs;

  // حالة الإرسال
  final isSubmitting = false.obs;

  int? get activeNetworkId {
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  NetworkPosLinkEntity? get selectedPosLink =>
      posLinks.firstWhereOrNull((link) => link.posId == selectedPosId.value);

  int get cartPackagesCount =>
      packageQuantities.values.where((count) => count > 0).length;

  int get checkoutTotalVouchers => packageQuantities.values.fold<int>(
    0,
    (sum, count) => sum + (count > 0 ? count : 0),
  );

  double get checkoutGrossAmount {
    var total = 0.0;
    for (final entry in packageQuantities.entries) {
      if (entry.value > 0) {
        final pkg = packages.firstWhereOrNull((p) => p.packageId == entry.key);
        if (pkg != null) {
          total += pkg.resolvedBasePrice * entry.value;
        }
      }
    }
    return total;
  }

  double get checkoutDiscountAmount {
    var discount = 0.0;
    final isCash = selectedSaleType == SaleType.cash;
    for (final entry in packageQuantities.entries) {
      if (entry.value > 0) {
        final pkg = packages.firstWhereOrNull((p) => p.packageId == entry.key);
        if (pkg != null) {
          final unitDiscount = isCash
              ? pkg.resolvedCashDiscount
              : pkg.resolvedCreditDiscount;
          discount += unitDiscount * entry.value;
        }
      }
    }
    return discount;
  }

  double get checkoutNetAmount {
    final net = checkoutGrossAmount - checkoutDiscountAmount;
    return net > 0 ? net : 0.0;
  }

  /// المبلغ المقبوض كاش في البيع الآجل (إن وجد)
  double get checkoutPaidAmount {
    if (selectedSaleType != SaleType.credit) return 0.0;
    final paid = paidAmount.value;
    final net = checkoutNetAmount;
    return paid > net ? net : paid;
  }

  /// المتبقي الآجل المطلوب قيده كدين على نقطة البيع
  double get checkoutRemainingCreditAmount {
    if (selectedSaleType != SaleType.credit) return 0.0;
    final net = checkoutNetAmount;
    final paid = checkoutPaidAmount;
    final remaining = net - paid;
    return remaining > 0 ? remaining : 0.0;
  }

  bool get canSubmitInvoice {
    if (selectedPosId.value == null ||
        cartPackagesCount <= 0 ||
        isSubmitting.value) {
      return false;
    }
    if (selectedSaleType == SaleType.credit &&
        paidAmount.value > checkoutNetAmount) {
      return false;
    }
    return true;
  }

  TextEditingController getQuantityController(int packageId) {
    return quantityControllers.putIfAbsent(
      packageId,
      () => TextEditingController(text: '${packageQuantities[packageId] ?? 0}'),
    );
  }

  void setPackageQuantity(int packageId, int quantity) {
    final clamped = quantity < 0 ? 0 : quantity;
    if (clamped == 0) {
      packageQuantities.remove(packageId);
    } else {
      packageQuantities[packageId] = clamped;
    }
    final ctrl = quantityControllers[packageId];
    if (ctrl != null && ctrl.text != '$clamped') {
      ctrl.text = '$clamped';
    }
  }

  void setSaleTypeIndex(int index) {}

  void selectPos(int posId) {
    selectedPosId.value = posId;
    isPosContextExpanded.value = false;
  }

  void togglePosContextExpansion() {
    isPosContextExpanded.value = !isPosContextExpanded.value;
  }

  @override
  void onInit() {
    super.onInit();
    packageSearchController.addListener(() {
      packageSearchQuery.value = packageSearchController.text.trim();
    });
    paidAmountController.addListener(() {
      final parsed = double.tryParse(paidAmountController.text.trim()) ?? 0.0;
      paidAmount.value = parsed >= 0 ? parsed : 0.0;
    });
    loadInitialData();
  }

  @override
  void onClose() {
    for (final ctrl in quantityControllers.values) {
      ctrl.dispose();
    }
    packageSearchController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([loadPosList(), loadPackages()]);
  }

  Future<void> loadPosList() async {
    final netId = activeNetworkId;
    if (netId == null || getNetworkPosListUseCase == null) return;

    isLoadingPosList.value = true;
    try {
      final paginated = await getNetworkPosListUseCase!(networkId: netId);
      posLinks.assignAll(paginated.items);
      if (posLinks.isNotEmpty && selectedPosId.value == null) {
        selectedPosId.value = posLinks.first.posId;
      }
    } catch (_) {
      // التعامل بهدوء
    } finally {
      isLoadingPosList.value = false;
    }
  }

  Future<void> loadPackages() async {
    final netId = activeNetworkId;
    if (netId == null || getPackagesUseCase == null) return;

    isLoadingPackages.value = true;
    try {
      final paginated = await getPackagesUseCase!(networkId: netId);
      packages.assignAll(paginated.items);
    } catch (_) {
      // التعامل بهدوء
    } finally {
      isLoadingPackages.value = false;
    }
  }

  Future<void> submitDirectInvoice() async {
    if (!canSubmitInvoice) return;

    final netId = activeNetworkId;
    final posId = selectedPosId.value;

    if (netId == null || posId == null) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'يرجى تحديد الشبكة ونقطة البيع المستلمة.',
        type: SnackType.error,
      );
      return;
    }

    final itemsPayload = <DirectSaleInvoiceItemInputEntity>[];
    for (final entry in packageQuantities.entries) {
      if (entry.value > 0) {
        itemsPayload.add(
          DirectSaleInvoiceItemInputEntity(
            packageId: entry.key,
            voucherCount: entry.value,
          ),
        );
      }
    }

    if (itemsPayload.isEmpty) {
      CustomSnackbar.show(
        title: 'السلة فارغة',
        message: 'يرجى اختيار باقة واحدة على الأقل وتحديد كميتها.',
        type: SnackType.warning,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري إصدار فاتورة المبيعات المباشرة...',
      );

      final idempotencyKey = IdempotencyHelper.forSaleInvoice(posId);

      final createdInvoice = await createDirectSaleInvoiceUseCase(
        networkId: netId,
        posId: posId,
        saleType: selectedSaleType,
        items: itemsPayload,
        idempotencyKey: idempotencyKey,
        paidAmount: selectedSaleType == SaleType.credit && paidAmount.value > 0
            ? paidAmount.value
            : null,
      );

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تسجيل الفاتورة رقم ${createdInvoice.displayReference}',
      );

      Get.back<void>();
      await Get.toNamed<void>(
        AppRoutes.saleInvoiceDetails,
        arguments: {
          'invoice_id': createdInvoice.invoiceId,
          'invoice': createdInvoice,
        },
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      isSubmitting.value = false;
    }
  }
}
