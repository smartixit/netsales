import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/idempotency_key_generator.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkWalletTransferController extends GetxController {
  final TransferFromNetworkToPosUseCase transferFromNetworkToPosUseCase;
  final GetNetworkPosListUseCase getNetworkPosListUseCase;

  NetworkWalletTransferController({
    required this.transferFromNetworkToPosUseCase,
    required this.getNetworkPosListUseCase,
  });

  final selectedWallet = Rxn<NetworkWalletEntity>();
  final posList = <PosEntity>[].obs;
  final selectedPosId = RxnInt();
  final selectedPos = Rxn<PosEntity>();
  final amountController = TextEditingController();
  final statementController = TextEditingController();

  final isLoadingPos = false.obs;
  final hasLoadedPosList = false.obs;
  final posErrorMessage = RxnString();
  final posNextCursor = RxnString();
  final isLoadingMorePos = false.obs;
  final posLoadMoreErrorMessage = RxnString();
  final isSubmitting = false.obs;

  String _searchQuery = '';
  int _requestVersion = 0;
  String? _pendingKey;
  String? _pendingFingerprint;

  bool get hasMorePos => posNextCursor.value?.trim().isNotEmpty ?? false;

  void initialize(NetworkWalletEntity wallet) {
    ++_requestVersion;
    selectedWallet.value = wallet;
    posList.clear();
    selectedPosId.value = null;
    selectedPos.value = null;
    amountController.clear();
    statementController.clear();
    posNextCursor.value = null;
    posErrorMessage.value = null;
    posLoadMoreErrorMessage.value = null;
    hasLoadedPosList.value = false;
    isLoadingPos.value = false;
    isLoadingMorePos.value = false;
    isSubmitting.value = false;
    _searchQuery = '';
    _pendingKey = null;
    _pendingFingerprint = null;
    loadPosForNetwork();
  }

  @override
  void onClose() {
    ++_requestVersion;
    amountController.dispose();
    statementController.dispose();
    super.onClose();
  }

  Future<void> loadPosForNetwork({
    String? search,
    String? cursor,
    bool append = false,
  }) async {
    final wallet = selectedWallet.value;
    if (wallet == null || isSubmitting.value) return;

    final requestVersion = ++_requestVersion;
    if (append) {
      isLoadingMorePos.value = true;
      posLoadMoreErrorMessage.value = null;
    } else {
      isLoadingPos.value = true;
      posErrorMessage.value = null;
    }

    try {
      final normalizedSearch = search?.trim();
      final result = await getNetworkPosListUseCase(
        wallet.networkId,
        cursor: cursor,
        search: normalizedSearch == null || normalizedSearch.isEmpty
            ? null
            : normalizedSearch,
        status: true,
        perPage: 50,
      );

      if (requestVersion != _requestVersion ||
          selectedWallet.value?.walletId != wallet.walletId) {
        return;
      }

      final pageItems = result.items
          .map((link) => link.pos)
          .whereType<PosEntity>()
          .toList(growable: false);
      if (append) {
        final existingIds = posList.map((pos) => pos.posId).toSet();
        posList.addAll(pageItems.where((pos) => existingIds.add(pos.posId)));
      } else {
        posList.assignAll(pageItems);
      }
      posNextCursor.value = result.nextCursor;
      hasLoadedPosList.value = true;
      posErrorMessage.value = null;
      posLoadMoreErrorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _requestVersion) return;
      if (append) {
        posLoadMoreErrorMessage.value = e.message;
      } else {
        posErrorMessage.value = e.message;
      }
    } catch (e) {
      if (requestVersion != _requestVersion) return;
      final message = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل نقاط البيع المرتبطة بهذه الشبكة.',
      );
      if (append) {
        posLoadMoreErrorMessage.value = message;
      } else {
        posErrorMessage.value = message;
      }
    } finally {
      if (requestVersion == _requestVersion) {
        isLoadingPos.value = false;
        isLoadingMorePos.value = false;
      }
    }
  }

  Future<void> searchPos(String query) async {
    _searchQuery = query.trim();
    posNextCursor.value = null;
    posLoadMoreErrorMessage.value = null;
    await loadPosForNetwork(search: _searchQuery);
  }

  Future<void> loadMorePos() async {
    if (isSubmitting.value ||
        isLoadingPos.value ||
        isLoadingMorePos.value ||
        !hasMorePos) {
      return;
    }
    await loadPosForNetwork(
      search: _searchQuery,
      cursor: posNextCursor.value,
      append: true,
    );
  }

  void onPosChanged(int? posId) {
    selectedPosId.value = posId;
    selectedPos.value = posId == null
        ? null
        : posList.firstWhereOrNull((pos) => pos.posId == posId);
  }

  Future<bool> submitTransfer() async {
    final wallet = selectedWallet.value;
    final posId = selectedPosId.value;
    final amount = double.tryParse(amountController.text.trim());
    if (wallet == null || !wallet.status || posId == null ||
        amount == null || !amount.isFinite || amount < 0.01) {
      CustomSnackbar.show(
        title: 'بيانات التحويل غير مكتملة',
        message: 'اختر نقطة البيع وأدخل مبلغاً صحيحاً لا يقل عن 0.01.',
        type: SnackType.warning,
      );
      return false;
    }
    if (isSubmitting.value) return false;

    final fingerprint = jsonEncode({
      'network_id': wallet.networkId,
      'pos_id': posId,
      'amount': amount,
      'statement': statementController.text.trim(),
    });
    if (_pendingFingerprint != fingerprint || _pendingKey == null) {
      _pendingFingerprint = fingerprint;
      _pendingKey = IdempotencyKeyGenerator.generate();
    }

    isSubmitting.value = true;
    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جاري تحويل الرصيد والتحقق من صلاحية المحفظة...',
      );
      await transferFromNetworkToPosUseCase(
        networkId: wallet.networkId,
        posId: posId,
        amount: amount,
        statement: statementController.text.trim().isEmpty
            ? null
            : statementController.text.trim(),
        idempotencyKey: _pendingKey,
      );
      await CustomAnimationOverlay.showSuccess(
        message: 'تم تحويل الرصيد إلى نقطة البيع بنجاح',
      );
      _pendingKey = null;
      _pendingFingerprint = null;
      Get.back<void>();
      if (Get.isRegistered<NetworkWalletDashboardController>()) {
        await Get.find<NetworkWalletDashboardController>().loadWallets();
      }
      return true;
    } on AppException catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل التحويل',
        message: e.message,
        type: SnackType.error,
      );
      return false;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر تنفيذ التحويل',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحويل الرصيد. يرجى المحاولة مجدداً.',
        ),
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
