import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/accounting_status.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_model.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';
import 'package:netsales/features/wallet/domain/usecases/get_pos_wallet_by_network_and_pos_use_case.dart';
import 'package:netsales/features/wallet/domain/usecases/get_pos_wallet_logs_use_case.dart';

class MockPosWalletRepository implements PosWalletRepository {
  PosWalletEntity? stubbedWallet;
  PaginatedList<PosWalletLogEntity>? stubbedLogs;
  WalletOperationType? capturedOperationType;

  @override
  Future<PosWalletEntity> getWalletByNetworkAndPos({
    required int networkId,
    required int posId,
  }) async {
    return stubbedWallet!;
  }

  @override
  Future<PosWalletEntity> getWalletById(int walletId) async {
    return stubbedWallet!;
  }

  @override
  Future<PaginatedList<PosWalletLogEntity>> getWalletLogs({
    required int walletId,
    WalletOperationType? operationType,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    capturedOperationType = operationType;
    return stubbedLogs!;
  }

  @override
  Future<PosWalletEntity> transferFromNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {
    return stubbedWallet!;
  }

  @override
  Future<PosWalletEntity> deposit({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) async {
    return stubbedWallet!;
  }

  @override
  Future<PosWalletEntity> withdraw({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) async {
    return stubbedWallet!;
  }

  @override
  Future<PosWalletEntity> updateCreditLimit({
    required int walletId,
    required double? creditLimit,
  }) async {
    return stubbedWallet!;
  }
}

void main() {
  group('POS Wallet Unified Enum & Parity Tests', () {
    test('AccountingStatus wire mapping & PresentationRegistry resolution', () {
      expect(
        AccountingStatus.fromWire('CREDIT'),
        equals(AccountingStatus.credit),
      );
      expect(
        AccountingStatus.fromWire('DEBIT'),
        equals(AccountingStatus.debit),
      );
      expect(AccountingStatus.fromWire('ZERO'), equals(AccountingStatus.zero));
      expect(
        AccountingStatus.fromWire('UNKNOWN'),
        equals(AccountingStatus.unknown),
      );
      expect(AccountingStatus.fromWire(null), equals(AccountingStatus.unknown));

      final creditPres = EnumPresentationRegistry.resolveAccountingStatus(
        AccountingStatus.credit,
      );
      expect(creditPres.tone, equals(SemanticTone.success));
      expect(creditPres.label, equals('دائن (له رصيد متاح)'));

      final debitPres = EnumPresentationRegistry.resolveAccountingStatus(
        AccountingStatus.debit,
      );
      expect(debitPres.tone, equals(SemanticTone.warning));
      expect(debitPres.label, equals('مدين (عليه مديونية للشبكة)'));
    });

    test(
      'WalletOperationType wire mapping & PresentationRegistry resolution',
      () {
        expect(
          WalletOperationType.fromWire('DEPOSIT'),
          equals(WalletOperationType.deposit),
        );
        expect(
          WalletOperationType.fromWire('WITHDRAW'),
          equals(WalletOperationType.withdraw),
        );
        expect(
          WalletOperationType.fromWire('OTHER'),
          equals(WalletOperationType.unknown),
        );

        final depositPres = EnumPresentationRegistry.resolveWalletOperationType(
          WalletOperationType.deposit,
        );
        expect(depositPres.tone, equals(SemanticTone.success));
        expect(depositPres.label, equals('إيداع'));

        final withdrawPres =
            EnumPresentationRegistry.resolveWalletOperationType(
              WalletOperationType.withdraw,
            );
        expect(withdrawPres.tone, equals(SemanticTone.danger));
        expect(withdrawPres.label, equals('سحب'));
      },
    );

    test('PosWalletEntity typed getters map to authoritative enums', () {
      const wallet = PosWalletEntity(
        walletId: 1,
        networkId: 10,
        posId: 20,
        walletUuid: 'WAL-123',
        walletBalance: 50000.0,
        openingBalance: 0.0,
        currencyCode: 'YER',
        availableOverdraftCapacity: 10000.0,
        totalPurchasingPower: 60000.0,
        status: true,
        accountingStatus: 'CREDIT',
        accountingStatusLabel: 'رصيد دائن متاح',
        isOverdrawn: false,
        debitAmount: 0.0,
        creditAmount: 50000.0,
      );

      expect(wallet.typedAccountingStatus, equals(AccountingStatus.credit));
      expect(wallet.isCredit, isTrue);
      expect(wallet.isDebit, isFalse);
      expect(EnumPresentationRegistry.resolveAccountingStatus(wallet.typedAccountingStatus, serverLabel: wallet.accountingStatusLabel).label, equals('رصيد دائن متاح'));
      expect(EnumPresentationRegistry.resolveAccountingStatus(wallet.typedAccountingStatus, serverLabel: wallet.accountingStatusLabel).tone, equals(SemanticTone.success));
    });

    test('PosWalletLogEntity typed getters map to authoritative enums', () {
      const log = PosWalletLogEntity(
        logId: 101,
        walletId: 1,
        operationTypeRaw: 'DEPOSIT',
        operationTypeLabel: 'إيداع نقدي',
        amount: 25000.0,
        balanceBefore: 0.0,
        balanceAfter: 25000.0,
        balanceSnapshotSource: 'LIVE',
        currencyCode: 'YER',
        statement: 'تغذية رصيد الحساب',
      );

      expect(log.typedOperationType, equals(WalletOperationType.deposit));
      expect(log.isDeposit, isTrue);
      expect(log.isWithdraw, isFalse);
      expect(EnumPresentationRegistry.resolveWalletOperationType(log.typedOperationType, serverLabel: log.operationTypeLabel).label, equals('إيداع نقدي'));
      expect(EnumPresentationRegistry.resolveWalletOperationType(log.typedOperationType, serverLabel: log.operationTypeLabel).tone, equals(SemanticTone.success));
    });

    test('PosWalletModel fromJson and toJson round-trip', () {
      final json = {
        'id': 1,
        'network_id': 10,
        'pos_id': 20,
        'wallet_uuid': 'WAL-UUID-1',
        'wallet_balance': '50000.00',
        'opening_balance': '0.00',
        'opening_balance_source': 'LIVE',
        'currency_code': 'YER',
        'credit_limit': '20000.00',
        'available_overdraft_capacity': '20000.00',
        'total_purchasing_power': '70000.00',
        'status': true,
        'accounting_status': 'CREDIT',
        'accounting_status_label': 'رصيد دائن',
        'is_overdrawn': false,
        'debit_amount': '0.00',
        'credit_amount': '50000.00',
        'network': {'id': 10, 'network_name': 'شبكة الأمانة'},
        'pos': {'id': 20, 'pos_name': 'نقطة الأمل'},
      };

      final model = PosWalletModel.fromJson(json);
      expect(model.walletId, equals(1));
      expect(model.networkId, equals(10));
      expect(model.posId, equals(20));
      expect(model.walletBalance, equals(50000.0));
      expect(model.creditLimit, equals(20000.0));
      expect(model.networkName, equals('شبكة الأمانة'));
      expect(model.posName, equals('نقطة الأمل'));
      expect(model.typedAccountingStatus, equals(AccountingStatus.credit));

      final serialized = model.toJson();
      expect(serialized['id'], equals(1));
      expect(serialized['currency_code'], equals('YER'));
      expect(serialized['accounting_status'], equals('CREDIT'));
    });

    test('PosWalletLogModel fromJson and toJson round-trip', () {
      final json = {
        'id': 55,
        'wallet_id': 1,
        'log_operation_type': 'WITHDRAW',
        'log_operation_type_label': 'سحب مالي',
        'amount': '15000.00',
        'balance_before': '50000.00',
        'balance_after': '35000.00',
        'balance_snapshot_source': 'LIVE',
        'currency_code': 'YER',
        'statement': 'سداد فاتورة مشتريات',
        'log_date': '2026-11-22',
        'created_by': 7,
        'created_by_name': 'المسؤول المالي',
        'created_at': '2026-11-22 10:00:00',
      };

      final model = PosWalletLogModel.fromJson(json);
      expect(model.logId, equals(55));
      expect(model.walletId, equals(1));
      expect(model.amount, equals(15000.0));
      expect(model.typedOperationType, equals(WalletOperationType.withdraw));
      expect(model.isWithdraw, isTrue);

      final serialized = model.toJson();
      expect(serialized['id'], equals(55));
      expect(serialized['log_operation_type'], equals('WITHDRAW'));
    });

    test('UseCases delegate with strongly typed enums', () async {
      final mockRepo = MockPosWalletRepository();
      const testWallet = PosWalletEntity(
        walletId: 1,
        networkId: 10,
        posId: 20,
        walletUuid: 'WAL-1',
        walletBalance: 1000.0,
        openingBalance: 0.0,
        currencyCode: 'YER',
        availableOverdraftCapacity: 0.0,
        totalPurchasingPower: 1000.0,
        status: true,
        isOverdrawn: false,
        debitAmount: 0.0,
        creditAmount: 1000.0,
      );
      mockRepo.stubbedWallet = testWallet;
      mockRepo.stubbedLogs = const PaginatedList<PosWalletLogEntity>(items: []);

      final getWalletUseCase = GetPosWalletByNetworkAndPosUseCase(mockRepo);
      final wallet = await getWalletUseCase(networkId: 10, posId: 20);
      expect(wallet.walletId, equals(1));

      final getLogsUseCase = GetPosWalletLogsUseCase(mockRepo);
      await getLogsUseCase(
        walletId: 1,
        operationType: WalletOperationType.deposit,
      );
      expect(
        mockRepo.capturedOperationType,
        equals(WalletOperationType.deposit),
      );
    });
  });
}
