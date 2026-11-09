import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_cart_line_entity.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Owns the complete Network-side direct invoice draft and submission flow.
/// All prices, discounts, invoice totals and wallet settlement stay in Laravel.
class NetworkDirectInvoiceController extends GetxController {
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;
  final GetPackagesUseCase getPackagesUseCase;
  final CreateDirectSaleInvoiceUseCase createDirectSaleInvoiceUseCase;

  NetworkDirectInvoiceController({
    required this.getMyNetworksUseCase,
    required this.getNetworkPosListUseCase,
    required this.getPackagesUseCase,
    required this.createDirectSaleInvoiceUseCase,
  });

  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController(text: '1');

  final authorizedNetworks = <NetworkEntity>[].obs;
  final linkedPos = <NetworkPosLinkEntity>[].obs;
  final availablePackages = <PackageEntity>[].obs;
  final cart = <DirectInvoiceCartLineEntity>[].obs;

  final selectedNetworkId = RxnInt();
  final selectedPosId = RxnInt();
  final selectedPackageId = RxnInt();
  final selectedSaleType = SaleType.cash.obs;

  final isLoadingNetworks = false.obs;
  final isLoadingPos = false.obs;
  final isLoadingPackages = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  int _networkRevision = 0;
  int _posRevision = 0;
  int _packageRevision = 0;
  String? _submissionIdempotencyKey;

  void _invalidateSubmissionIdempotencyKey() {
    _submissionIdempotencyKey = null;
  }

  bool get hasSelectedNetwork => selectedNetworkId.value != null;
  bool get hasSelectedPos => selectedPosId.value != null;
  bool get canChangeTarget => cart.isEmpty;

  PackageEntity? get selectedPackage {
    final packageId = selectedPackageId.value;
    if (packageId == null) return null;
    return availablePackages.firstWhereOrNull(
      (package) => package.packageId == packageId,
    );
  }

  bool get isSelectedPackageInCart {
    final packageId = selectedPackageId.value;
    return packageId != null &&
        cart.any((line) => line.package.packageId == packageId);
  }

  int get requestedItemCount =>
      cart.fold<int>(0, (total, line) => total + line.voucherCount);

  @override
  void onInit() {
    super.onInit();
    unawaited(loadInitialData());
  }

  @override
  void onClose() {
    _networkRevision++;
    _posRevision++;
    _packageRevision++;
    quantityController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoadingNetworks.value = true;
    errorMessage.value = null;
    try {
      final networks = await getMyNetworksUseCase();
      authorizedNetworks.assignAll(networks);
      if (networks.isEmpty) {
        errorMessage.value =
            'لا توجد شبكة مخولة بإصدار فواتير مبيعات لهذا الحساب.';
        return;
      }

      // Financial beneficiary selection must be deliberate even when the
      // account has exactly one network. Never infer the target from API order.
      selectedNetworkId.value = null;
      selectedPosId.value = null;
      selectedPackageId.value = null;
      linkedPos.clear();
      availablePackages.clear();
    } catch (error) {
      errorMessage.value = error is AppException
          ? error.message
          : AppException.sanitizeMessage(
              error,
              fallback: 'تعذر تحميل شبكات الحساب.',
            );
      CustomSnackbar.show(
        title: 'تعذر تحميل الشبكات',
        message: errorMessage.value!,
        type: SnackType.error,
      );
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  Future<void> onNetworkSelected(int networkId) async {
    if (cart.isNotEmpty) {
      CustomSnackbar.show(
        title: 'الفاتورة تحتوي على بنود',
        message: 'أفرغ البنود قبل تغيير الشبكة المستفيدة.',
        type: SnackType.warning,
      );
      return;
    }
    _invalidateSubmissionIdempotencyKey();
    selectedNetworkId.value = networkId;
    selectedPosId.value = null;
    selectedPackageId.value = null;
    linkedPos.clear();
    availablePackages.clear();

    final networkRevision = ++_networkRevision;
    _posRevision++;
    _packageRevision++;

    await Future.wait([
      loadLinkedPos(networkId, networkRevision),
      loadNetworkPackages(networkId, networkRevision),
    ]);
  }

  Future<void> loadLinkedPos(int networkId, int networkRevision) async {
    final revision = ++_posRevision;
    isLoadingPos.value = true;
    try {
      final result = await getNetworkPosListUseCase(
        networkId,
        status: true,
        perPage: 100,
      );
      if (revision != _posRevision ||
          networkRevision != _networkRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }

      linkedPos.assignAll(
        result.items.where((link) => link.isActive && link.pos != null),
      );
      // POS beneficiary must also be selected explicitly by the user.
      selectedPosId.value = null;
    } catch (error) {
      if (revision != _posRevision ||
          networkRevision != _networkRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      linkedPos.clear();
      selectedPosId.value = null;
      CustomSnackbar.show(
        title: 'تعذر تحميل نقاط البيع',
        message: error is AppException
            ? error.message
            : AppException.sanitizeMessage(error),
        type: SnackType.error,
      );
    } finally {
      if (revision == _posRevision) {
        isLoadingPos.value = false;
      }
    }
  }

  Future<void> loadNetworkPackages(int networkId, int networkRevision) async {
    final revision = ++_packageRevision;
    isLoadingPackages.value = true;
    try {
      final result = await getPackagesUseCase(
        networkId: networkId,
        status: true,
        perPage: 100,
      );
      if (revision != _packageRevision ||
          networkRevision != _networkRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }

      availablePackages.assignAll(
        result.items.where((package) => package.isActive),
      );
      // Require an explicit package choice; do not use catalog ordering.
      selectedPackageId.value = null;
    } catch (error) {
      if (revision != _packageRevision ||
          networkRevision != _networkRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      availablePackages.clear();
      selectedPackageId.value = null;
      CustomSnackbar.show(
        title: 'تعذر تحميل الباقات',
        message: error is AppException
            ? error.message
            : AppException.sanitizeMessage(error),
        type: SnackType.error,
      );
    } finally {
      if (revision == _packageRevision) {
        isLoadingPackages.value = false;
      }
    }
  }

  void onPosSelected(int posId) {
    if (cart.isNotEmpty) {
      CustomSnackbar.show(
        title: 'الفاتورة تحتوي على بنود',
        message: 'أفرغ البنود قبل تغيير نقطة البيع.',
        type: SnackType.warning,
      );
      return;
    }
    _invalidateSubmissionIdempotencyKey();
    selectedPosId.value = posId;
  }

  void onPackageSelected(int packageId) {
    selectedPackageId.value = packageId;
  }

  String? validateVoucherCount(String? value) {
    final count = int.tryParse(value?.trim() ?? '');
    if (count == null || count <= 0) {
      return 'أدخل عدد كروت صحيحاً أكبر من صفر.';
    }
    return null;
  }

  void addOrUpdateCartLine() {
    if (selectedNetworkId.value == null || selectedPosId.value == null) {
      CustomSnackbar.show(
        title: 'حدد جهة الفاتورة أولاً',
        message: 'اختر الشبكة ونقطة البيع قبل إضافة الباقات.',
        type: SnackType.warning,
      );
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;

    final package = selectedPackage;
    final quantity = int.tryParse(quantityController.text.trim());
    if (package == null || quantity == null || quantity <= 0) {
      CustomSnackbar.show(
        title: 'بيانات الباقة غير مكتملة',
        message: 'اختر باقة وأدخل كمية صحيحة.',
        type: SnackType.warning,
      );
      return;
    }
    if (package.networkId != selectedNetworkId.value || !package.isActive) {
      CustomSnackbar.show(
        title: 'الباقة غير متاحة',
        message: 'اختر باقة نشطة تابعة للشبكة المحددة.',
        type: SnackType.error,
      );
      return;
    }

    final index = cart.indexWhere(
      (line) => line.package.packageId == package.packageId,
    );
    final hasChanged = index < 0 || cart[index].voucherCount != quantity;
    final line = DirectInvoiceCartLineEntity(
      package: package,
      voucherCount: quantity,
    );
    if (hasChanged) {
      _invalidateSubmissionIdempotencyKey();
    }
    if (index >= 0) {
      cart[index] = line;
    } else {
      cart.add(line);
    }
  }

  void updateLineQuantity(int packageId, int quantity) {
    if (quantity <= 0) return;
    final index = cart.indexWhere(
      (line) => line.package.packageId == packageId,
    );
    if (index < 0 || cart[index].voucherCount == quantity) return;
    _invalidateSubmissionIdempotencyKey();
    cart[index] = cart[index].copyWith(voucherCount: quantity);
  }

  void removeLine(int packageId) {
    final previousLength = cart.length;
    cart.removeWhere((line) => line.package.packageId == packageId);
    if (cart.length != previousLength) {
      _invalidateSubmissionIdempotencyKey();
    }
  }

  void clearCart() {
    if (cart.isNotEmpty) {
      _invalidateSubmissionIdempotencyKey();
      cart.clear();
    }
  }

  void setSaleType(SaleType saleType) {
    if (saleType == SaleType.unknown || selectedSaleType.value == saleType) {
      return;
    }
    _invalidateSubmissionIdempotencyKey();
    selectedSaleType.value = saleType;
  }

  Future<InvoiceEntity?> submitInvoice() async {
    final networkId = selectedNetworkId.value;
    final posId = selectedPosId.value;
    if (networkId == null || posId == null || cart.isEmpty) {
      CustomSnackbar.show(
        title: 'الفاتورة غير مكتملة',
        message: 'حدد الشبكة ونقطة البيع وأضف بنداً واحداً على الأقل.',
        type: SnackType.warning,
      );
      return null;
    }
    if (isSubmitting.value) return null;

    isSubmitting.value = true;
    final idempotencyKey = _submissionIdempotencyKey ??=
        IdempotencyHelper.forSaleInvoice(posId);
    await CustomAnimationOverlay.showLoading(
      message: 'جاري إنشاء الفاتورة والتحقق من التسعير والتسوية لدى الخادم...',
    );
    try {
      final invoice = await createDirectSaleInvoiceUseCase(
        networkId: networkId,
        posId: posId,
        saleType: selectedSaleType.value,
        idempotencyKey: idempotencyKey,
        items: cart
            .map(
              (line) => DirectInvoiceItemInputEntity(
                packageId: line.package.packageId,
                voucherCount: line.voucherCount,
              ),
            )
            .toList(growable: false),
      );
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إنشاء فاتورة المبيعات المباشرة بنجاح.',
      );
      _invalidateSubmissionIdempotencyKey();
      return invoice;
    } on AppException catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: error.message,
        type: SnackType.error,
      );
      return null;
    } catch (error) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: AppException.sanitizeMessage(error),
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
