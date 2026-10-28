import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_logs_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_wallet_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/transfer_pos_wallet_balance_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// متحكم نافذة المحفظة التوزيعية الثنائية (PosWalletSheetController)
/// ============================================================================
/// يدير عرض بيانات المحفظة المسترجعة من الخادم، سجل العمليات، وإجراء التحويل البيني.
/// يلتزم بمبدأ عدم إجراء أي عمليات حسابية مالية في الواجهة، واعتبار الخادم المصدر الحصري للحقيقة.
class PosWalletSheetController extends GetxController {
  final GetPosWalletUseCase _getPosWalletUseCase;
  final TransferPosWalletBalanceUseCase _transferPosWalletBalanceUseCase;
  final GetPosWalletLogsUseCase _getPosWalletLogsUseCase;

  PosWalletSheetController({
    required GetPosWalletUseCase getPosWalletUseCase,
    required TransferPosWalletBalanceUseCase transferPosWalletBalanceUseCase,
    required GetPosWalletLogsUseCase getPosWalletLogsUseCase,
  })  : _getPosWalletUseCase = getPosWalletUseCase,
        _transferPosWalletBalanceUseCase = transferPosWalletBalanceUseCase,
        _getPosWalletLogsUseCase = getPosWalletLogsUseCase;

  final RxBool isLoading = false.obs;
  final RxBool isTransferring = false.obs;
  final RxnString errorMessage = RxnString();

  final Rxn<PosWalletEntity> posWallet = Rxn<PosWalletEntity>();
  final RxList<PosWalletLogEntity> logs = <PosWalletLogEntity>[].obs;

  final RxInt selectedTab = 0.obs; // 0: Overview & Ledger, 1: Transfer
  final RxInt transferDirection = 0.obs; // 0: Feed (From Network to POS), 1: Collect (From POS to Network)

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

  /// تهيئة النافذة بمعرفات الشبكة ونقطة البيع وجلب البيانات
  Future<void> init({
    required int networkId,
    required int posId,
  }) async {
    currentNetworkId = networkId;
    currentPosId = posId;
    selectedTab.value = 0;
    amountController.clear();
    statementController.clear();
    errorMessage.value = null;

    await loadWalletAndLogs();
  }

  /// جلب بيانات المحفظة وسجل القيود من الخادم
  Future<void> loadWalletAndLogs() async {
    if (currentNetworkId == null || currentPosId == null) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final wallet = await _getPosWalletUseCase(
        networkId: currentNetworkId!,
        posId: currentPosId!,
      );
      posWallet.value = wallet;

      final logsList = await _getPosWalletLogsUseCase(
        networkId: currentNetworkId!,
        posId: currentPosId!,
      );
      logs.assignAll(logsList);
    } catch (e) {
      errorMessage.value = e is AppException ? e.message : 'تعذر تحميل بيانات المحفظة';
    } finally {
      isLoading.value = false;
    }
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

    isTransferring.value = true;

    try {
      final statement = statementController.text.trim();
      final isFeed = transferDirection.value == 0;

      if (isFeed) {
        await _transferPosWalletBalanceUseCase.transferFromNetwork(
          networkId: currentNetworkId!,
          posId: currentPosId!,
          amount: amount,
          statement: statement.isNotEmpty ? statement : null,
        );
      } else {
        await _transferPosWalletBalanceUseCase.transferToNetwork(
          networkId: currentNetworkId!,
          posId: currentPosId!,
          amount: amount,
          statement: statement.isNotEmpty ? statement : null,
        );
      }

      CustomSnackbar.show(
        title: 'تم التحويل بنجاح',
        message: isFeed
            ? 'تم تحويل وتغذية الرصيد إلى نقطة البيع وتسجيل القيود.'
            : 'تم توريد واسترجاع الرصيد إلى الشبكة بنجاح.',
        type: SnackType.success,
      );

      amountController.clear();
      statementController.clear();
      selectedTab.value = 0; // Return to ledger tab

      // Refresh wallet and logs directly from server
      await loadWalletAndLogs();
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل التحويل',
        message: e is AppException ? e.message : 'تعذر تنفيذ عملية التحويل المالي',
        type: SnackType.error,
      );
    } finally {
      isTransferring.value = false;
    }
  }
}
