import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/transfer_pos_wallet_balance_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم نافذة المحفظة التوزيعية الثنائية (PosWalletSheetController)
/// ============================================================================
/// يدير عرض بيانات المحفظة المسترجعة من الخادم، سجل العمليات، وإجراء التحويل البيني
/// مصاغ وفق النمط المعماري القياسي الموحد المعتمد في OperationsController.
class PosWalletSheetController extends GetxController {
  final GetPosWalletUseCase getPosWalletUseCase;
  final TransferPosWalletBalanceUseCase transferPosWalletBalanceUseCase;
  final GetPosWalletLogsUseCase getPosWalletLogsUseCase;

  PosWalletSheetController({
    required this.getPosWalletUseCase,
    required this.transferPosWalletBalanceUseCase,
    required this.getPosWalletLogsUseCase,
  });

  /// حالات تحميل البيانات والعمليات
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingAction = false.obs;
  final RxString errorMessage = ''.obs;

  /// بيانات المحفظة المسترجعة وسجل القيود
  final Rxn<PosWalletEntity> posWallet = Rxn<PosWalletEntity>();
  final RxList<PosWalletLogEntity> logs = <PosWalletLogEntity>[].obs;

  /// التبويب النشط: 0 للملخص والقيود، 1 للتحويل
  final RxInt selectedTab = 0.obs;
  /// اتجاه التحويل: 0 تغذية (من الشبكة لنقطة البيع)، 1 توريد (من نقطة البيع للشبكة)
  final RxInt transferDirection = 0.obs;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController statementController = TextEditingController();

  int? currentNetworkId;
  int? currentPosId;

  @override
  void onClose() {
    amountController.dispose();
    statementController.dispose();
    super.onClose();
  }

  /// تهيئة المتحكم ببيانات نقطة البيع والشبكة
  Future<void> init({
    required int networkId,
    required int posId,
  }) async {
    currentNetworkId = networkId;
    currentPosId = posId;
    selectedTab.value = 0;
    amountController.clear();
    statementController.clear();
    errorMessage.value = '';

    await loadWalletData();
  }

  /// جلب بيانات المحفظة وسجل القيود دفعة واحدة
  Future<void> loadWalletData({bool isRefresh = false}) async {
    if (currentNetworkId == null || currentPosId == null) return;

    if (!isRefresh) isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        getPosWalletUseCase(
          networkId: currentNetworkId!,
          posId: currentPosId!,
        ),
        getPosWalletLogsUseCase(
          networkId: currentNetworkId!,
          posId: currentPosId!,
        ),
      ]);

      posWallet.value = results[0] as PosWalletEntity;
      logs.assignAll(results[1] as List<PosWalletLogEntity>);
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'خطأ في التحديث',
          message: errorMessage.value,
          type: SnackType.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// تبديل التبويب بين الكشف والتحويل
  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// تبديل اتجاه التحويل
  void changeTransferDirection(int direction) {
    transferDirection.value = direction;
  }

  /// تنفيذ عملية التحويل المالي المشترك عبر الخادم
  Future<void> executeTransfer() async {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      CustomSnackbar.show(
        title: 'تنبيه إدخال',
        message: 'يرجى إدخال مبلغ مالي صالح للتحويل.',
        type: SnackType.warning,
      );
      return;
    }

    if (currentNetworkId == null || currentPosId == null) return;

    isSubmittingAction.value = true;
    final isFeed = transferDirection.value == 0;

    try {
      await CustomAnimationOverlay.showLoading(
        message: isFeed
            ? 'جارٍ تحويل وتغذية الرصيد إلى نقطة البيع...'
            : 'جارٍ توريد واسترجاع الرصيد إلى الشبكة...',
      );

      final statement = statementController.text.trim();

      if (isFeed) {
        await transferPosWalletBalanceUseCase.transferFromNetwork(
          networkId: currentNetworkId!,
          posId: currentPosId!,
          amount: amount,
          statement: statement.isNotEmpty ? statement : null,
        );
      } else {
        await transferPosWalletBalanceUseCase.transferToNetwork(
          networkId: currentNetworkId!,
          posId: currentPosId!,
          amount: amount,
          statement: statement.isNotEmpty ? statement : null,
        );
      }

      await loadWalletData(isRefresh: true);

      await CustomAnimationOverlay.showSuccess(
        message: isFeed
            ? 'تم تحويل وتغذية الرصيد إلى نقطة البيع وتسجيل القيود.'
            : 'تم توريد واسترجاع الرصيد إلى الشبكة بنجاح.',
      );

      amountController.clear();
      statementController.clear();
      selectedTab.value = 0;
    } catch (e) {
      await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر تنفيذ التحويل',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmittingAction.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }
}
