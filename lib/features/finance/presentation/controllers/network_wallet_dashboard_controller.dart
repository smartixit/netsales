import 'dart:async';

import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/export_wallet_statement_document_use_case.dart';
import 'package:netsales/features/finance/presentation/widgets/manual_wallet_transaction_sheet.dart';
import 'package:netsales/features/finance/presentation/widgets/network_wallet_transfer_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkWalletDashboardController extends GetxController {
  final GetNetworkWalletsUseCase getNetworkWalletsUseCase;
  final GetNetworkWalletLogsUseCase getNetworkWalletLogsUseCase;
  final ExportWalletStatementDocumentUseCase exportWalletStatementDocumentUseCase;

  NetworkWalletDashboardController({
    required this.getNetworkWalletsUseCase,
    required this.getNetworkWalletLogsUseCase,
    required this.exportWalletStatementDocumentUseCase,
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
  final isExportingStatement = false.obs;

  static const int _maxStatementRows = 2000;

  int _logsRequestVersion = 0;
  int _walletsRequestVersion = 0;

  bool get hasMoreWallets =>
      walletsNextCursor.value?.trim().isNotEmpty ?? false;

  bool get hasMoreLogs => nextCursor.value?.trim().isNotEmpty ?? false;

  bool get canTransfer {
    final wallet = selectedWallet.value;
    if (wallet == null || !wallet.status) return false;
    final permissions = PermissionService.to;
    if (permissions.hasRole(AppRoles.superAdmin)) return false;
    return permissions.hasRole(AppRoles.networkOwner) ||
        permissions.can(AppPermissions.posWalletsCreate);
  }

  void openTransferSheet() {
    final wallet = selectedWallet.value;
    if (wallet == null) return;
    unawaited(NetworkWalletTransferSheet.show(wallet));
  }

  void openManualTransactionSheet() {
    final wallet = selectedWallet.value;
    if (wallet == null) return;
    unawaited(
      ManualWalletTransactionSheet.show(
        walletId: wallet.walletId,
        accountName:
            wallet.networkName ?? 'محفظة الشبكة #${wallet.networkId}',
        currentBalance: wallet.walletBalance,
        isPosWallet: false,
        onSuccess: loadWallets,
      ),
    );
  }

  bool _isAccessUnavailable(AppException error) {
    final message = error.message.toLowerCase();
    return message.contains('غير مصرح') ||
        message.contains('ليس لديك الصلاحية') ||
        message.contains('غير موجود') ||
        message.contains('forbidden') ||
        message.contains('not found');
  }

  void _clearUnavailableWallet(int walletId, String message) {
    wallets.removeWhere((wallet) => wallet.walletId == walletId);
    if (selectedWallet.value?.walletId != walletId) return;
    selectedWallet.value = null;
    logs.clear();
    nextCursor.value = null;
    logsErrorMessage.value = null;
    walletsErrorMessage.value = message;
    isLoadingLogs.value = false;
    isLoadingMoreLogs.value = false;
  }

  void _clearAllWalletAccess() {
    wallets.clear();
    selectedWallet.value = null;
    logs.clear();
    walletsNextCursor.value = null;
    walletsLoadMoreErrorMessage.value = null;
    nextCursor.value = null;
    logsErrorMessage.value = null;
    isLoadingLogs.value = false;
    isLoadingMoreLogs.value = false;
    isLoadingMoreWallets.value = false;
  }

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
      final availableWallets = List<NetworkWalletEntity>.of(res.items);
      final previousSelected = selectedWallet.value;
      final previousId = previousSelected?.walletId;
      var selected = previousId == null
          ? (availableWallets.isEmpty ? null : availableWallets.first)
          : availableWallets.firstWhereOrNull(
              (wallet) => wallet.walletId == previousId,
            );

      // The first cursor page cannot prove that an off-page wallet was revoked.
      if (selected == null && previousSelected != null) {
        selected = previousSelected;
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
      if (_isAccessUnavailable(e)) _clearAllWalletAccess();
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
        logs.addAll(res.items.where((item) => existingIds.add(item.logId)));
      }
      nextCursor.value = res.nextCursor;
      logsErrorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion != _logsRequestVersion ||
          selectedWallet.value?.walletId != walletId) {
        return;
      }
      if (_isAccessUnavailable(e)) {
        _clearUnavailableWallet(walletId, e.message);
      } else {
        logsErrorMessage.value = e.message;
      }
      if (isRefresh && selectedWallet.value?.walletId == walletId) {
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

  Future<void> exportStatementPdf() async {
    final wallet = selectedWallet.value;
    if (wallet == null || isExportingStatement.value) return;
    isExportingStatement.value = true;
    try {
      final statementLogs = await _loadAllStatementLogs(wallet.walletId);
      if (selectedWallet.value?.walletId != wallet.walletId) return;
      final success = await exportWalletStatementDocumentUseCase.exportNetwork(wallet, statementLogs);
      CustomSnackbar.show(
        title: success ? 'تم إنشاء كشف الحساب' : 'تعذر حفظ كشف الحساب',
        message: success ? 'تم تجهيز كشف حساب محفظة الشبكة وحفظ ملف PDF.' : 'لم تكتمل عملية حفظ ملف كشف الحساب.',
        type: success ? SnackType.success : SnackType.error,
      );
    } catch (error) {
      final message = error is StateError
          ? error.toString().replaceFirst('Bad state: ', '')
          : AppException.sanitizeMessage(error, fallback: 'تعذر إنشاء كشف حساب محفظة الشبكة.');
      CustomSnackbar.show(title: 'تعذر إنشاء كشف الحساب', message: message, type: SnackType.error);
    } finally {
      isExportingStatement.value = false;
    }
  }

  Future<List<NetworkWalletLogEntity>> _loadAllStatementLogs(int walletId) async {
    final result = <NetworkWalletLogEntity>[];
    final seenCursors = <String>{};
    String? cursor;
    do {
      if (selectedWallet.value?.walletId != walletId) {
        throw StateError('تم تغيير المحفظة أثناء تجهيز الكشف؛ أعد المحاولة.');
      }
      final page = await getNetworkWalletLogsUseCase(walletId, cursor: cursor, perPage: 50);
      result.addAll(page.items);
      if (result.length > _maxStatementRows) {
        throw StateError('يتجاوز عدد الحركات الحد الآمن لتوليد PDF؛ لم يتم إنشاء كشف جزئي.');
      }
      cursor = page.nextCursor?.trim();
      if (cursor != null && cursor.isEmpty) cursor = null;
      if (cursor != null && !seenCursors.add(cursor)) {
        throw StateError('توقف ترقيم الحركات عند مؤشر متكرر؛ لم يتم إنشاء كشف ناقص.');
      }
    } while (cursor != null);
    return result;
  }

  Future<void> loadMoreLogs() async {
    final walletId = selectedWallet.value?.walletId;
    if (walletId == null) return;
    await loadWalletLogs(walletId, isRefresh: false);
  }
}
