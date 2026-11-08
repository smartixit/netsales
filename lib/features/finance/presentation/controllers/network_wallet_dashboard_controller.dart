import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkWalletDashboardController extends GetxController {
  final GetNetworkWalletsUseCase getNetworkWalletsUseCase;
  final GetNetworkWalletLogsUseCase getNetworkWalletLogsUseCase;

  NetworkWalletDashboardController({
    required this.getNetworkWalletsUseCase,
    required this.getNetworkWalletLogsUseCase,
  });

  final wallets = <NetworkWalletEntity>[].obs;
  final selectedWallet = Rxn<NetworkWalletEntity>();
  final logs = <NetworkWalletLogEntity>[].obs;

  final isLoading = false.obs;
  final isLoadingLogs = false.obs;
  final isLoadingMoreLogs = false.obs;
  final nextCursor = RxnString();
  final walletsErrorMessage = RxnString();
  final logsErrorMessage = RxnString();

  bool get hasMoreLogs => nextCursor.value != null;

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
      final res = await getNetworkWalletsUseCase();
      wallets.assignAll(res.items);

      final selectedId = selectedWallet.value?.walletId;
      final selected = res.items.cast<NetworkWalletEntity?>().firstWhere(
        (wallet) => wallet?.walletId == selectedId,
        orElse: () => res.items.isEmpty ? null : res.items.first,
      );
      selectedWallet.value = selected;

      if (selected != null) {
        await loadWalletLogs(selected.walletId, isRefresh: true);
      } else {
        logs.clear();
        nextCursor.value = null;
        logsErrorMessage.value = null;
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
        fallback: 'تعذر تحميل محافظ الشبكة. يرجى المحاولة مجدداً.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectWallet(NetworkWalletEntity wallet) async {
    if (selectedWallet.value?.walletId == wallet.walletId) return;
    selectedWallet.value = wallet;
    logs.clear();
    await loadWalletLogs(wallet.walletId, isRefresh: true);
  }

  Future<void> loadWalletLogs(int walletId, {bool isRefresh = false}) async {
    if (isRefresh) {
      isLoadingLogs.value = true;
      nextCursor.value = null;
      logsErrorMessage.value = null;
    } else if (!hasMoreLogs) {
      return;
    }

    try {
      final res = await getNetworkWalletLogsUseCase(
        walletId,
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (selectedWallet.value?.walletId != walletId) return;
      if (isRefresh) {
        logs.assignAll(res.items);
      } else {
        logs.addAll(
          res.items.where(
            (item) => !logs.any((existing) => existing.logId == item.logId),
          ),
        );
      }
      nextCursor.value = res.nextCursor;
      logsErrorMessage.value = null;
    } on AppException catch (e) {
      logsErrorMessage.value = e.message;
      if (isRefresh) {
        CustomSnackbar.show(
          title: 'تعذر تحميل الحركات',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      logsErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل حركات المحفظة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (isRefresh) isLoadingLogs.value = false;
      isLoadingMoreLogs.value = false;
    }
  }

  Future<void> loadMoreLogs() async {
    final walletId = selectedWallet.value?.walletId;
    if (walletId == null || isLoadingMoreLogs.value || !hasMoreLogs) return;

    isLoadingMoreLogs.value = true;
    await loadWalletLogs(walletId, isRefresh: false);
  }
}
