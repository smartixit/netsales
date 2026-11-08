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
  final walletsLoadMoreErrorMessage = RxnString();
  final walletsNextCursor = RxnString();
  final isLoadingMoreWallets = false.obs;
  final logsErrorMessage = RxnString();

  int _logsRequestVersion = 0;
  int _walletsRequestVersion = 0;

  bool get hasMoreWallets =>
      walletsNextCursor.value?.trim().isNotEmpty ?? false;

  bool get hasMoreLogs => nextCursor.value?.trim().isNotEmpty ?? false;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    if (isLoading.value) return;
    final requestVersion = ++_walletsRequestVersion;
    isLoading.value = true;
    isLoadingMoreWallets.value = false;
    walletsErrorMessage.value = null;
    walletsLoadMoreErrorMessage.value = null;
    walletsNextCursor.value = null;

    try {
      final res = await getNetworkWalletsUseCase(perPage: 15);
      if (requestVersion != _walletsRequestVersion) return;
      final previousSelected = selectedWallet.value;
      final availableWallets = List<NetworkWalletEntity>.of(res.items);
      NetworkWalletEntity? selected = previousSelected == null
          ? null
          : availableWallets.firstWhereOrNull(
              (wallet) => wallet.walletId == previousSelected.walletId,
            );
      selected ??= previousSelected ?? (availableWallets.isEmpty ? null : availableWallets.first);

      if (previousSelected != null &&
          !availableWallets.any(
            (wallet) => wallet.walletId == previousSelected.walletId,
          )) {
        availableWallets.insert(0, previousSelected);
      }

      wallets.assignAll(availableWallets);
      walletsNextCursor.value = res.nextCursor;
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
      if (requestVersion != _walletsRequestVersion) return;
      walletsErrorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      if (requestVersion != _walletsRequestVersion) return;
      walletsErrorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل محافظ الشبكة. يرجى المحاولة مجدداً.',
      );
    } finally {
      if (requestVersion == _walletsRequestVersion) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreWallets() async {
    if (isLoading.value || isLoadingMoreWallets.value || !hasMoreWallets) {
      return;
    }

    final requestVersion = ++_walletsRequestVersion;
    final requestedCursor = walletsNextCursor.value;
    isLoadingMoreWallets.value = true;
    walletsLoadMoreErrorMessage.value = null;

    try {
      final result = await getNetworkWalletsUseCase(
        cursor: requestedCursor,
        perPage: 15,
      );
      if (requestVersion != _walletsRequestVersion) return;

      final existingIds = wallets.map((wallet) => wallet.walletId).toSet();
      wallets.addAll(
        result.items.where((wallet) => existingIds.add(wallet.walletId)),
      );
      walletsNextCursor.value = result.nextCursor;
    } on AppException catch (e) {
      if (requestVersion == _walletsRequestVersion) {
        walletsLoadMoreErrorMessage.value = e.message;
      }
    } catch (e) {
      if (requestVersion == _walletsRequestVersion) {
        walletsLoadMoreErrorMessage.value = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل بقية المحافظ. يرجى المحاولة مجدداً.',
        );
      }
    } finally {
      if (requestVersion == _walletsRequestVersion) {
        isLoadingMoreWallets.value = false;
      }
    }
  }

  Future<void> selectWallet(NetworkWalletEntity wallet) async {
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
      final res = await getNetworkWalletLogsUseCase(
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
