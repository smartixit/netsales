import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_wallet_dashboard_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_collection_controller.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

class MockCommercialRepository implements CommercialRepository {
  List<NetworkEntity> networks = [];
  PaginatedList<NetworkPosLinkEntity> posLinks = const PaginatedList(items: []);
  final List<int> requestedNetworkIds = [];

  @override
  Future<List<NetworkEntity>> getMyNetworks() async => networks;

  @override
  Future<List<PosEntity>> getMyPos() async => [];

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
    return posLinks;
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async => const PaginatedList(items: []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestFinanceRepository implements FinanceRepository {
  PaginatedList<PosWalletEntity> posWallets = const PaginatedList(items: []);
  PaginatedList<PosWalletLogEntity> posLogs = const PaginatedList(items: []);
  DebtSummaryEntity? debtSummary;
  PaginatedList<InvoiceEntity> invoices = const PaginatedList(items: []);
  PaginatedList<PosRepaymentEntity> repayments = const PaginatedList(items: []);
  PaginatedList<NetworkWalletEntity> networkWallets = const PaginatedList(
    items: [],
  );
  PaginatedList<NetworkWalletLogEntity> networkLogs = const PaginatedList(
    items: [],
  );

  @override
  Future<PaginatedList<PosWalletEntity>> getPosWallets({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  }) async => posWallets;

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
  }) async => posLogs;

  @override
  Future<DebtSummaryEntity> getDebtSummary({
    int? networkId,
    int? posId,
  }) async =>
      debtSummary ??
      const DebtSummaryEntity(
        totalReceivables: 0,
        agingBuckets: {},
      );

  @override
  Future<PaginatedList<InvoiceEntity>> getOutstandingInvoices({
    int? networkId,
    int? posId,
    String? bucket,
    String? search,
    String? cursor,
    int? perPage,
  }) async => invoices;

  @override
  Future<PaginatedList<PosRepaymentEntity>> getRepayments({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async => repayments;

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
  }) async => networkWallets;

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
  }) async => networkLogs;

  @override
  Future<void> transferFromNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
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

        final controller = PosDebtLedgerController(
          getDebtSummaryUseCase: GetDebtSummaryUseCase(repository),
          getOutstandingInvoicesUseCase: GetOutstandingInvoicesUseCase(
            repository,
          ),
        );

        await controller.loadDebtData();

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
          ),
          const NetworkEntity(
            networkId: 2,
            ownerId: 1,
            networkName: 'الشبكة الثانية',
            networkPhoneNumber: '777000222',
            status: 'ACTIVE',
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
        expect(controller.selectedPosId.value, 20);
        expect(controller.posList.single.posId, 20);
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

      final controller = RepaymentHistoryController(
        getRepaymentsUseCase: GetRepaymentsUseCase(repository),
        reverseRepaymentUseCase: ReverseRepaymentUseCase(repository),
      );

      await controller.loadRepayments(isRefresh: true);

      expect(controller.isLoading.value, isFalse);
      expect(controller.repayments.length, 1);
      expect(controller.repayments[0].amount, 250000);
    });

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
