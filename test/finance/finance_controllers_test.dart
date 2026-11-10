import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/transfer_pos_to_network_use_case.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_transfer_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_collection_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

class MockCommercialRepository implements CommercialRepository {
  List<NetworkEntity> networks = [];
  List<PosEntity> myPos = [];
  PaginatedList<NetworkPosLinkEntity> posLinks = const PaginatedList(items: []);
  PaginatedList<NetworkPosLinkEntity> posNetworkLinks = const PaginatedList(
    items: [],
  );
  final List<int> requestedPosNetworkIds = [];
  final List<String?> requestedPosNetworkSearchQueries = [];
  final List<String?> requestedPosNetworkCursors = [];
  final List<String?> requestedNetworkPosCursors = [];
  final Map<String, PaginatedList<NetworkPosLinkEntity>> networkPosPages = {};
  final Map<String, PaginatedList<NetworkPosLinkEntity>> posNetworkPages = {};
  final Map<String, PaginatedList<NetworkPosLinkEntity>>
  posNetworkSearchResults = {};
  final Map<String, Completer<PaginatedList<NetworkPosLinkEntity>>>
  pendingPosNetworkSearches = {};
  bool failPosNetworksList = false;
  final List<int> requestedNetworkIds = [];
  final List<int?> requestedPosPageSizes = [];
  final List<bool?> requestedPosStatuses = [];
  final List<String?> requestedPosSearchQueries = [];
  final Map<String, Completer<PaginatedList<NetworkPosLinkEntity>>>
  pendingPosSearches = {};
  bool failNetworkList = false;
  bool failPosList = false;

  @override
  Future<List<NetworkEntity>> getMyNetworks() async {
    if (failNetworkList) throw Exception('Network list request failed');
    return networks;
  }

  @override
  Future<List<PosEntity>> getMyPos() async => myPos;

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList(
    int networkId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    requestedNetworkIds.add(networkId);
    requestedNetworkPosCursors.add(cursor);
    requestedPosPageSizes.add(perPage);
    requestedPosStatuses.add(status);
    requestedPosSearchQueries.add(search);
    if (failPosList) throw Exception('POS list request failed');
    final pending = pendingPosSearches[search ?? ''];
    if (pending != null) return pending.future;
    if (cursor != null) {
      return networkPosPages[cursor] ?? const PaginatedList(items: []);
    }
    final items = status == null
        ? posLinks.items
        : posLinks.items.where((link) => link.status == status).toList();
    return PaginatedList(items: items, nextCursor: posLinks.nextCursor);
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    requestedPosNetworkIds.add(posId);
    requestedPosNetworkSearchQueries.add(search);
    requestedPosNetworkCursors.add(cursor);
    if (failPosNetworksList) {
      throw Exception('POS network list request failed');
    }
    final searchKey = search ?? '';
    final pending = pendingPosNetworkSearches[searchKey];
    if (pending != null) return pending.future;
    if (search != null && search.isNotEmpty) {
      return cursor == null
          ? posNetworkSearchResults[searchKey] ?? const PaginatedList(items: [])
          : posNetworkPages[cursor] ?? const PaginatedList(items: []);
    }
    return cursor == null
        ? posNetworkLinks
        : posNetworkPages[cursor] ?? const PaginatedList(items: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestFinanceRepository implements FinanceRepository {
  PaginatedList<PosWalletEntity> posWallets = const PaginatedList(items: []);
  final Map<String, PaginatedList<PosWalletEntity>> posWalletPages = {};
  final List<String?> requestedPosWalletCursors = [];
  PaginatedList<PosWalletLogEntity> posLogs = const PaginatedList(items: []);
  DebtSummaryEntity? debtSummary;
  PaginatedList<InvoiceEntity> invoices = const PaginatedList(items: []);
  PaginatedList<PosRepaymentEntity> repayments = const PaginatedList(items: []);
  final List<Map<String, int?>> requestedRepaymentScopes = [];
  final List<String?> requestedRepaymentStatuses = [];
  final List<Map<String, int?>> requestedDebtScopes = [];
  final List<Map<String, int?>> requestedInvoiceScopes = [];
  PaginatedList<NetworkWalletEntity> networkWallets = const PaginatedList(
    items: [],
  );
  final Map<String, PaginatedList<NetworkWalletEntity>> networkWalletPages = {};
  final List<String?> requestedNetworkWalletCursors = [];
  final Set<String> failedNetworkWalletPageCursors = {};
  PaginatedList<NetworkWalletLogEntity> networkLogs = const PaginatedList(
    items: [],
  );
  bool failNetworkLogs = false;
  bool failPosLogs = false;
  bool denyNetworkLogs = false;
  bool denyPosLogs = false;
  bool failOutstandingInvoices = false;
  final Map<int, Completer<PaginatedList<NetworkWalletLogEntity>>>
  pendingNetworkLogs = {};
  final Map<int, Completer<PaginatedList<PosWalletLogEntity>>> pendingPosLogs =
      {};
  final Map<String, Completer<PaginatedList<InvoiceEntity>>>
  pendingInvoicePages = {};
  final Map<String?, Completer<PaginatedList<PosRepaymentEntity>>>
  pendingRepaymentPages = {};

  @override
  Future<PaginatedList<PosWalletEntity>> getPosWallets({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedPosWalletCursors.add(cursor);
    return cursor == null
        ? posWallets
        : posWalletPages[cursor] ?? const PaginatedList(items: []);
  }

  @override
  Future<PosWalletEntity> getPosWalletByNetworkAndPos(
    int networkId,
    int posId,
  ) async => posWallets.items.first;

  @override
  Future<PaginatedList<PosWalletLogEntity>> getPosWalletLogs(
    int walletId, {
    String? operationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (denyPosLogs) {
      throw const AppException('غير مصرح لك باستعراض كشف حساب هذه المحفظة.');
    }
    if (failPosLogs) throw Exception('POS wallet log request failed');
    final pending = pendingPosLogs[walletId];
    if (pending != null) return pending.future;
    return posLogs;
  }

  @override
  Future<DebtSummaryEntity> getDebtSummary({int? networkId, int? posId}) async {
    requestedDebtScopes.add({'networkId': networkId, 'posId': posId});
    return debtSummary ??
        const DebtSummaryEntity(totalReceivables: 0, agingBuckets: {});
  }

  @override
  Future<PaginatedList<InvoiceEntity>> getOutstandingInvoices({
    int? networkId,
    int? posId,
    String? bucket,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedInvoiceScopes.add({'networkId': networkId, 'posId': posId});
    if (failOutstandingInvoices) {
      throw Exception('Outstanding invoice request failed');
    }
    final pending = pendingInvoicePages[bucket ?? 'all'];
    if (pending != null) return pending.future;
    return invoices;
  }

  @override
  Future<PaginatedList<PosRepaymentEntity>> getRepayments({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedRepaymentScopes.add({'networkId': networkId, 'posId': posId});
    requestedRepaymentStatuses.add(status);
    final pending = pendingRepaymentPages[status];
    if (pending != null) return pending.future;
    return repayments;
  }

  @override
  Future<PosRepaymentEntity> getRepaymentById(int repaymentId) async =>
      repayments.items.first;

  @override
  Future<PosRepaymentEntity> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  }) async => PosRepaymentEntity(
    repaymentId: 10,
    repaymentUuid: 'rep-10',
    networkId: networkId,
    posId: posId,
    amount: amount,
    paymentMethod: paymentMethod,
    referenceNumber: referenceNumber,
    notes: notes,
    repaymentDate: '2026-11-07',
  );

  @override
  Future<PosRepaymentEntity> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  }) async => PosRepaymentEntity(
    repaymentId: repaymentId,
    networkId: 1,
    posId: 1,
    amount: 500,
    status: 'REVERSED',
    reversalReason: reversalReason,
  );

  @override
  Future<PaginatedList<NetworkWalletEntity>> getNetworkWallets({
    int? networkId,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedNetworkWalletCursors.add(cursor);
    if (cursor != null && failedNetworkWalletPageCursors.contains(cursor)) {
      throw Exception('Network wallet page request failed');
    }
    return cursor == null
        ? networkWallets
        : networkWalletPages[cursor] ?? const PaginatedList(items: []);
  }

  @override
  Future<NetworkWalletEntity> getNetworkWalletById(int walletId) async =>
      networkWallets.items.first;

  @override
  Future<PaginatedList<NetworkWalletLogEntity>> getNetworkWalletLogs(
    int walletId, {
    String? operation,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (denyNetworkLogs) {
      throw const AppException('غير مصرح لك باستعراض كشف حساب هذه المحفظة.');
    }
    if (failNetworkLogs) throw Exception('Network wallet log request failed');
    final pending = pendingNetworkLogs[walletId];
    if (pending != null) return pending.future;
    return networkLogs;
  }

  @override
  Future<void> transferFromNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
    String? idempotencyKey,
  }) async {}

  @override
  Future<void> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
    String? idempotencyKey,
  }) async {}

  @override
  Future<void> updatePosCreditLimit({
    required int posWalletId,
    required double? creditLimit,
  }) async {}

  @override
  Future<void> depositToPosWallet({
    required int posWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) async {}

  @override
  Future<void> withdrawFromPosWallet({
    required int posWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) async {}

  @override
  Future<void> depositToNetworkWallet({
    required int networkWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) async {}

  @override
  Future<void> withdrawFromNetworkWallet({
    required int networkWalletId,
    required double amount,
    required String statement,
    String? logDate,
    String? idempotencyKey,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestFinanceRepository repository;
  late MockCommercialRepository commercialRepository;

  setUp(() {
    Get.testMode = true;
    repository = TestFinanceRepository();
    commercialRepository = MockCommercialRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('M8 Controllers Test Suite', () {
    test(
      'PosWalletDashboardController loads wallets and logs successfully',
      () async {
        repository.posWallets = const PaginatedList(
          items: [
            PosWalletEntity(
              walletId: 1,
              networkId: 1,
              posId: 5,
              walletBalance: 120000,
              creditLimit: 300000,
              availableOverdraftCapacity: 180000,
            ),
          ],
        );
        repository.posLogs = const PaginatedList(
          items: [
            PosWalletLogEntity(
              logId: 1,
              walletId: 1,
              logOperationType: 'DEPOSIT',
              logAmount: 50000,
            ),
          ],
        );

        final controller = PosWalletDashboardController(
          getPosWalUseCase: GetPosWalUseCase(repository),
          getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
        );

        await controller.loadWallets();

        expect(controller.isLoading.value, isFalse);
        expect(controller.wallets.length, 1);
        expect(controller.selectedWallet.value, isNotNull);
        expect(controller.selectedWallet.value!.walletBalance, 120000);
        expect(controller.logs.length, 1);
      },
    );

    test(
      'PosDebtLedgerController loads aging summary and outstanding invoices',
      () async {
        repository.debtSummary = const DebtSummaryEntity(
          totalReceivables: 850000,
          unpaidInvoicesCount: 2,
          partiallyPaidInvoicesCount: 2,
          agingBuckets: {
            '0_30': 400000,
            '31_60': 250000,
            '61_90': 100000,
            'over_90': 100000,
          },
        );
        repository.invoices = const PaginatedList(
          items: [
            InvoiceEntity(
              invoiceId: 1,
              networkId: 1,
              posId: 2,
              invoiceTotalAmount: 1000,
              paidAmount: 200,
              remainingAmount: 800,
              paymentStatusRaw: 'PARTIAL',
              invoiceDate: '2026-11-01',
            ),
          ],
        );

        commercialRepository.myPos = [
          const PosEntity(
            posId: 2,
            ownerId: 1,
            posUuid: 'pos-2',
            posName: 'نقطة البيع الرئيسية',
            posPhoneNumber: '777000111',
          ),
        ];
        commercialRepository.posNetworkLinks = const PaginatedList(
          items: [
            NetworkPosLinkEntity(
              networkPosId: 20,
              networkId: 1,
              posId: 2,
              status: true,
              network: NetworkEntity(
                networkId: 1,
                ownerId: 1,
                networkName: 'شبكة السرعة',
                networkPhoneNumber: '777111222',
                networkUuid: 'NET-123',
              ),
            ),
          ],
        );

        final controller = PosDebtLedgerController(
          getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
          getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
            repository,
          ),
          getMyPosUseCase: GetMyPosUseCase(commercialRepository),
          getPosNetworksListUseCase: GetPosNetworksListUseCase(
            commercialRepository,
          ),
        );

        await controller.initializeScope();

        expect(controller.isLoading.value, isFalse);
        expect(controller.summary.value, isNotNull);
        expect(controller.summary.value!.totalReceivables, 850000);
        expect(controller.summary.value!.unpaidInvoicesCount, 2);
        expect(controller.summary.value!.partiallyPaidInvoicesCount, 2);
        expect(controller.summary.value!.totalOutstandingInvoices, 4);
        expect(controller.outstandingInvoices.length, 1);
        expect(controller.outstandingInvoices[0].remainingAmount, 800);
      },
    );

    test(
      'RepaymentCollectionController initializes networks and pos lists',
      () async {
        commercialRepository.networks = [
          const NetworkEntity(
            networkId: 1,
            ownerId: 1,
            networkName: 'شبكة السرعة',
            networkPhoneNumber: '777000111',
            status: 'ACTIVE',
            networkUuid: 'NET-342',
          ),
        ];
        commercialRepository.posLinks = const PaginatedList(
          items: [
            NetworkPosLinkEntity(
              networkPosId: 1,
              networkId: 1,
              posId: 10,
              status: true,
              createdAt: '2026-11-01',
              pos: PosEntity(
                posId: 10,
                ownerId: 1,
                posUuid: 'pos-uuid-10',
                posName: 'نقطة الأمل',
                posPhoneNumber: '777999888',
                status: 'ACTIVE',
              ),
            ),
            NetworkPosLinkEntity(
              networkPosId: 2,
              networkId: 1,
              posId: 11,
              status: false,
              createdAt: '2026-11-01',
              pos: PosEntity(
                posId: 11,
                ownerId: 1,
                posUuid: 'pos-uuid-11',
                posName: 'نقطة متوقفة',
                posPhoneNumber: '777999887',
                status: 'ACTIVE',
              ),
            ),
          ],
        );

        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );

        await controller.loadInitialData();

        expect(controller.networks.length, 1);
        expect(controller.selectedNetworkId.value, isNull);
        expect(controller.posList, isEmpty);
        expect(controller.selectedPosId.value, isNull);

        // CustomDropdown writes the selected ID before invoking onChanged.
        controller.selectedNetworkId.value = 1;
        await controller.onNetworkChanged(1);

        expect(controller.posList.length, 1);
        expect(controller.posList.single.posId, 10);
        expect(commercialRepository.requestedPosStatuses, [true]);
        expect(controller.selectedPosId.value, isNull);

        // The POS must be chosen deliberately for a financial transaction.
        controller.selectedPosId.value = 10;
        expect(controller.selectedPosId.value, 10);
      },
    );

    test(
      'RepaymentCollectionController reloads POS after dropdown network change',
      () async {
        commercialRepository.networks = [
          const NetworkEntity(
            networkId: 1,
            ownerId: 1,
            networkName: 'الشبكة الأولى',
            networkPhoneNumber: '777000111',
            status: 'ACTIVE',
            networkUuid: 'NET-255',
          ),
          const NetworkEntity(
            networkId: 2,
            ownerId: 1,
            networkName: 'الشبكة الثانية',
            networkPhoneNumber: '777000222',
            status: 'ACTIVE',
            networkUuid: 'NET-784',
          ),
        ];
        commercialRepository.posLinks = const PaginatedList(
          items: [
            NetworkPosLinkEntity(
              networkPosId: 2,
              networkId: 2,
              posId: 20,
              status: true,
              pos: PosEntity(
                posId: 20,
                ownerId: 1,
                posUuid: 'pos-uuid-20',
                posName: 'نقطة الشبكة الثانية',
                posPhoneNumber: '777999000',
                status: 'ACTIVE',
              ),
            ),
          ],
        );

        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );

        await controller.loadInitialData();
        controller.selectedNetworkId.value = 2;
        await controller.onNetworkChanged(2);

        expect(commercialRepository.requestedNetworkIds.last, 2);
        expect(controller.posList.single.posId, 20);

        // The available POS is loaded, but financial collection must not
        // select it automatically. The user must choose the beneficiary.
        expect(controller.selectedPosId.value, isNull);
        controller.selectedPosId.value = 20;
        expect(controller.selectedPosId.value, 20);
      },
    );

    test(
      'Repayment beneficiary cannot change while collection is submitting',
      () async {
        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );
        controller.selectedNetworkId.value = 7;
        controller.selectedPosId.value = 22;
        controller.isSubmitting.value = true;

        await controller.onNetworkChanged(8);
        controller.onPosChanged(33);
        await controller.loadPosForNetwork(7);
        await controller.searchPosForNetwork('different beneficiary');

        expect(controller.selectedNetworkId.value, 7);
        expect(controller.selectedPosId.value, 22);
        expect(commercialRepository.requestedNetworkIds, isEmpty);
        expect(controller.isLoadingPos.value, isFalse);
      },
    );

    test('Repayment beneficiary remote search uses the server and rejects stale results', () async {
      const oldPos = PosEntity(
        posId: 11,
        ownerId: 1,
        posUuid: 'pos-uuid-old',
        posName: 'نقطة قديمة',
        posPhoneNumber: '777111111',
        status: 'ACTIVE',
      );
      const newPos = PosEntity(
        posId: 22,
        ownerId: 1,
        posUuid: 'pos-uuid-new',
        posName: 'نقطة حديثة',
        posPhoneNumber: '777222222',
        status: 'ACTIVE',
      );
      const oldLink = NetworkPosLinkEntity(
        networkPosId: 11,
        networkId: 7,
        posId: 11,
        status: true,
        pos: oldPos,
      );
      const newLink = NetworkPosLinkEntity(
        networkPosId: 22,
        networkId: 7,
        posId: 22,
        status: true,
        pos: newPos,
      );
      final oldRequest = Completer<PaginatedList<NetworkPosLinkEntity>>();
      commercialRepository.pendingPosSearches['old'] = oldRequest;
      commercialRepository.pendingPosSearches['new'] =
          Completer<PaginatedList<NetworkPosLinkEntity>>()
            ..complete(const PaginatedList(items: [newLink]));

      final controller = RepaymentCollectionController(
        collectRepaymentUseCase: CollectRepaymentUseCase(repository),
        getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
        getNetworkPosListUseCase: GetNetworkPosListUseCase(
          commercialRepository,
        ),
      );
      controller.selectedNetworkId.value = 7;

      final oldFuture = controller.searchPosForNetwork('old');
      await controller.searchPosForNetwork('new');
      oldRequest.complete(const PaginatedList(items: [oldLink]));
      await oldFuture;

      expect(controller.posList.map((pos) => pos.posId), [22]);
      expect(commercialRepository.requestedPosSearchQueries, ['old', 'new']);
      expect(commercialRepository.requestedPosPageSizes, [50, 50]);
      expect(controller.isLoadingPos.value, isFalse);
    });

    test(
      'Repayment remote search failure preserves the selected beneficiary',
      () async {
        const selected = PosEntity(
          posId: 22,
          ownerId: 1,
          posUuid: 'pos-uuid-selected',
          posName: 'نقطة البيع المحددة',
          posPhoneNumber: '777222222',
          status: 'ACTIVE',
        );
        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );
        controller.selectedNetworkId.value = 7;
        controller.selectedPosId.value = selected.posId;
        controller.selectedPos.value = selected;
        controller.posList.assignAll([selected]);
        controller.hasLoadedPosList.value = true;
        commercialRepository.failPosList = true;

        await controller.searchPosForNetwork('نتيجة غير متاحة');

        expect(controller.selectedPosId.value, selected.posId);
        expect(controller.selectedPos.value, selected);
        expect(controller.posList, [selected]);
        expect(controller.posErrorMessage.value, isNotNull);
        expect(controller.hasLoadedPosList.value, isTrue);
      },
    );

    test(
      'Repayment collection exposes network list failure for retry',
      () async {
        commercialRepository.failNetworkList = true;
        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );

        await controller.loadInitialData();

        expect(controller.networks, isEmpty);
        expect(controller.initialErrorMessage.value, isNotNull);
        expect(controller.isLoadingInitial.value, isFalse);
      },
    );

    test(
      'Repayment collection exposes linked POS failure instead of empty result',
      () async {
        commercialRepository.failPosList = true;
        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );
        controller.selectedNetworkId.value = 7;

        await controller.loadPosForNetwork(7);

        expect(controller.posList, isEmpty);
        expect(controller.posErrorMessage.value, isNotNull);
        expect(controller.isLoadingPos.value, isFalse);
      },
    );

    test('RepaymentHistoryController loads repayment list', () async {
      repository.repayments = const PaginatedList(
        items: [
          PosRepaymentEntity(
            repaymentId: 1,
            repaymentUuid: 'rep-uuid-1',
            posId: 1,
            networkId: 1,
            amount: 250000,
            paymentMethod: 'CASH',
            repaymentDate: '2026-11-07',
          ),
        ],
      );

      commercialRepository.networks = [
        const NetworkEntity(
          networkId: 1,
          ownerId: 1,
          networkName: 'شبكة الاختبار',
          networkPhoneNumber: '777111222',
          networkUuid: 'NET-126',
        ),
      ];

      final controller = RepaymentHistoryController(
        getRepaymentsUseCase: GetRepaymentsUseCase(repository),
        getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
        reverseRepaymentUseCase: ReverseRepaymentUseCase(repository),
      );

      await controller.initializeNetworks();

      expect(controller.isLoading.value, isFalse);
      expect(controller.repayments.length, 1);
      expect(controller.repayments[0].amount, 250000);
      expect(controller.selectedNetworkId.value, 1);
      expect(repository.requestedRepaymentScopes, [
        {'networkId': 1, 'posId': null},
      ]);
    });

    test('repayment history requires explicit network selection when multiple networks exist', () async {
      commercialRepository.networks = [
        const NetworkEntity(
          networkId: 11,
          ownerId: 1,
          networkName: 'الشبكة الأولى',
          networkPhoneNumber: '777111111',
          networkUuid: 'NET-124',
        ),
        const NetworkEntity(
          networkId: 22,
          ownerId: 1,
          networkName: 'الشبكة الثانية',
          networkPhoneNumber: '777222222',
          networkUuid: 'NET-125',
        ),
      ];
      repository.repayments = const PaginatedList(
        items: [
          PosRepaymentEntity(
            repaymentId: 22,
            repaymentUuid: 'rep-network-22',
            posId: 2,
            networkId: 22,
            amount: 200,
            repaymentDate: '2026-11-08',
          ),
        ],
      );

      final controller = RepaymentHistoryController(
        getRepaymentsUseCase: GetRepaymentsUseCase(repository),
        getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
      );

      await controller.initializeNetworks();

      expect(controller.selectedNetworkId.value, isNull);
      expect(repository.requestedRepaymentScopes, isEmpty);
      expect(controller.repayments, isEmpty);

      await controller.selectNetwork(22);

      expect(controller.selectedNetworkId.value, 22);
      expect(repository.requestedRepaymentScopes, [
        {'networkId': 22, 'posId': null},
      ]);
      expect(controller.repayments.single.networkId, 22);
    });

    test(
      'Repayment status stale response cannot replace latest filter results',
      () async {
        const oldRepayment = PosRepaymentEntity(
          repaymentId: 101,
          repaymentUuid: 'rep-old',
          posId: 1,
          networkId: 1,
          amount: 100,
          repaymentDate: '2026-11-01',
        );
        const newRepayment = PosRepaymentEntity(
          repaymentId: 202,
          repaymentUuid: 'rep-new',
          posId: 1,
          networkId: 1,
          amount: 200,
          repaymentDate: '2026-11-02',
        );
        final oldRequest = Completer<PaginatedList<PosRepaymentEntity>>();
        repository.pendingRepaymentPages['PENDING'] = oldRequest;
        repository.pendingRepaymentPages['COMPLETED'] =
            Completer<PaginatedList<PosRepaymentEntity>>()
              ..complete(const PaginatedList(items: [newRepayment]));

        final controller = RepaymentHistoryController(
          getRepaymentsUseCase: GetRepaymentsUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
        );
        controller.selectedNetworkId.value = 1;
        controller.selectedStatus.value = 'PENDING';
        final oldFuture = controller.loadRepayments(isRefresh: true);
        controller.onStatusChanged('COMPLETED');
        await Future<void>.delayed(Duration.zero);
        oldRequest.complete(const PaginatedList(items: [oldRepayment]));
        await oldFuture;

        expect(controller.selectedStatus.value, 'COMPLETED');
        expect(repository.requestedRepaymentScopes, [
          {'networkId': 1, 'posId': null},
          {'networkId': 1, 'posId': null},
        ]);
        expect(repository.requestedRepaymentStatuses, ['PENDING', 'COMPLETED']);
        expect(controller.repayments.map((item) => item.repaymentId), [202]);
        expect(controller.isLoading.value, isFalse);
      },
    );

    test(
      'POS wallet log failure is exposed separately from an empty ledger',
      () async {
        repository.posWallets = const PaginatedList(
          items: [
            PosWalletEntity(
              walletId: 1,
              networkId: 1,
              posId: 5,
              walletBalance: 120000,
            ),
          ],
        );
        repository.failPosLogs = true;

        final controller = PosWalletDashboardController(
          getPosWalUseCase: GetPosWalUseCase(repository),
          getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
        );

        await controller.loadWallets();

        expect(controller.wallets, hasLength(1));
        expect(controller.logs, isEmpty);
        expect(controller.logsErrorMessage.value, isNotNull);
        expect(controller.isLoadingLogs.value, isFalse);
      },
    );

    test(
      'Network wallet log failure is exposed separately from an empty ledger',
      () async {
        repository.networkWallets = const PaginatedList(
          items: [
            NetworkWalletEntity(
              walletId: 1,
              networkId: 1,
              walletBalance: 8400000,
            ),
          ],
        );
        repository.failNetworkLogs = true;

        final controller = NetworkWalletDashboardController(
          getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
          getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
        );

        await controller.loadWallets();

        expect(controller.wallets, hasLength(1));
        expect(controller.logs, isEmpty);
        expect(controller.logsErrorMessage.value, isNotNull);
        expect(controller.isLoadingLogs.value, isFalse);
      },
    );

    test(
      'network wallet transfer can page through all linked POS beneficiaries',
      () async {
        const firstPos = PosEntity(
          posId: 81,
          ownerId: 1,
          posUuid: 'pos-81',
          posName: 'نقطة البيع الأولى',
          posPhoneNumber: '777000081',
        );
        const secondPos = PosEntity(
          posId: 82,
          ownerId: 1,
          posUuid: 'pos-82',
          posName: 'نقطة البيع الثانية',
          posPhoneNumber: '777000082',
        );
        commercialRepository.posLinks = const PaginatedList(
          items: [
            NetworkPosLinkEntity(
              networkPosId: 8001,
              networkId: 8,
              posId: 81,
              status: true,
              pos: firstPos,
            ),
          ],
          nextCursor: 'transfer-pos-page-2',
        );
        commercialRepository.networkPosPages['transfer-pos-page-2'] =
            const PaginatedList(
              items: [
                NetworkPosLinkEntity(
                  networkPosId: 8002,
                  networkId: 8,
                  posId: 82,
                  status: true,
                  pos: secondPos,
                ),
              ],
            );

        final controller = NetworkWalletTransferController(
          transferFromNetworkToPosUseCase: TransferFromNetworkToPosUseCase(
            repository,
          ),
          transferPosToNetworkUseCase: TransferPosToNetworkUseCase(
            repository,
          ),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );

        await controller.initialize(
          const NetworkWalletEntity(
            walletId: 8,
            networkId: 8,
            walletBalance: 50000,
          ),
        );
        expect(controller.posList.map((pos) => pos.posId), [81]);
        expect(controller.hasMorePos, isTrue);

        await controller.loadMorePos();

        expect(controller.posList.map((pos) => pos.posId), [81, 82]);
        expect(controller.hasMorePos, isFalse);
      },
    );

    test(
      'repayment collection can page through all POS beneficiaries',
      () async {
        const firstPos = PosEntity(
          posId: 71,
          ownerId: 1,
          posUuid: 'pos-71',
          posName: 'نقطة البيع الأولى',
          posPhoneNumber: '777000071',
        );
        const secondPos = PosEntity(
          posId: 72,
          ownerId: 1,
          posUuid: 'pos-72',
          posName: 'نقطة البيع الثانية',
          posPhoneNumber: '777000072',
        );
        commercialRepository.posLinks = const PaginatedList(
          items: [
            NetworkPosLinkEntity(
              networkPosId: 7001,
              networkId: 7,
              posId: 71,
              status: true,
              pos: firstPos,
            ),
          ],
          nextCursor: 'network-pos-page-2',
        );
        commercialRepository.networkPosPages['network-pos-page-2'] =
            const PaginatedList(
              items: [
                NetworkPosLinkEntity(
                  networkPosId: 7002,
                  networkId: 7,
                  posId: 72,
                  status: true,
                  pos: secondPos,
                ),
              ],
            );

        final controller = RepaymentCollectionController(
          collectRepaymentUseCase: CollectRepaymentUseCase(repository),
          getMyNetworksUseCase: GetMyNetworksUseCase(commercialRepository),
          getNetworkPosListUseCase: GetNetworkPosListUseCase(
            commercialRepository,
          ),
        );
        controller.selectedNetworkId.value = 7;

        await controller.loadPosForNetwork(7);
        expect(controller.posList.map((pos) => pos.posId), [71]);
        expect(controller.hasMorePosOptions, isTrue);

        await controller.loadMorePosForNetwork();

        expect(controller.posList.map((pos) => pos.posId), [71, 72]);
        expect(controller.hasMorePosOptions, isFalse);
        expect(commercialRepository.requestedNetworkPosCursors, [
          null,
          'network-pos-page-2',
        ]);
      },
    );

    test('network wallet refresh preserves a selected wallet outside the first page', () async {
      const firstWallet = NetworkWalletEntity(
        walletId: 31,
        networkId: 301,
        walletBalance: 1000,
      );
      const selectedWallet = NetworkWalletEntity(
        walletId: 32,
        networkId: 302,
        walletBalance: 2000,
      );
      repository.networkWallets = const PaginatedList(
        items: [firstWallet],
        nextCursor: 'wallet-refresh-page-2',
      );
      repository.networkWalletPages['wallet-refresh-page-2'] =
          const PaginatedList(items: [selectedWallet]);

      final controller = NetworkWalletDashboardController(
        getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
        getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
      );

      await controller.loadWallets();
      await controller.loadMoreWallets();
      await controller.selectWallet(selectedWallet);

      repository.networkWallets = const PaginatedList(
        items: [firstWallet],
        nextCursor: 'wallet-refresh-page-2',
      );
      await controller.loadWallets();

      expect(controller.selectedWallet.value?.walletId, 32);
      expect(controller.wallets.map((wallet) => wallet.walletId), [32, 31]);
    });

    test('network wallet selection is cleared when the ledger confirms access was revoked', () async {
      const wallet = NetworkWalletEntity(
        walletId: 41,
        networkId: 401,
        walletBalance: 1000,
      );
      repository.networkWallets = const PaginatedList(items: [wallet]);
      repository.denyNetworkLogs = true;

      final controller = NetworkWalletDashboardController(
        getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
        getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
      );

      await controller.loadWallets();

      expect(controller.selectedWallet.value, isNull);
      expect(controller.wallets, isEmpty);
      expect(controller.walletsErrorMessage.value, isNotNull);
    });

    test(
      'POS wallet refresh preserves a selected wallet outside the first page',
      () async {
        const firstWallet = PosWalletEntity(
          walletId: 51,
          networkId: 501,
          posId: 5,
          walletBalance: 1000,
        );
        const selectedWallet = PosWalletEntity(
          walletId: 52,
          networkId: 502,
          posId: 6,
          walletBalance: 2000,
        );
        repository.posWallets = const PaginatedList(
          items: [firstWallet],
          nextCursor: 'pos-wallet-refresh-page-2',
        );
        repository.posWalletPages['pos-wallet-refresh-page-2'] =
            const PaginatedList(items: [selectedWallet]);

        final controller = PosWalletDashboardController(
          getPosWalUseCase: GetPosWalUseCase(repository),
          getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
        );

        await controller.loadWallets();
        await controller.loadMoreWallets();
        await controller.selectWallet(selectedWallet);

        repository.posWallets = const PaginatedList(
          items: [firstWallet],
          nextCursor: 'pos-wallet-refresh-page-2',
        );
        await controller.loadWallets();

        expect(controller.selectedWallet.value?.walletId, 52);
        expect(controller.wallets.map((wallet) => wallet.walletId), [52, 51]);
      },
    );

    test('POS wallet selection is cleared when the ledger confirms access was revoked', () async {
      const wallet = PosWalletEntity(
        walletId: 61,
        networkId: 601,
        posId: 6,
        walletBalance: 1000,
      );
      repository.posWallets = const PaginatedList(items: [wallet]);
      repository.denyPosLogs = true;

      final controller = PosWalletDashboardController(
        getPosWalUseCase: GetPosWalUseCase(repository),
        getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
      );

      await controller.loadWallets();

      expect(controller.selectedWallet.value, isNull);
      expect(controller.wallets, isEmpty);
      expect(controller.walletsErrorMessage.value, isNotNull);
    });

    test(
      'POS debt scope selector can load every cursor page of network links',
      () async {
        const firstNetwork = NetworkPosLinkEntity(
          networkPosId: 1001,
          networkId: 101,
          posId: 5,
          status: true,
          network: NetworkEntity(
            networkId: 101,
            ownerId: 1,
            networkName: 'الشبكة الأولى',
            networkPhoneNumber: '777111101',
            networkUuid: 'NET-127',
          ),
        );
        const secondNetwork = NetworkPosLinkEntity(
          networkPosId: 2002,
          networkId: 202,
          posId: 5,
          status: true,
          network: NetworkEntity(
            networkId: 202,
            ownerId: 1,
            networkName: 'الشبكة الثانية',
            networkPhoneNumber: '777111202',
            networkUuid: 'NET-128',
          ),
        );
        commercialRepository.myPos = [
          const PosEntity(
            posId: 5,
            ownerId: 1,
            posUuid: 'pos-5',
            posName: 'نقطة البيع',
            posPhoneNumber: '777000555',
          ),
        ];
        commercialRepository.posNetworkLinks = const PaginatedList(
          items: [firstNetwork],
          nextCursor: 'network-links-page-2',
        );
        commercialRepository.posNetworkPages['network-links-page-2'] =
            const PaginatedList(items: [secondNetwork]);

        final controller = PosDebtLedgerController(
          getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
          getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
            repository,
          ),
          getMyPosUseCase: GetMyPosUseCase(commercialRepository),
          getPosNetworksListUseCase: GetPosNetworksListUseCase(
            commercialRepository,
          ),
        );

        await controller.initializeScope();
        expect(controller.networkLinks.map((link) => link.networkId), [101]);
        expect(controller.hasMoreNetworkOptions, isTrue);
        expect(controller.selectedNetworkId.value, isNull);

        await controller.loadMoreNetworkOptions();

        expect(controller.networkLinks.map((link) => link.networkId), [
          101,
          202,
        ]);
        expect(controller.hasMoreNetworkOptions, isFalse);
        expect(commercialRepository.requestedPosNetworkCursors, [
          null,
          'network-links-page-2',
        ]);

        await controller.selectNetwork(202);
        expect(controller.selectedNetworkId.value, 202);
        expect(repository.requestedDebtScopes, [
          {'networkId': 202, 'posId': 5},
        ]);
      },
    );

    test('Outstanding invoice failure is not represented as no debt', () async {
      repository.debtSummary = const DebtSummaryEntity(
        totalReceivables: 850000,
        unpaidInvoicesCount: 2,
        partiallyPaidInvoicesCount: 2,
        agingBuckets: {'0_30': 850000},
      );
      repository.failOutstandingInvoices = true;
      commercialRepository.myPos = [
        const PosEntity(
          posId: 2,
          ownerId: 1,
          posUuid: 'pos-2',
          posName: 'نقطة البيع الرئيسية',
          posPhoneNumber: '777000111',
        ),
      ];
      commercialRepository.posNetworkLinks = const PaginatedList(
        items: [
          NetworkPosLinkEntity(
            networkPosId: 20,
            networkId: 1,
            posId: 2,
            status: true,
            network: NetworkEntity(
              networkId: 1,
              ownerId: 1,
              networkName: 'شبكة السرعة',
              networkPhoneNumber: '777111222',
              networkUuid: 'NET-121',
            ),
          ),
        ],
      );

      final controller = PosDebtLedgerController(
        getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
        getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
          repository,
        ),
        getMyPosUseCase: GetMyPosUseCase(commercialRepository),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          commercialRepository,
        ),
      );

      await controller.initializeScope();

      expect(controller.summary.value, isNotNull);
      expect(controller.outstandingInvoices, isEmpty);
      expect(controller.invoicesErrorMessage.value, isNotNull);
      expect(controller.isLoadingInvoices.value, isFalse);
    });

    test('POS debt summary and invoices remain blocked until the network scope is explicit', () async {
      const pos = PosEntity(
        posId: 5,
        ownerId: 1,
        posUuid: 'pos-5',
        posName: 'نقطة بيع متعددة الشبكات',
        posPhoneNumber: '777000555',
      );
      const firstLink = NetworkPosLinkEntity(
        networkPosId: 51,
        networkId: 11,
        posId: 5,
        status: true,
        network: NetworkEntity(
          networkId: 11,
          ownerId: 1,
          networkName: 'الشبكة الأولى',
          networkPhoneNumber: '777111111',
          networkUuid: 'NET-122',
        ),
      );
      const secondLink = NetworkPosLinkEntity(
        networkPosId: 52,
        networkId: 22,
        posId: 5,
        status: false,
        network: NetworkEntity(
          networkId: 22,
          ownerId: 2,
          networkName: 'الشبكة الثانية',
          networkPhoneNumber: '777222222',
          networkUuid: 'NET-224',
        ),
      );
      commercialRepository.myPos = [pos];
      commercialRepository.posNetworkLinks = const PaginatedList(
        items: [firstLink, secondLink],
      );

      final controller = PosDebtLedgerController(
        getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
        getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
          repository,
        ),
        getMyPosUseCase: GetMyPosUseCase(commercialRepository),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          commercialRepository,
        ),
      );

      await controller.initializeScope();

      expect(controller.selectedPosId.value, 5);
      expect(controller.selectedNetworkId.value, isNull);
      expect(repository.requestedDebtScopes, isEmpty);
      expect(repository.requestedInvoiceScopes, isEmpty);
      expect(commercialRepository.requestedPosNetworkIds, [5]);

      await controller.selectNetwork(22);

      expect(repository.requestedDebtScopes, [
        {'networkId': 22, 'posId': 5},
      ]);
      expect(repository.requestedInvoiceScopes, [
        {'networkId': 22, 'posId': 5},
      ]);
    });

    test('multiple POS memberships require explicit POS selection before loading debt', () async {
      commercialRepository.myPos = [
        const PosEntity(
          posId: 1,
          ownerId: 1,
          posUuid: 'pos-1',
          posName: 'نقطة البيع الأولى',
          posPhoneNumber: '777000001',
        ),
        const PosEntity(
          posId: 2,
          ownerId: 1,
          posUuid: 'pos-2',
          posName: 'نقطة البيع الثانية',
          posPhoneNumber: '777000002',
        ),
      ];
      commercialRepository.posNetworkLinks = const PaginatedList(
        items: [
          NetworkPosLinkEntity(
            networkPosId: 201,
            networkId: 20,
            posId: 2,
            status: true,
            network: NetworkEntity(
              networkId: 20,
              ownerId: 1,
              networkName: 'شبكة النقطة الثانية',
              networkPhoneNumber: '777222000',
              networkUuid: 'NET-222',
            ),
          ),
        ],
      );

      final controller = PosDebtLedgerController(
        getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
        getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
          repository,
        ),
        getMyPosUseCase: GetMyPosUseCase(commercialRepository),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          commercialRepository,
        ),
      );

      await controller.initializeScope();

      expect(controller.selectedPosId.value, isNull);
      expect(commercialRepository.requestedPosNetworkIds, isEmpty);
      expect(repository.requestedDebtScopes, isEmpty);

      await controller.selectPos(2);

      expect(controller.selectedPosId.value, 2);
      expect(controller.selectedNetworkId.value, 20);
      expect(repository.requestedDebtScopes.single, {
        'networkId': 20,
        'posId': 2,
      });
      expect(repository.requestedInvoiceScopes.single, {
        'networkId': 20,
        'posId': 2,
      });
    });

    test('remote network search preserves selected supplier and records the server query', () async {
      const pos = PosEntity(
        posId: 8,
        ownerId: 1,
        posUuid: 'pos-8',
        posName: 'نقطة البحث',
        posPhoneNumber: '777000008',
      );
      const firstLink = NetworkPosLinkEntity(
        networkPosId: 81,
        networkId: 81,
        posId: 8,
        status: true,
        network: NetworkEntity(
          networkId: 81,
          ownerId: 1,
          networkName: 'شبكة ألف',
          networkPhoneNumber: '777888111',
          networkUuid: 'NET-223',
        ),
      );
      const secondLink = NetworkPosLinkEntity(
        networkPosId: 82,
        networkId: 82,
        posId: 8,
        status: true,
        network: NetworkEntity(
          networkId: 82,
          ownerId: 2,
          networkName: 'شبكة باء',
          networkPhoneNumber: '777888222',
          networkUuid: 'NET-224',
        ),
      );
      commercialRepository.myPos = [pos];
      commercialRepository.posNetworkLinks = const PaginatedList(
        items: [firstLink, secondLink],
      );
      commercialRepository.posNetworkSearchResults['شبكة باء'] =
          const PaginatedList(items: [secondLink]);

      final controller = PosDebtLedgerController(
        getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
        getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
          repository,
        ),
        getMyPosUseCase: GetMyPosUseCase(commercialRepository),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          commercialRepository,
        ),
      );

      await controller.initializeScope();
      await controller.selectNetwork(81);
      await controller.searchNetworks('شبكة باء');

      expect(commercialRepository.requestedPosNetworkSearchQueries, [
        null,
        'شبكة باء',
      ]);
      expect(controller.networkLinks.map((link) => link.networkId), [82]);
      expect(controller.selectedNetworkId.value, 81);
      expect(controller.selectedNetwork?.networkId, 81);
      expect(repository.requestedDebtScopes, [
        {'networkId': 81, 'posId': 8},
      ]);
    });

    test('empty remote network search preserves the selected scope without showing no-link state', () async {
      const pos = PosEntity(
        posId: 9,
        ownerId: 1,
        posUuid: 'pos-9',
        posName: 'نقطة البحث الفارغ',
        posPhoneNumber: '777000009',
      );
      const selectedLink = NetworkPosLinkEntity(
        networkPosId: 91,
        networkId: 91,
        posId: 9,
        status: true,
        network: NetworkEntity(
          networkId: 91,
          ownerId: 1,
          networkName: 'مزود مختار',
          networkPhoneNumber: '777999111',
          networkUuid: 'NET-225',
        ),
      );
      const anotherLink = NetworkPosLinkEntity(
        networkPosId: 92,
        networkId: 92,
        posId: 9,
        status: true,
        network: NetworkEntity(
          networkId: 92,
          ownerId: 2,
          networkName: 'مزود آخر',
          networkPhoneNumber: '777999222',
        ),
      );

      commercialRepository.myPos = [pos];
      commercialRepository.posNetworkLinks = const PaginatedList(
        items: [selectedLink, anotherLink],
      );

      final controller = PosDebtLedgerController(
        getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
        getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
          repository,
        ),
        getMyPosUseCase: GetMyPosUseCase(commercialRepository),
        getPosNetworksListUseCase: GetPosNetworksListUseCase(
          commercialRepository,
        ),
      );

      await controller.initializeScope();
      await controller.selectNetwork(91);
      final debtRequestCount = repository.requestedDebtScopes.length;

      await controller.searchNetworks('لا يوجد بهذا الاسم');

      expect(controller.selectedNetworkId.value, 91);
      expect(controller.selectedNetwork?.networkId, 91);
      expect(controller.networkSearchHasNoResults.value, isTrue);
      expect(controller.networkLinks.map((link) => link.networkId), [91, 92]);
      expect(controller.hasSelectedScope, isTrue);
      expect(repository.requestedDebtScopes, hasLength(debtRequestCount));
    });

    test('Network wallet selection appends cursor pages and deduplicates wallet IDs', () async {
      const firstWallet = NetworkWalletEntity(
        walletId: 1,
        networkId: 101,
        walletBalance: 1000,
        networkName: 'الشبكة الأولى',
      );
      const secondWallet = NetworkWalletEntity(
        walletId: 2,
        networkId: 202,
        walletBalance: 2000,
        networkName: 'الشبكة الثانية',
      );
      repository.networkWallets = const PaginatedList(
        items: [firstWallet],
        nextCursor: 'network-wallet-page-2',
      );
      repository.networkWalletPages['network-wallet-page-2'] =
          const PaginatedList(items: [firstWallet, secondWallet]);

      final controller = NetworkWalletDashboardController(
        getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
        getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
      );

      await controller.loadWallets();
      await controller.loadMoreWallets();

      expect(controller.wallets.map((wallet) => wallet.walletId), [1, 2]);
      expect(controller.selectedWallet.value?.walletId, 1);
      expect(repository.requestedNetworkWalletCursors, [
        null,
        'network-wallet-page-2',
      ]);
      expect(controller.hasMoreWallets, isFalse);
      expect(controller.isLoadingMoreWallets.value, isFalse);
    });

    test(
      'POS wallet selection appends cursor pages and preserves selected wallet',
      () async {
        const firstWallet = PosWalletEntity(
          walletId: 11,
          networkId: 101,
          posId: 5,
          walletBalance: 3000,
          networkName: 'الشبكة الأولى',
        );
        const secondWallet = PosWalletEntity(
          walletId: 22,
          networkId: 202,
          posId: 5,
          walletBalance: 4000,
          networkName: 'الشبكة الثانية',
        );
        repository.posWallets = const PaginatedList(
          items: [firstWallet],
          nextCursor: 'pos-wallet-page-2',
        );
        repository.posWalletPages['pos-wallet-page-2'] = const PaginatedList(
          items: [firstWallet, secondWallet],
        );

        final controller = PosWalletDashboardController(
          getPosWalUseCase: GetPosWalUseCase(repository),
          getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
        );

        await controller.loadWallets();
        await controller.loadMoreWallets();

        expect(controller.wallets.map((wallet) => wallet.walletId), [11, 22]);
        expect(controller.selectedWallet.value?.walletId, 11);
        expect(repository.requestedPosWalletCursors, [
          null,
          'pos-wallet-page-2',
        ]);
        expect(controller.hasMoreWallets, isFalse);
        expect(controller.isLoadingMoreWallets.value, isFalse);
      },
    );

    test(
      'Network wallet page failure preserves already loaded wallet options',
      () async {
        const wallet = NetworkWalletEntity(
          walletId: 101,
          networkId: 10,
          walletBalance: 100,
        );
        repository.networkWallets = const PaginatedList(
          items: [wallet],
          nextCursor: 'missing-page',
        );
        repository.failedNetworkWalletPageCursors.add('missing-page');

        final controller = NetworkWalletDashboardController(
          getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
          getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
        );

        await controller.loadWallets();
        await controller.loadMoreWallets();

        expect(controller.wallets.map((item) => item.walletId), [101]);
        expect(controller.walletsLoadMoreErrorMessage.value, isNotNull);
        expect(controller.hasMoreWallets, isTrue);
        expect(controller.isLoadingMoreWallets.value, isFalse);
      },
    );

    test('Network wallet stale response cannot replace newly selected wallet ledger', () async {
      const walletA = NetworkWalletEntity(
        walletId: 1,
        networkId: 1,
        walletBalance: 1000,
      );
      const walletB = NetworkWalletEntity(
        walletId: 2,
        networkId: 1,
        walletBalance: 2000,
      );
      const oldLog = NetworkWalletLogEntity(
        logId: 101,
        walletId: 1,
        logOperation: 'DEPOSIT',
        logAmount: 100,
      );
      const newLog = NetworkWalletLogEntity(
        logId: 202,
        walletId: 2,
        logOperation: 'DEPOSIT',
        logAmount: 200,
      );
      final oldRequest = Completer<PaginatedList<NetworkWalletLogEntity>>();
      repository.pendingNetworkLogs[1] = oldRequest;
      repository.pendingNetworkLogs[2] =
          Completer<PaginatedList<NetworkWalletLogEntity>>()
            ..complete(const PaginatedList(items: [newLog]));

      final controller = NetworkWalletDashboardController(
        getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
        getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
      );
      controller.selectedWallet.value = walletA;
      final oldFuture = controller.loadWalletLogs(1, isRefresh: true);

      await controller.selectWallet(walletB);
      oldRequest.complete(const PaginatedList(items: [oldLog]));
      await oldFuture;

      expect(controller.selectedWallet.value?.walletId, 2);
      expect(controller.logs.map((item) => item.logId), [202]);
      expect(controller.isLoadingLogs.value, isFalse);
    });

    test(
      'POS wallet stale response cannot replace newly selected wallet ledger',
      () async {
        const walletA = PosWalletEntity(
          walletId: 1,
          networkId: 1,
          posId: 1,
          walletBalance: 1000,
        );
        const walletB = PosWalletEntity(
          walletId: 2,
          networkId: 1,
          posId: 2,
          walletBalance: 2000,
        );
        const oldLog = PosWalletLogEntity(
          logId: 101,
          walletId: 1,
          logOperationType: 'DEPOSIT',
          logAmount: 100,
        );
        const newLog = PosWalletLogEntity(
          logId: 202,
          walletId: 2,
          logOperationType: 'DEPOSIT',
          logAmount: 200,
        );
        final oldRequest = Completer<PaginatedList<PosWalletLogEntity>>();
        repository.pendingPosLogs[1] = oldRequest;
        repository.pendingPosLogs[2] =
            Completer<PaginatedList<PosWalletLogEntity>>()
              ..complete(const PaginatedList(items: [newLog]));

        final controller = PosWalletDashboardController(
          getPosWalUseCase: GetPosWalUseCase(repository),
          getPosWalletLogsUseCase: GetPosWalletLogsUseCase(repository),
        );
        controller.selectedWallet.value = walletA;
        final oldFuture = controller.loadWalletLogs(1, isRefresh: true);

        await controller.selectWallet(walletB);
        oldRequest.complete(const PaginatedList(items: [oldLog]));
        await oldFuture;

        expect(controller.selectedWallet.value?.walletId, 2);
        expect(controller.logs.map((item) => item.logId), [202]);
        expect(controller.isLoadingLogs.value, isFalse);
      },
    );

    test(
      'Debt bucket stale response cannot replace latest bucket invoices',
      () async {
        const oldInvoice = InvoiceEntity(
          invoiceId: 101,
          networkId: 1,
          posId: 1,
          invoiceTotalAmount: 1000,
          paidAmount: 0,
          remainingAmount: 1000,
          paymentStatusRaw: 'UNPAID',
          invoiceDate: '2026-11-01',
        );
        const newInvoice = InvoiceEntity(
          invoiceId: 202,
          networkId: 1,
          posId: 1,
          invoiceTotalAmount: 2000,
          paidAmount: 0,
          remainingAmount: 2000,
          paymentStatusRaw: 'UNPAID',
          invoiceDate: '2026-11-02',
        );
        final oldRequest = Completer<PaginatedList<InvoiceEntity>>();
        repository.pendingInvoicePages['0_30'] = oldRequest;
        repository.pendingInvoicePages['31_60'] =
            Completer<PaginatedList<InvoiceEntity>>()
              ..complete(const PaginatedList(items: [newInvoice]));

        final controller = PosDebtLedgerController(
          getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
          getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
            repository,
          ),
          getMyPosUseCase: GetMyPosUseCase(commercialRepository),
          getPosNetworksListUseCase: GetPosNetworksListUseCase(
            commercialRepository,
          ),
        );
        controller.selectedBucket.value = '0_30';
        controller.selectedPosId.value = 1;
        controller.selectedNetworkId.value = 1;
        final oldFuture = controller.loadInvoices(isRefresh: true);
        await controller.onBucketSelected('31_60');
        oldRequest.complete(const PaginatedList(items: [oldInvoice]));
        await oldFuture;

        expect(controller.selectedBucket.value, '31_60');
        expect(controller.outstandingInvoices.map((item) => item.invoiceId), [
          202,
        ]);
        expect(controller.isLoadingInvoices.value, isFalse);
      },
    );

    test(
      'NetworkWalletDashboardController loads network wallet balances',
      () async {
        repository.networkWallets = const PaginatedList(
          items: [
            NetworkWalletEntity(
              walletId: 1,
              networkId: 1,
              walletBalance: 8400000,
            ),
          ],
        );

        final controller = NetworkWalletDashboardController(
          getNetworkWalletsUseCase: GetNetworkWalletsUseCase(repository),
          getNetworkWalletLogsUseCase: GetNetworkWalletLogsUseCase(repository),
        );

        await controller.loadWallets();

        expect(controller.isLoading.value, isFalse);
        expect(controller.wallets.length, 1);
        expect(controller.wallets[0].walletBalance, 8400000);
      },
    );
  });
}
