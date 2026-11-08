import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class RepaymentCollectionController extends GetxController {
  final CollectRepaymentUseCase collectRepaymentUseCase;
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;

  RepaymentCollectionController({
    required this.collectRepaymentUseCase,
    required this.getMyNetworksUseCase,
    required this.getNetworkPosListUseCase,
  });

  final networks = <NetworkEntity>[].obs;
  final posList = <PosEntity>[].obs;

  /// Selection state is exposed as ValueListenable for the shared CustomDropdown.
  /// The controller remains the single owner of both selected values.
  final selectedNetworkId = ValueNotifier<int?>(null);
  final selectedPosId = ValueNotifier<int?>(null);
  int _posLoadRevision = 0;

  final amountController = TextEditingController();
  final refController = TextEditingController();
  final notesController = TextEditingController();
  final selectedMethod = 'CASH'.obs;

  final isLoadingInitial = false.obs;
  final isSubmitting = false.obs;
  final lastResult = Rxn<PosRepaymentEntity>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    amountController.dispose();
    refController.dispose();
    notesController.dispose();
    selectedNetworkId.dispose();
    selectedPosId.dispose();
    _posLoadRevision++;
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoadingInitial.value = true;
    try {
      final netList = await getMyNetworksUseCase();
      networks.assignAll(netList);
      if (networks.isNotEmpty) {
        selectedNetworkId.value = networks.first.networkId;
        await loadPosForNetwork(networks.first.networkId);
      }
    } catch (_) {
      // initial load
    } finally {
      isLoadingInitial.value = false;
    }
  }

  Future<void> loadPosForNetwork(int networkId) async {
    final revision = ++_posLoadRevision;
    try {
      final res = await getNetworkPosListUseCase(networkId);
      if (revision != _posLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      posList.assignAll(
        res.items.map((link) => link.pos).whereType<PosEntity>(),
      );
      selectedPosId.value =
          posList.isNotEmpty ? posList.first.posId : null;
    } catch (_) {
      if (revision != _posLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      posList.clear();
      selectedPosId.value = null;
    }
  }

  void onNetworkChanged(int? netId) {
    if (netId == null) return;
    // CustomDropdown writes to selectedNetworkId before calling onChanged.
    // Do not compare against the notifier here or the linked POS refresh is skipped.
    selectedNetworkId.value = netId;
    posList.clear();
    selectedPosId.value = null;
    loadPosForNetwork(netId);
  }

  Future<bool> submitRepayment() async {
    final netId = selectedNetworkId.value;
    final pId = selectedPosId.value;
    final amount = double.tryParse(amountController.text.trim());

    if (netId == null || pId == null || amount == null || amount <= 0) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'يرجى اختيار الشبكة ونقطة البيع وتحديد مبلغ سداد صحيح.',
        type: SnackType.warning,
      );
      return false;
    }

    if (isSubmitting.value) return false;
    isSubmitting.value = true;

    await CustomAnimationOverlay.showLoading(
      message: 'جاري تحصيل السداد وتوزيعه وفق FIFO...',
    );

    try {
      final repayment = await collectRepaymentUseCase(
        networkId: netId,
        posId: pId,
        amount: amount,
        paymentMethod: selectedMethod.value,
        referenceNumber: refController.text.trim().isEmpty
            ? null
            : refController.text.trim(),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      lastResult.value = repayment;
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحصيل السداد وتسويته بنجاح',
      );
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'فشل التحصيل',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'تعذر إتمام السداد: $e',
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }
}
