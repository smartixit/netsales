import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class PosWalletDashboardController extends GetxController {
  final GetPosWalUseCase getPosWalUseCase;
  final GetPosWalletLogsUseCase getPosWalletLogsUseCase;

  PosWalletDashboardController({
    required this.getPosWalUseCase,
    required this.getPosWalletLogsUseCase,
  });

  final wallets = <PosWalletEntity>[].obs;
  final selectedWallet = Rxn<PosWalletEntity>();
  final logs = <PosWalletLogEntity>[].obs;

  final isLoading = false.obs;
  final isLoadingLogs = false.obs;
  final isLoadingMoreLogs = false.obs;
  final nextCursor = RxnString();
  final walletsErrorMessage = RxnString();
  final logsErrorMessage = RxnString();

  int _logsRequestVersion = 0;

  bool get hasMoreLogs => nextCursor.value?.trim().isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    if (isLoading.value) return;
    isLoading.value = true;
    walletsErrorMessage.value = null;

    try {
      final res = await getPosWalUseCase();
      wallets.assignAll(res.items);

      PosWalletEntity? selected;
      final previousId = selectedWallet.value?.walletId;
      for (final wallet in res.items) {
        if (wallet.walletId == previousId) {
          selected = wallet;
          break;
        }
      }
      selected ??= res.items.isEmpty ? null : res.items.first;
      selectedWallet.value = selected;

      if (selected != null) {
        await loadWalletLogs(selected.walletId, isRefresh: true);
      } else {
        ++_logsRequestVersion;
        logs.clear();
        nextCursor.value = null;
        logsErrorMessage.value = null;
        isLoadingLogs.value = false;
        isLoadingMoreLogs.value = false;
      }
    } on AppException catch (e) {
      walletsErrorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      walletsErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل بيانات المحفظة. يرجى المحاولة مجدداً.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectWallet(PosWalletEntity wallet) async {
    if (selectedWallet.value?.walletId == wallet.walletId) return;
    selectedWallet.value = wallet;
    logs.clear();
    await loadWalletLogs(wallet.walletId, isRefresh: true);
  }

  Future<void> loadWalletLogs(int walletId, {bool isRefresh = false}) async {
    if (selectedWallet.value?.walletId != walletId) return;

    if (isRefresh) {
      isLoadingLogs.value = true;
      isLoadingMoreLogs.value = false;
      nextCursor.value = null;
      logsErrorMessage.value = null;
    } else {
      if (isLoadingLogs.value || isLoadingMoreLogs.value || !hasMoreLogs) {
        return;
      }
      isLoadingMoreLogs.value = true;
      logsErrorMessage.value = null;
    }

    final requestVersion = ++_logsRequestVersion;
    final requestedCursor = isRefresh ? null : nextCursor.value;

    try {
      final res = await getPosWalletLogsUseCase(
        walletId,
        cursor: requestedCursor,
        perPage: 15,
      );

      if (requestVersion != _logsRequestVersion ||
          selectedWallet.value?.walletId != walletId) {
        return;
      }

      if (isRefresh) {
        logs.assignAll(res.items);
      } else {
        final existingIds = logs.map((item) => item.logId).toSet();
        logs.addAll(
          res.items.where((item) => existingIds.add(item.logId)),
        );
      }
      nextCursor.value = res.nextCursor;
      logsErrorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _logsRequestVersion ||
          selectedWallet.value?.walletId != walletId) {
        return;
      }
      logsErrorMessage.value = e.message;
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'تعذر تحميل الحركات',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (requestVersion != _logsRequestVersion ||
          selectedWallet.value?.walletId != walletId) {
        return;
      }
      logsErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل حركات المحفظة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (requestVersion == _logsRequestVersion) {
        isLoadingLogs.value = false;
        isLoadingMoreLogs.value = false;
      }
    }
  }

  Future<void> loadMoreLogs() async {
    final walletId = selectedWallet.value?.walletId;
    if (walletId == null) return;
    await loadWalletLogs(walletId, isRefresh: false);
  }
}
