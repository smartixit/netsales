import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_cart_line_entity.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم إنشاء فاتورة مبيعات مباشرة من جهة شبكة التزويد
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

  // ── الكيانات والسياق ──
  final authorizedNetworks = <NetworkEntity>[].obs;
  final linkedPos = <PosEntity>[].obs;
  final availablePackages = <PackageEntity>[].obs;

  final selectedNetworkId = RxnInt();
  final selectedPosId = RxnInt();
  final selectedSaleType = SaleType.cash.obs;
  final cart = <DirectInvoiceCartLineEntity>[].obs;

  // ── مؤشرات التحميل ──
  final isLoadingNetworks = false.obs;
  final isLoadingPos = false.obs;
  final isLoadingPackages = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();

  bool get canChangeTarget => !isSubmitting.value;

  int get totalCartVouchers =>
      cart.fold(0, (sum, line) => sum + line.voucherCount);

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// تحميل الشبكات المصرح بها
  Future<void> loadInitialData() async {
    isLoadingNetworks.value = true;
    errorMessage.value = null;

    try {
      final networks = await getMyNetworksUseCase();
      authorizedNetworks.assignAll(networks);

      if (networks.isNotEmpty) {
        final networkIds =
            networks.map((n) => n.networkId).toList(growable: false);
        final defaultId = WorkspaceService.to.resolveActiveNetworkId(networkIds) ??
            networks.first.networkId;
        await onNetworkSelected(defaultId);
      }
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ في جلب الشبكات',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل قائمة الشبكات: $e';
    } finally {
      isLoadingNetworks.value = false;
    }
  }

  /// اختيار الشبكة وجلب نقاط البيع المرتبطة وباقات الكروت
  Future<void> onNetworkSelected(int networkId) async {
    if (selectedNetworkId.value == networkId && linkedPos.isNotEmpty) return;

    selectedNetworkId.value = networkId;
    selectedPosId.value = null;
    cart.clear();

    await Future.wait([
      _loadLinkedPos(networkId),
      _loadPackages(networkId),
    ]);
  }

  Future<void> _loadLinkedPos(int networkId) async {
    isLoadingPos.value = true;
    try {
      final posLinks = await getNetworkPosListUseCase(networkId: networkId);
      final posList = posLinks.items
          .map((link) => link.pos)
          .whereType<PosEntity>()
          .toList(growable: false);
      linkedPos.assignAll(posList);
      if (posList.isNotEmpty) {
        selectedPosId.value = posList.first.posId;
      }
    } catch (_) {
      linkedPos.clear();
    } finally {
      isLoadingPos.value = false;
    }
  }

  Future<void> _loadPackages(int networkId) async {
    isLoadingPackages.value = true;
    try {
      final paginatedPackages = await getPackagesUseCase(
        networkId: networkId,
        perPage: 50,
      );
      availablePackages.assignAll(paginatedPackages.items);
    } catch (_) {
      availablePackages.clear();
    } finally {
      isLoadingPackages.value = false;
    }
  }

  /// اختيار نقطة البيع
  void onPosSelected(int posId) {
    selectedPosId.value = posId;
  }

  /// تعيين نوع البيع
  void setSaleType(SaleType type) {
    selectedSaleType.value = type;
  }

  /// إضافة باقة إلى السلة أو تحديث كميتها
  void addOrUpdatePackageInCart(PackageEntity package, int count) {
    if (count <= 0) {
      removeFromCart(package.packageId);
      return;
    }

    final existingIndex =
        cart.indexWhere((line) => line.package.packageId == package.packageId);

    if (existingIndex >= 0) {
      cart[existingIndex] = cart[existingIndex].copyWith(voucherCount: count);
    } else {
      cart.add(DirectInvoiceCartLineEntity(package: package, voucherCount: count));
    }
  }

  /// حذف باقة من السلة
  void removeFromCart(int packageId) {
    cart.removeWhere((line) => line.package.packageId == packageId);
  }

  /// إفراغ السلة
  void clearCart() {
    cart.clear();
  }

  /// إرسال وإنشاء الفاتورة السيادية
  Future<void> submitInvoice() async {
    final networkId = selectedNetworkId.value;
    final posId = selectedPosId.value;

    if (networkId == null) {
      CustomSnackbar.show(
        title: 'تحديد الشبكة',
        message: 'يرجى اختيار الشبكة الموردة.',
        type: SnackType.warning,
      );
      return;
    }

    if (posId == null) {
      CustomSnackbar.show(
        title: 'تحديد نقطة البيع',
        message: 'يرجى اختيار نقطة البيع المستفيدة.',
        type: SnackType.warning,
      );
      return;
    }

    if (cart.isEmpty) {
      CustomSnackbar.show(
        title: 'السلة فارغة',
        message: 'يرجى إضافة باقة واحدة على الأقل لإنشاء الفاتورة.',
        type: SnackType.warning,
      );
      return;
    }

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري إصدار وتثبيت الفاتورة على الخادم...',
    );

    try {
      final inputItems = cart
          .map(
            (line) => DirectInvoiceItemInputEntity(
              packageId: line.package.packageId,
              voucherCount: line.voucherCount,
            ),
          )
          .toList(growable: false);

      final idempotencyKey = IdempotencyHelper.generate('inv');

      final createdInvoice = await createDirectSaleInvoiceUseCase(
        networkId: networkId,
        posId: posId,
        saleType: selectedSaleType.value,
        items: inputItems,
        idempotencyKey: idempotencyKey,
      );

      CustomSnackbar.show(
        title: 'تم إصدار الفاتورة',
        message: 'تم إصدار الفاتورة #${createdInvoice.displayReference} بنجاح.',
        type: SnackType.success,
      );

      await Get.offNamed<void>(
        AppRoutes.saleInvoiceDetails,
        arguments: createdInvoice,
      );
    } on AppException catch (e) {
      CustomSnackbar.show(
        title: 'تعذر إنشاء الفاتورة',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ غير متوقع',
        message: 'تعذر إتمام عملية إصدار الفاتورة: $e',
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
