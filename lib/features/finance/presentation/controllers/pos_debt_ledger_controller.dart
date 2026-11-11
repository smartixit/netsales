import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class PosDebtLedgerController extends GetxController {
  final GetDebtSummaryUseCase getDebtSummaryUseCase;
  final GetOutstandingInvoicesUseCase getOutstandingInvoicesUseCase;
  final GetMyPosUseCase getMyPosUseCase;
  final GetPosNetworksListUseCase getPosNetworksListUseCase;

  PosDebtLedgerController({
    required this.getDebtSummaryUseCase,
    required this.getOutstandingInvoicesUseCase,
    required this.getMyPosUseCase,
    required this.getPosNetworksListUseCase,
  });

  final posOptions = <PosEntity>[].obs;
  final networkLinks = <NetworkPosLinkEntity>[].obs;
  final selectedPosId = Rxn<int>();
  final selectedNetworkId = Rxn<int>();

  final isLoadingScope = false.obs;
  final isLoadingNetworks = false.obs;
  final isSearchingNetworks = false.obs;
  final scopeErrorMessage = RxnString();
  final networksErrorMessage = RxnString();
  final networkSearchErrorMessage = RxnString();
  final networkSearchQuery = ''.obs;
  final networkSearchHasNoResults = false.obs;
  final networkNextCursor = RxnString();
  final isLoadingMoreNetworks = false.obs;
  final networkOptionsLoadMoreErrorMessage = RxnString();
  final requiresNetworkSelection = false.obs;

  final summary = Rxn<DebtSummaryEntity>();
  final outstandingInvoices = <InvoiceEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingInvoices = false.obs;
  final isLoadingMore = false.obs;
  final selectedBucket = RxnString();
  final nextCursor = RxnString();
  final summaryErrorMessage = RxnString();
  final invoicesErrorMessage = RxnString();

  int _posOptionsRequestVersion = 0;
  int _networkOptionsRequestVersion = 0;
  int _scopeVersion = 0;
  int _summaryRequestVersion = 0;
  int _invoiceRequestVersion = 0;

  bool get hasMore => nextCursor.value?.trim().isNotEmpty ?? false;
  bool get hasMoreNetworkOptions =>
      networkNextCursor.value?.trim().isNotEmpty ?? false;
  bool get hasSelectedScope =>
      selectedPosId.value != null && selectedNetworkId.value != null;

  void openInvoiceDetails(InvoiceEntity invoice) {
    Get.toNamed<void>(
      AppRoutes.purchaseInvoiceDetails,
      arguments: invoice,
    );
  }

  PosEntity? get selectedPos {
    final id = selectedPosId.value;
    if (id == null) return null;
    for (final pos in posOptions) {
      if (pos.posId == id) return pos;
    }
    return null;
  }

  NetworkPosLinkEntity? get selectedNetwork {
    final id = selectedNetworkId.value;
    if (id == null) return null;
    for (final link in networkLinks) {
      if (link.networkId == id) return link;
    }
    return _selectedNetworkFallback?.networkId == id
        ? _selectedNetworkFallback
        : null;
  }

  NetworkPosLinkEntity? _selectedNetworkFallback;

  String posName(int posId) {
    for (final pos in posOptions) {
      if (pos.posId == posId) return pos.posName;
    }
    return 'نقطة البيع رقم $posId';
  }

  String networkName(int networkId) {
    for (final link in networkLinks) {
      if (link.networkId == networkId) return networkLabel(link);
    }
    final selected = _selectedNetworkFallback;
    if (selected?.networkId == networkId) return networkLabel(selected!);
    return 'مزود الشبكة رقم $networkId';
  }

  String networkLabel(NetworkPosLinkEntity link) {
    final name = link.network?.networkName.trim();
    return name != null && name.isNotEmpty
        ? name
        : 'مزود الشبكة رقم ${link.networkId}';
  }

  @override
  void onInit() {
    super.onInit();
    initializeScope();
  }

  Future<void> initializeScope() async {
    final requestVersion = ++_posOptionsRequestVersion;
    ++_networkOptionsRequestVersion;
    _scopeVersion++;
    _resetDebtState();

    isLoadingScope.value = true;
    scopeErrorMessage.value = null;
    networksErrorMessage.value = null;
    networkSearchErrorMessage.value = null;
    networkSearchHasNoResults.value = false;
    requiresNetworkSelection.value = false;
    posOptions.clear();
    networkLinks.clear();
    networkNextCursor.value = null;
    isLoadingMoreNetworks.value = false;
    networkOptionsLoadMoreErrorMessage.value = null;
    selectedPosId.value = null;
    selectedNetworkId.value = null;
    _selectedNetworkFallback = null;
    networkSearchQuery.value = '';

    var autoSelectPosId = 0;
    try {
      final result = await getMyPosUseCase();
      if (requestVersion != _posOptionsRequestVersion) return;

      final uniquePositions = <PosEntity>[];
      final seenIds = <int>{};
      for (final pos in result) {
        if (pos.posId > 0 && seenIds.add(pos.posId)) {
          uniquePositions.add(pos);
        }
      }
      posOptions.assignAll(uniquePositions);

      final posIds = uniquePositions.map((p) => p.posId).toList(growable: false);
      final resolvedId = WorkspaceService.to.resolveActivePosId(posIds);
      if (resolvedId != null) {
        autoSelectPosId = resolvedId;
      }
    } on AppException catch (e) {
      if (requestVersion == _posOptionsRequestVersion) {
        scopeErrorMessage.value = e.message;
      }
    } catch (e) {
      if (requestVersion == _posOptionsRequestVersion) {
        scopeErrorMessage.value = AppException.sanitizeMessage(
          e,
          fallback:
              'تعذر تحميل نقاط البيع التابعة لحسابك. يرجى المحاولة مجدداً.',
        );
      }
    } finally {
      if (requestVersion == _posOptionsRequestVersion) {
        isLoadingScope.value = false;
      }
    }

    if (requestVersion == _posOptionsRequestVersion && autoSelectPosId > 0) {
      await selectPos(autoSelectPosId);
    }
  }

  Future<void> selectPos(int posId) async {
    PosEntity? nextPos;
    for (final pos in posOptions) {
      if (pos.posId == posId) {
        nextPos = pos;
        break;
      }
    }
    if (nextPos == null || selectedPosId.value == posId) return;

    selectedPosId.value = posId;
    await WorkspaceService.to.saveActivePosId(posId);
    selectedNetworkId.value = null;
    _selectedNetworkFallback = null;
    _scopeVersion++;
    ++_networkOptionsRequestVersion;
    _resetDebtState();

    networkLinks.clear();
    networkNextCursor.value = null;
    networksErrorMessage.value = null;
    networkSearchErrorMessage.value = null;
    networkSearchHasNoResults.value = false;
    requiresNetworkSelection.value = false;
    networkSearchQuery.value = '';

    await loadNetworksForSelectedPos();
  }

  Future<void> loadNetworksForSelectedPos() async {
    final posId = selectedPosId.value;
    if (posId == null) return;

    await _fetchNetworkLinks(posId: posId, search: null, isSearch: false);
  }

  Future<void> searchNetworks(String query) async {
    final posId = selectedPosId.value;
    if (posId == null) return;

    networkSearchQuery.value = query.trim();
    networkNextCursor.value = null;
    networkOptionsLoadMoreErrorMessage.value = null;
    await _fetchNetworkLinks(
      posId: posId,
      search: query.trim().isEmpty ? null : query.trim(),
      isSearch: true,
    );
  }

  /// Loads the next cursor page while retaining the active POS and remote-search scope.
  Future<void> loadMoreNetworkOptions() async {
    final posId = selectedPosId.value;
    if (posId == null ||
        !hasMoreNetworkOptions ||
        isLoadingNetworks.value ||
        isSearchingNetworks.value ||
        isLoadingMoreNetworks.value) {
      return;
    }

    final search = networkSearchQuery.value.trim();
    await _fetchNetworkLinks(
      posId: posId,
      search: search.isEmpty ? null : search,
      isSearch: search.isNotEmpty,
      cursor: networkNextCursor.value,
      append: true,
    );
  }

  Future<void> _fetchNetworkLinks({
    required int posId,
    required String? search,
    required bool isSearch,
    String? cursor,
    bool append = false,
  }) async {
    final requestVersion = ++_networkOptionsRequestVersion;
    if (append) {
      isLoadingMoreNetworks.value = true;
      networkOptionsLoadMoreErrorMessage.value = null;
    } else if (isSearch) {
      isSearchingNetworks.value = true;
      networkSearchErrorMessage.value = null;
      networkSearchHasNoResults.value = false;
    } else {
      isLoadingNetworks.value = true;
      networksErrorMessage.value = null;
      networkSearchErrorMessage.value = null;
      networkOptionsLoadMoreErrorMessage.value = null;
    }

    var autoSelectNetworkId = 0;
    try {
      final result = await getPosNetworksListUseCase(
        posId,
        cursor: cursor,
        search: search,
        perPage: 50,
      );

      if (requestVersion != _networkOptionsRequestVersion ||
          selectedPosId.value != posId) {
        return;
      }

      final uniqueLinks = <NetworkPosLinkEntity>[];
      final seenNetworkIds = <int>{};
      for (final link in result.items) {
        if (link.networkId > 0 && seenNetworkIds.add(link.networkId)) {
          uniqueLinks.add(link);
        }
      }

      if (isSearch && search != null && uniqueLinks.isEmpty && !append) {
        // Keep the active scope and the previous usable options intact.
        networkSearchHasNoResults.value = true;
        networkNextCursor.value = result.nextCursor;
      } else {
        if (append) {
          final existingIds = networkLinks
              .map((link) => link.networkId)
              .toSet();
          networkLinks.addAll(
            uniqueLinks.where((link) => existingIds.add(link.networkId)),
          );
        } else {
          networkLinks.assignAll(uniqueLinks);
        }
        networkNextCursor.value = result.nextCursor;
      }

      if (!isSearch && !append) {
        final hasMultipleNetworks =
            uniqueLinks.length > 1 || result.nextCursor != null;
        requiresNetworkSelection.value = hasMultipleNetworks;

        if (selectedNetworkId.value == null &&
            uniqueLinks.length == 1 &&
            result.nextCursor == null) {
          autoSelectNetworkId = uniqueLinks.single.networkId;
        }
      }

      if (selectedNetworkId.value != null) {
        final selectedLink = uniqueLinks.where(
          (link) => link.networkId == selectedNetworkId.value,
        );
        if (selectedLink.isNotEmpty) {
          _selectedNetworkFallback = selectedLink.first;
        }
      }
    } on AppException catch (e) {
      if (requestVersion == _networkOptionsRequestVersion &&
          selectedPosId.value == posId) {
        if (append) {
          networkOptionsLoadMoreErrorMessage.value = e.message;
        } else if (isSearch) {
          networkSearchErrorMessage.value = e.message;
          networkSearchHasNoResults.value = false;
        } else {
          networksErrorMessage.value = e.message;
        }
      }
    } catch (e) {
      if (requestVersion == _networkOptionsRequestVersion &&
          selectedPosId.value == posId) {
        final message = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل مزودي الشبكة المرتبطين بنقطة البيع.',
        );
        if (append) {
          networkOptionsLoadMoreErrorMessage.value = message;
        } else if (isSearch) {
          networkSearchErrorMessage.value = message;
          networkSearchHasNoResults.value = false;
        } else {
          networksErrorMessage.value = message;
        }
      }
    } finally {
      if (requestVersion == _networkOptionsRequestVersion) {
        isLoadingNetworks.value = false;
        isSearchingNetworks.value = false;
        isLoadingMoreNetworks.value = false;
      }
    }

    if (requestVersion == _networkOptionsRequestVersion &&
        selectedPosId.value == posId &&
        autoSelectNetworkId > 0) {
      await selectNetwork(autoSelectNetworkId);
    }
  }

  Future<void> selectNetwork(int networkId) async {
    NetworkPosLinkEntity? nextNetwork;
    for (final link in networkLinks) {
      if (link.networkId == networkId) {
        nextNetwork = link;
        break;
      }
    }
    if (nextNetwork == null || selectedNetworkId.value == networkId) return;

    selectedNetworkId.value = networkId;
    _selectedNetworkFallback = nextNetwork;
    _scopeVersion++;
    _resetDebtState();
    await loadDebtData();
  }

  void _resetDebtState() {
    ++_summaryRequestVersion;
    ++_invoiceRequestVersion;
    summary.value = null;
    outstandingInvoices.clear();
    selectedBucket.value = null;
    nextCursor.value = null;
    summaryErrorMessage.value = null;
    invoicesErrorMessage.value = null;
    isLoading.value = false;
    isLoadingInvoices.value = false;
    isLoadingMore.value = false;
  }

  @override
  Future<void> refresh() async {
    if (!hasSelectedScope) {
      if (posOptions.isEmpty) await initializeScope();
      return;
    }
    await loadDebtData();
  }

  Future<void> loadDebtData() async {
    if (!hasSelectedScope) return;

    final networkId = selectedNetworkId.value!;
    final posId = selectedPosId.value!;
    final scopeVersion = _scopeVersion;
    final invoiceVersionAtStart = _invoiceRequestVersion;
    final requestVersion = ++_summaryRequestVersion;

    isLoading.value = true;
    summaryErrorMessage.value = null;

    try {
      final result = await getDebtSummaryUseCase(
        networkId: networkId,
        posId: posId,
      );
      if (requestVersion != _summaryRequestVersion ||
          scopeVersion != _scopeVersion) {
        return;
      }
      summary.value = result;
    } on AppException catch (e) {
      if (requestVersion == _summaryRequestVersion &&
          scopeVersion == _scopeVersion) {
        summaryErrorMessage.value = e.message;
        CustomSnackbar.show(
          title: 'تعذر تحميل ملخص الذمم',
          message: e.message,
          type: SnackType.error,
        );
      }
    } catch (e) {
      if (requestVersion == _summaryRequestVersion &&
          scopeVersion == _scopeVersion) {
        summaryErrorMessage.value = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل ملخص الذمم. يرجى المحاولة مجدداً.',
        );
      }
    } finally {
      if (requestVersion == _summaryRequestVersion) {
        isLoading.value = false;
      }
    }

    if (scopeVersion == _scopeVersion &&
        invoiceVersionAtStart == _invoiceRequestVersion) {
      await loadInvoices(isRefresh: true);
    }
  }

  Future<void> loadInvoices({bool isRefresh = false}) async {
    if (!hasSelectedScope) return;

    final networkId = selectedNetworkId.value!;
    final posId = selectedPosId.value!;
    final scopeVersion = _scopeVersion;

    if (isRefresh) {
      isLoadingInvoices.value = true;
      isLoadingMore.value = false;
      nextCursor.value = null;
      invoicesErrorMessage.value = null;
    } else {
      if (isLoadingInvoices.value || isLoadingMore.value || !hasMore) {
        return;
      }
      isLoadingMore.value = true;
      invoicesErrorMessage.value = null;
    }

    final requestVersion = ++_invoiceRequestVersion;
    final requestedBucket = selectedBucket.value;
    final requestedCursor = isRefresh ? null : nextCursor.value;

    try {
      final result = await getOutstandingInvoicesUseCase(
        networkId: networkId,
        posId: posId,
        bucket: requestedBucket,
        cursor: requestedCursor,
        perPage: 15,
      );

      if (requestVersion != _invoiceRequestVersion ||
          scopeVersion != _scopeVersion ||
          selectedBucket.value != requestedBucket) {
        return;
      }

      if (isRefresh) {
        outstandingInvoices.assignAll(result.items);
      } else {
        final existingIds = outstandingInvoices
            .map((invoice) => invoice.invoiceId)
            .toSet();
        outstandingInvoices.addAll(
          result.items.where((invoice) => existingIds.add(invoice.invoiceId)),
        );
      }
      nextCursor.value = result.nextCursor;
      invoicesErrorMessage.value = null;
    } on AppException catch (e) {
      if (requestVersion == _invoiceRequestVersion &&
          scopeVersion == _scopeVersion &&
          selectedBucket.value == requestedBucket) {
        invoicesErrorMessage.value = e.message;
        if (isRefresh) {
          CustomSnackbar.show(
            title: 'تعذر تحميل الفواتير المستحقة',
            message: e.message,
            type: SnackType.error,
          );
        }
      }
    } catch (e) {
      if (requestVersion == _invoiceRequestVersion &&
          scopeVersion == _scopeVersion &&
          selectedBucket.value == requestedBucket) {
        invoicesErrorMessage.value = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل الفواتير المستحقة. يرجى المحاولة مجدداً.',
        );
      }
    } finally {
      if (requestVersion == _invoiceRequestVersion) {
        isLoadingInvoices.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> onBucketSelected(String? bucket) async {
    if (selectedBucket.value == bucket || !hasSelectedScope) return;
    selectedBucket.value = bucket;
    outstandingInvoices.clear();
    nextCursor.value = null;
    await loadInvoices(isRefresh: true);
  }

  Future<void> loadMoreInvoices() async {
    await loadInvoices(isRefresh: false);
  }
}
