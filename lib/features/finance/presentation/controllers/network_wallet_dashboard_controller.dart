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
  final errorMessage = RxnString();

  bool get hasMoreLogs => nextCursor.value != null;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final res = await getNetworkWalletsUseCase();
      wallets.assignAll(res.items);
      if (wallets.isNotEmpty) {
        selectedWallet.value = wallets.first;
        await loadWalletLogs(wallets.first.walletId, isRefresh: true);
      }
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل محافظ الشبكة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectWallet(NetworkWalletEntity wallet) {
    if (selectedWallet.value?.walletId == wallet.walletId) return;
    selectedWallet.value = wallet;
    loadWalletLogs(wallet.walletId, isRefresh: true);
  }

  Future<void> loadWalletLogs(int walletId, {bool isRefresh = false}) async {
    if (isRefresh) {
      isLoadingLogs.value = true;
      nextCursor.value = null;
    }

    try {
      final res = await getNetworkWalletLogsUseCase(
        walletId,
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (isRefresh) {
        logs.assignAll(res.items);
      } else {
        logs.addAll(res.items);
      }
      nextCursor.value = res.nextCursor;
    } catch (e) {
      // logs failure
    } finally {
      isLoadingLogs.value = false;
      isLoadingMoreLogs.value = false;
    }
  }

  Future<void> loadMoreLogs() async {
    final wId = selectedWallet.value?.walletId;
    if (wId == null || isLoadingMoreLogs.value || !hasMoreLogs) return;

    isLoadingMoreLogs.value = true;
    await loadWalletLogs(wId, isRefresh: false);
  }
}
