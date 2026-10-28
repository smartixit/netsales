import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/usecases/update_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم تعديل طلب توريد الكروت قيد الانتظار (EditVoucherRequestController)
/// ============================================================================
/// يدير حالة تعديل كميات الباقات، نوع البيع، وملاحظات الطلب مع الحفاظ على القواعد
/// المؤسسية وحظر تعديل الطلبات المعتمدة أو المرفوضة نهائياً.
class EditVoucherRequestController extends GetxController {
  final GetVoucherPackagesUseCase getVoucherPackagesUseCase;
  final UpdateVoucherRequestUseCase updateVoucherRequestUseCase;

  EditVoucherRequestController({
    required this.getVoucherPackagesUseCase,
    required this.updateVoucherRequestUseCase,
  });

  /// الطلب المبدئي الجاري تعديله
  VoucherRequestEntity? currentRequest;

  /// الحالات التفاعلية
  final RxString saleType = 'CASH'.obs;
  final RxMap<int, int> packageQuantities = <int, int>{}.obs;
  final RxList<VoucherPackageEntity> packages = <VoucherPackageEntity>[].obs;

  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController notesController = TextEditingController();

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  /// تهيئة المتحكم بالطلب المراد تعديله
  Future<void> init(VoucherRequestEntity request) async {
    currentRequest = request;
    saleType.value = request.saleType;
    notesController.text = request.requestNote ?? '';
    packageQuantities.clear();

    // ملء الكميات السابقة
    for (final item in request.items) {
      packageQuantities[item.packageId] = item.voucherCount;
    }

    await loadPackagesForNetwork(request.networkId);
  }

  /// جلب باقات الشبكة الموردة
  Future<void> loadPackagesForNetwork(int networkId) async {
    isLoading.value = true;
    loadError.value = '';

    try {
      final result = await getVoucherPackagesUseCase(
        networkId: networkId,
        status: true,
      );
      packages.assignAll(result);
    } catch (e) {
      loadError.value = 'تعذر استرجاع باقات الشبكة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير نوع البيع (نقدي / آجل)
  void setSaleType(String type) {
    if (saleType.value != type) {
      saleType.value = type;
    }
  }

  /// تحديث كمية باقة معينة
  void setPackageQuantity(int packageId, int quantity) {
    if (quantity <= 0) {
      packageQuantities.remove(packageId);
    } else {
      packageQuantities[packageId] = quantity;
    }
  }

  void incrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    setPackageQuantity(packageId, current + 1);
  }

  void decrementQuantity(int packageId) {
    final current = packageQuantities[packageId] ?? 0;
    if (current > 0) {
      setPackageQuantity(packageId, current - 1);
    }
  }

  void addPresetQuantity(int packageId, int preset) {
    final current = packageQuantities[packageId] ?? 0;
    setPackageQuantity(packageId, current + preset);
  }

  void setExactQuantity(int packageId, int qty) {
    setPackageQuantity(packageId, qty);
  }

  /// إجمالي عدد الكروت المختارة
  int get totalVoucherCount {
    return packageQuantities.values.fold(0, (sum, count) => sum + count);
  }

  /// إجمالي المبلغ الإجمالي قبل الخصم
  double get totalGrossAmount {
    double total = 0.0;
    for (final entry in packageQuantities.entries) {
      final pkg = packages.firstWhereOrNull((p) => p.packageId == entry.key);
      if (pkg != null) {
        total += pkg.packageVoucherPrice * entry.value;
      }
    }
    return total;
  }

  /// إجمالي مبالغ الخصم المطبقة
  double get totalDiscountAmount {
    double totalDiscount = 0.0;
    final isCash = saleType.value == 'CASH';

    for (final entry in packageQuantities.entries) {
      final pkg = packages.firstWhereOrNull((p) => p.packageId == entry.key);
      if (pkg != null) {
        final lineGross = pkg.packageVoucherPrice * entry.value;
        final discountPercent = isCash
            ? pkg.packageDefaultCashDiscount
            : pkg.packageDefaultCreditDiscount;
        totalDiscount += lineGross * (discountPercent / 100);
      }
    }
    return totalDiscount;
  }

  /// صافي المبلغ بعد الخصم
  double get totalNetAmount {
    final net = totalGrossAmount - totalDiscountAmount;
    return net > 0 ? net : 0.0;
  }

  /// إرسال التعديلات إلى الخادم
  Future<bool> submit() async {
    if (currentRequest == null) return false;

    if (!currentRequest!.isPending) {
      CustomSnackbar.show(
        title: 'إجراء غير متاح',
        message: 'لا يمكن تعديل طلب توريد تم اعتماده أو رفضه أو إلغاؤه مسبقاً.',
        type: SnackType.warning,
      );
      return false;
    }

    if (totalVoucherCount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه الاختيار',
        message: 'يرجى تحديد كمية كرت واحدة على الأقل لإتمام التعديل.',
        type: SnackType.warning,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      await CustomAnimationOverlay.showLoading(message: 'جاري حفظ تعديلات الطلب...');

      final items = packageQuantities.entries.map((entry) {
        final pkg = packages.firstWhereOrNull((p) => p.packageId == entry.key);
        final isCash = saleType.value == 'CASH';
        final discount = pkg != null
            ? (isCash
                ? pkg.packageDefaultCashDiscount
                : pkg.packageDefaultCreditDiscount)
            : 0.0;

        return {
          'package_id': entry.key,
          'voucher_count': entry.value,
          if (pkg != null) 'voucher_price': pkg.packageVoucherPrice,
          'item_discount': discount,
        };
      }).toList();

      final updatedRequest = await updateVoucherRequestUseCase(
        currentRequest!.requestId,
        saleType: saleType.value,
        items: items,
        requestNote: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      // تحديث الطلب في المتحكم الرئيسي
      if (Get.isRegistered<OperationsController>()) {
        final opsCtrl = Get.find<OperationsController>();
        final idx = opsCtrl.requests.indexWhere(
          (r) => r.requestId == updatedRequest.requestId,
        );
        if (idx != -1) {
          opsCtrl.requests[idx] = updatedRequest;
        }
        if (opsCtrl.selectedRequest.value?.requestId == updatedRequest.requestId) {
          opsCtrl.selectedRequest.value = updatedRequest;
        }
      }

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تعديل طلب توريد الكروت بنجاح',
      );

      Get.back(result: updatedRequest);
      return true;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'تعذر تعديل الطلب',
        message: cleanMessage,
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
