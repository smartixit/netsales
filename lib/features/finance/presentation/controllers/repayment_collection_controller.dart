import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/idempotency_key_generator.dart';
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

  /// GetX remains the single source of truth for both selections.
  final selectedNetworkId = RxnInt();
  final selectedPosId = RxnInt();
  final selectedPos = Rxn<PosEntity>();
  final hasLoadedPosList = false.obs;
  int _posLoadRevision = 0;

  final amountController = TextEditingController();
  final refController = TextEditingController();
  final notesController = TextEditingController();
  final selectedMethod = 'CASH'.obs;

  final isLoadingInitial = false.obs;
  final isLoadingPos = false.obs;
  final initialErrorMessage = RxnString();
  final posErrorMessage = RxnString();
  final isSubmitting = false.obs;
  final lastResult = Rxn<PosRepaymentEntity>();
  String? _pendingCollectionKey;
  String? _pendingCollectionFingerprint;

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
    _posLoadRevision++;
    super.onClose();
  }

  Future<void> loadInitialData() async {
    if (isLoadingInitial.value || isSubmitting.value) return;
    isLoadingInitial.value = true;
    initialErrorMessage.value = null;
    try {
      final netList = await getMyNetworksUseCase();
      // Financial collections require an explicit beneficiary selection.
      // Never default to the first tenant or POS returned by the API.
      networks.assignAll(netList);
      ++_posLoadRevision;
      selectedNetworkId.value = null;
      selectedPosId.value = null;
      selectedPos.value = null;
      posList.clear();
      hasLoadedPosList.value = false;
      isLoadingPos.value = false;
      posErrorMessage.value = null;
    } on AppException catch (e) {
      initialErrorMessage.value = e.message;
    } catch (e) {
      initialErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل الشبكات المتاحة للتحصيل. يرجى المحاولة مجدداً.',
      );
    } finally {
      isLoadingInitial.value = false;
    }
  }

  Future<void> loadPosForNetwork(
    int networkId, {
    String? search,
    bool preserveSelection = false,
  }) async {
    if (isSubmitting.value) return;
    final revision = ++_posLoadRevision;
    if (!preserveSelection) {
      selectedPosId.value = null;
      selectedPos.value = null;
      posList.clear();
      hasLoadedPosList.value = false;
    }
    isLoadingPos.value = true;
    posErrorMessage.value = null;
    try {
      final normalizedSearch = search?.trim();
      final res = await getNetworkPosListUseCase(
        networkId,
        search: normalizedSearch == null || normalizedSearch.isEmpty
            ? null
            : normalizedSearch,
        status: true,
        perPage: 50,
      );
      if (revision != _posLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      posList.assignAll(
        res.items.map((link) => link.pos).whereType<PosEntity>(),
      );
      hasLoadedPosList.value = true;
      posErrorMessage.value = null;
    } on AppException catch (e) {
      if (revision != _posLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      if (!preserveSelection) {
        posList.clear();
      }
      posErrorMessage.value = e.message;
    } catch (e) {
      if (revision != _posLoadRevision ||
          selectedNetworkId.value != networkId) {
        return;
      }
      if (!preserveSelection) {
        posList.clear();
      }
      posErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل نقاط البيع المرتبطة بالشبكة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (revision == _posLoadRevision) {
        isLoadingPos.value = false;
      }
    }
  }

  Future<void> searchPosForNetwork(String query) async {
    if (isSubmitting.value) return;
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    await loadPosForNetwork(
      networkId,
      search: query,
      preserveSelection: true,
    );
  }

  void onPosChanged(int? posId) {
    if (isSubmitting.value) return;
    selectedPosId.value = posId;
    if (posId == null) {
      selectedPos.value = null;
      return;
    }
    selectedPos.value = posList.firstWhereOrNull(
          (pos) => pos.posId == posId,
        ) ??
        (selectedPos.value?.posId == posId ? selectedPos.value : null);
  }

  Future<void> onNetworkChanged(int? netId) async {
    if (netId == null || isSubmitting.value) return;
    // CustomDropdown writes to selectedNetworkId before calling onChanged.
    // Do not compare against the notifier here or the linked POS refresh is skipped.
    selectedNetworkId.value = netId;
    selectedPosId.value = null;
    selectedPos.value = null;
    posList.clear();
    hasLoadedPosList.value = false;
    await loadPosForNetwork(netId);
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
    final fingerprint = jsonEncode({
      'network_id': netId,
      'pos_id': pId,
      'amount': amount,
      'payment_method': selectedMethod.value,
      'reference_number': refController.text.trim(),
      'notes': notesController.text.trim(),
    });
    if (_pendingCollectionFingerprint != fingerprint ||
        _pendingCollectionKey == null) {
      _pendingCollectionFingerprint = fingerprint;
      _pendingCollectionKey = IdempotencyKeyGenerator.generate();
    }

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
        idempotencyKey: _pendingCollectionKey,
      );

      lastResult.value = repayment;
      _pendingCollectionKey = null;
      _pendingCollectionFingerprint = null;
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
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر إتمام السداد. يرجى المحاولة مجدداً.',
        ),
        type: SnackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }
}
