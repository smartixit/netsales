import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/idempotency_key_generator.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/deposit_pos_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_network_wallet_use_case.dart';
import 'package:netsales/features/finance/domain/usecases/withdraw_pos_wallet_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

enum ManualTransactionType {
  deposit,
  withdraw,
}

class ManualWalletTransactionController extends GetxController {
  ManualWalletTransactionController({
    required this.depositPosWalletUseCase,
    required this.withdrawPosWalletUseCase,
    required this.depositNetworkWalletUseCase,
    required this.withdrawNetworkWalletUseCase,
  });

  final DepositPosWalletUseCase depositPosWalletUseCase;
  final WithdrawPosWalletUseCase withdrawPosWalletUseCase;
  final DepositNetworkWalletUseCase depositNetworkWalletUseCase;
  final WithdrawNetworkWalletUseCase withdrawNetworkWalletUseCase;

  final formKey = GlobalKey<FormState>();
  final transactionType = ManualTransactionType.deposit.obs;
  final amountController = TextEditingController();
  final statementController = TextEditingController();
  final logDateController = TextEditingController();

  final enteredAmount = 0.0.obs;
  final isSubmitting = false.obs;

  int _walletId = 0;
  String _accountName = '';
  double _currentBalance = 0.0;
  bool _isPosWallet = true;
  VoidCallback? _onSuccess;

  int get walletId => _walletId;
  String get accountName => _accountName;
  double get currentBalance => _currentBalance;
  bool get isPosWallet => _isPosWallet;

  bool get isDeposit =>
      transactionType.value == ManualTransactionType.deposit;

  double get expectedBalance => isDeposit
      ? _currentBalance + enteredAmount.value
      : _currentBalance - enteredAmount.value;

  bool get isNegativeBalance => expectedBalance < 0;

  static const List<String> posDepositSuggestions = [
    'تسوية مبيعات',
    'بونص مبيعات تشجيعي',
    'رصيد مرتجع',
    'رصيد افتتاحي',
    'تعويض فروقات كروت',
  ];

  static const List<String> posWithdrawSuggestions = [
    'تسوية عجز حساب',
    'خصم عمولة مبيعات',
    'تسوية نقدية يدوية',
    'فروقات جرد',
    'استرداد رصيد',
  ];

  static const List<String> networkDepositSuggestions = [
    'توريد سيولة نقدية',
    'إيداع بنكي مركزي',
    'تسوية رصيد شبكة',
    'رصيد افتتاحي للشبكة',
  ];

  static const List<String> networkWithdrawSuggestions = [
    'سحب أرباح تشغيلية',
    'تسوية رصيد حساب',
    'تغذية سيولة خارجية',
  ];

  List<String> get currentSuggestions => _isPosWallet
      ? (isDeposit ? posDepositSuggestions : posWithdrawSuggestions)
      : (isDeposit ? networkDepositSuggestions : networkWithdrawSuggestions);

  void initialize({
    required int walletId,
    required String accountName,
    required double currentBalance,
    bool isPosWallet = true,
    VoidCallback? onSuccess,
  }) {
    _walletId = walletId;
    _accountName = accountName;
    _currentBalance = currentBalance;
    _isPosWallet = isPosWallet;
    _onSuccess = onSuccess;

    transactionType.value = ManualTransactionType.deposit;
    amountController.clear();
    statementController.clear();
    logDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    enteredAmount.value = 0.0;
    isSubmitting.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final text = amountController.text.trim();
    enteredAmount.value = double.tryParse(text) ?? 0.0;
  }

  @override
  void onClose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    statementController.dispose();
    logDateController.dispose();
    super.onClose();
  }

  void setTransactionTypeIndex(int index) {
    transactionType.value =
        index == 0 ? ManualTransactionType.deposit : ManualTransactionType.withdraw;
  }

  void selectSuggestion(String suggestion) {
    statementController.text = suggestion;
  }

  Future<void> submit() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount < 0.01) {
      CustomSnackbar.show(
        title: 'قيمة غير صالحة',
        message: 'أدخل مبلغاً صحيحاً لا يقل عن 0.01.',
        type: SnackType.warning,
      );
      return;
    }

    final statement = statementController.text.trim();
    if (statement.isEmpty) {
      CustomSnackbar.show(
        title: 'البيان مطلوب',
        message: 'يرجى إدخال سبب أو بيان رسمي للقيد المالي.',
        type: SnackType.warning,
      );
      return;
    }

    final typeLabel = isDeposit ? 'إيداع مالي مباشر' : 'سحب مالي مباشر';

    final confirmed = await CustomDialog.show(
      type: isDeposit ? DialogType.confirmation : DialogType.warning,
      title: 'تأكيد $typeLabel',
      message:
          'هل أنت متأكد من تنفيذ عملية ($typeLabel) بمبلغ ${AmountFormatter.formatValue(amount)} في حساب ($_accountName)؟\nسيتم تسجيل القيد فورياً بدفتر الأستاذ.',
      confirmLabel: 'تأكيد التنفيذ',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isSubmitting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري تسجيل القيد المالي بدفتر الأستاذ...',
    );

    try {
      final idempotencyKey = IdempotencyKeyGenerator.generate();
      final date = logDateController.text.trim().isEmpty
          ? null
          : logDateController.text.trim();

      if (_isPosWallet) {
        if (isDeposit) {
          await depositPosWalletUseCase(
            posWalletId: _walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        } else {
          await withdrawPosWalletUseCase(
            posWalletId: _walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        }
      } else {
        if (isDeposit) {
          await depositNetworkWalletUseCase(
            networkWalletId: _walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        } else {
          await withdrawNetworkWalletUseCase(
            networkWalletId: _walletId,
            amount: amount,
            statement: statement,
            logDate: date,
            idempotencyKey: idempotencyKey,
          );
        }
      }

      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      await CustomAnimationOverlay.showSuccess(
        message: 'تم إدراج القيد المالي وتحديث الرصيد بنجاح',
      );
      Get.back<void>();
      _onSuccess?.call();
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'تعذر تنفيذ القيد',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تسجيل القيد المالي بدفتر الأستاذ. يرجى المحاولة مجدداً.',
        ),
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

