import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/finance/domain/usecases/debt_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/network_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/domain/usecases/repayment_use_cases.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

class MockFinanceRepository implements FinanceRepository {
  PosWalletEntity? mockPosWallet;
  PaginatedList<PosWalletEntity> mockPosWallets = const PaginatedList(
    items: [],
  );
  PaginatedList<PosWalletLogEntity> mockPosWalletLogs = const PaginatedList(
    items: [],
  );
  DebtSummaryEntity? mockDebtSummary;
  PaginatedList<InvoiceEntity> mockOutstandingInvoices = const PaginatedList(
    items: [],
  );
  PaginatedList<PosRepaymentEntity> mockRepayments = const PaginatedList(
    items: [],
  );
  PosRepaymentEntity? mockRepaymentDetails;
  PosRepaymentEntity? mockCollectedRepayment;
  PaginatedList<NetworkWalletEntity> mockNetworkWallets = const PaginatedList(
    items: [],
  );
  NetworkWalletEntity? mockNetworkWallet;
  PaginatedList<NetworkWalletLogEntity> mockNetworkWalletLogs =
      const PaginatedList(items: []);

  @override
  Future<PaginatedList<PosWalletEntity>> getPosWallets({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  }) async => mockPosWallets;

  @override
  Future<PosWalletEntity> getPosWalletByNetworkAndPos(
    int networkId,
    int posId,
  ) async =>
      mockPosWallet ??
      PosWalletEntity(
        walletId: 1,
        networkId: networkId,
        posId: posId,
        walletBalance: 200000,
        creditLimit: 500000,
      );

  @override
  Future<PaginatedList<PosWalletLogEntity>> getPosWalletLogs(
    int walletId, {
    String? operationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async => mockPosWalletLogs;

  @override
  Future<DebtSummaryEntity> getDebtSummary({
    int? networkId,
    int? posId,
  }) async =>
      mockDebtSummary ??
      const DebtSummaryEntity(
        totalReceivables: 0,
        totalOutstandingInvoices: 0,
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
  }) async => mockOutstandingInvoices;

  @override
  Future<PaginatedList<PosRepaymentEntity>> getRepayments({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async => mockRepayments;

  @override
  Future<PosRepaymentEntity> getRepaymentById(int repaymentId) async =>
      mockRepaymentDetails ??
      PosRepaymentEntity(
        repaymentId: repaymentId,
        posId: 1,
        networkId: 1,
        amount: 1000,
        paymentMethod: 'CASH',
        repaymentDate: '2026-11-07',
      );

  @override
  Future<PosRepaymentEntity> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async =>
      mockCollectedRepayment ??
      PosRepaymentEntity(
        repaymentId: 99,
        posId: posId,
        networkId: networkId,
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
    amount: 1000,
    status: 'REVERSED',
    reversalReason: reversalReason,
  );

  @override
  Future<PaginatedList<NetworkWalletEntity>> getNetworkWallets({
    int? networkId,
    String? search,
    String? cursor,
    int? perPage,
  }) async => mockNetworkWallets;

  @override
  Future<NetworkWalletEntity> getNetworkWalletById(int walletId) async =>
      mockNetworkWallet ??
      NetworkWalletEntity(
        walletId: walletId,
        networkId: 1,
        walletBalance: 500000,
      );

  @override
  Future<PaginatedList<NetworkWalletLogEntity>> getNetworkWalletLogs(
    int walletId, {
    String? operation,
    String? search,
    String? cursor,
    int? perPage,
  }) async => mockNetworkWalletLogs;

  @override
  Future<void> transferFromNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {}
}

void main() {
  group('M8 Finance Use Cases Test Suite', () {
    late MockFinanceRepository repository;

    setUp(() {
      repository = MockFinanceRepository();
    });

    test('GetPosWalUseCase delegates correctly to repository', () async {
      repository.mockPosWallets = const PaginatedList(
        items: [
          PosWalletEntity(
            walletId: 1,
            networkId: 1,
            posId: 1,
            walletBalance: 200000,
            creditLimit: 500000,
            availableOverdraftCapacity: 300000,
          ),
        ],
      );

      final useCase = GetPosWalUseCase(repository);
      final result = await useCase();

      expect(result.items.length, 1);
      expect(result.items.first.walletId, 1);
      expect(result.items.first.walletBalance, 200000);
      expect(result.items.first.creditLimit, 500000);
    });

    test('GetDebtSummaryUseCase delegates correctly to repository', () async {
      repository.mockDebtSummary = const DebtSummaryEntity(
        totalReceivables: 750000,
        totalOutstandingInvoices: 5,
        agingBuckets: {
          '0_30': 300000,
          '31_60': 200000,
          '61_90': 150000,
          'over_90': 100000,
        },
      );

      final useCase = GetDebtSummaryUseCase(repository);
      final result = await useCase(posId: 1);

      expect(result.totalReceivables, 750000);
      expect(result.totalOutstandingInvoices, 5);
      expect(result.agingBuckets['over_90'], 100000);
    });

    test('CollectRepaymentUseCase delegates correctly to repository', () async {
      final useCase = CollectRepaymentUseCase(repository);
      final result = await useCase(
        networkId: 1,
        posId: 2,
        amount: 50000,
        paymentMethod: 'CASH',
        notes: 'دفعة سداد',
      );

      expect(result.repaymentId, 99);
      expect(result.amount, 50000);
      expect(result.paymentMethod, 'CASH');
      expect(result.notes, 'دفعة سداد');
    });

    test('ReverseRepaymentUseCase delegates correctly to repository', () async {
      final useCase = ReverseRepaymentUseCase(repository);
      final result = await useCase(
        repaymentId: 10,
        reversalReason: 'خطأ في التحصيل',
      );

      expect(result.repaymentId, 10);
      expect(result.status, 'REVERSED');
      expect(result.reversalReason, 'خطأ في التحصيل');
    });

    test(
      'GetNetworkWalletsUseCase delegates correctly to repository',
      () async {
        repository.mockNetworkWallets = const PaginatedList(
          items: [
            NetworkWalletEntity(
              walletId: 1,
              networkId: 10,
              walletBalance: 15000000,
            ),
          ],
        );

        final useCase = GetNetworkWalletsUseCase(repository);
        final list = await useCase();

        expect(list.items.length, 1);
        expect(list.items[0].walletBalance, 15000000);
      },
    );
  });
}
