import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_log_model.dart';
import 'package:netsales/features/wallet/data/models/network_wallet_model.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/entities/wallet_log_entry.dart';
import 'package:netsales/features/wallet/domain/repositories/network_wallet_repository.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_logs_use_case.dart';
import 'package:netsales/features/wallet/domain/usecases/get_network_wallet_use_case.dart';

class MockNetworkWalletRepository implements NetworkWalletRepository {
  NetworkWalletEntity? stubbedWallet;
  PaginatedList<NetworkWalletLogEntity>? stubbedLogs;
  WalletOperationType? capturedOperationType;

  @override
  Future<NetworkWalletEntity> getWalletByNetworkId(int networkId) async {
    return stubbedWallet!;
  }

  @override
  Future<NetworkWalletEntity> getWalletById(int walletId) async {
    return stubbedWallet!;
  }

  @override
  Future<PaginatedList<NetworkWalletLogEntity>> getWalletLogs({
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
}

void main() {
  group('Network Wallet Domain, Parity & Contract Tests', () {
    test('NetworkWalletLogEntity implements WalletLogEntry cleanly', () {
      const log = NetworkWalletLogEntity(
        logId: 301,
        walletId: 5,
        operationTypeRaw: 'DEPOSIT',
        operationTypeLabel: 'تحصيل فاتورة مبيعات كروت',
        amount: 80000.0,
        balanceBefore: 200000.0,
        balanceAfter: 280000.0,
        balanceSnapshotSource: 'LIVE',
        currencyCode: 'YER',
        statement: 'سداد نقدي لفاتورة توريد كروت INV-2026-0042',
      );

      expect(log, isA<WalletLogEntry>());
      expect(log.typedOperationType, equals(WalletOperationType.deposit));
      expect(log.isDeposit, isTrue);
      expect(log.isWithdraw, isFalse);
      expect(EnumPresentationRegistry.resolveWalletOperationType(log.typedOperationType, serverLabel: log.operationTypeLabel).tone, equals(SemanticTone.success));
      expect(
        EnumPresentationRegistry.resolveWalletOperationType(log.typedOperationType, serverLabel: log.operationTypeLabel).label,
        equals('تحصيل فاتورة مبيعات كروت'),
      );
    });

    test('NetworkWalletLogEntity handles WITHDRAW operation correctly', () {
      const log = NetworkWalletLogEntity(
        logId: 302,
        walletId: 5,
        operationTypeRaw: 'WITHDRAW',
        operationTypeLabel: 'تغذية رصيد نقطة بيع',
        amount: 30000.0,
        balanceBefore: 280000.0,
        balanceAfter: 250000.0,
        balanceSnapshotSource: 'LIVE',
        currencyCode: 'YER',
        statement: 'تحويل وتغذية رصيد لنقطة الأمل TRF-2026-0019',
      );

      expect(log.typedOperationType, equals(WalletOperationType.withdraw));
      expect(log.isWithdraw, isTrue);
      expect(log.isDeposit, isFalse);
      expect(log.operationPresentation.tone, equals(SemanticTone.danger));
      expect(log.operationPresentation.label, equals('تغذية رصيد نقطة بيع'));
    });

    test('NetworkWalletModel fromJson and toJson round-trip', () {
      final json = {
        'id': 5,
        'wallet_id': 5,
        'network_id': 12,
        'wallet_uuid': 'NET-WAL-0012',
        'wallet_balance': '4500000.00',
        'opening_balance': '1000000.00',
        'opening_balance_source': 'LIVE',
        'currency_code': 'YER',
        'status': true,
        'created_at': '2026-11-20 12:00:00',
        'updated_at': '2026-11-22 15:00:00',
        'network': {'id': 12, 'network_name': 'شبكة المستقبل الذكية'},
      };

      final model = NetworkWalletModel.fromJson(json);
      expect(model.walletId, equals(5));
      expect(model.networkId, equals(12));
      expect(model.walletBalance, equals(4500000.0));
      expect(model.openingBalance, equals(1000000.0));
      expect(model.networkName, equals('شبكة المستقبل الذكية'));
      expect(model.currencyCode, equals('YER'));
      expect(model.status, isTrue);

      final serialized = model.toJson();
      expect(serialized['wallet_id'], equals(5));
      expect(serialized['network_id'], equals(12));
      expect(serialized['currency_code'], equals('YER'));
    });

    test('NetworkWalletLogModel fromJson and toJson round-trip', () {
      final json = {
        'id': 88,
        'wallet_id': 5,
        'log_operation': 'DEPOSIT',
        'log_operation_label': 'تحصيل نقدي معتمد',
        'log_amount': '120000.00',
        'balance_before': '4500000.00',
        'balance_after': '4620000.00',
        'balance_snapshot_source': 'LIVE',
        'currency_code': 'YER',
        'log_statement': 'تحصيل مبيعات نقدية معتمدة',
        'log_date': '2026-11-22',
        'created_by': 3,
        'created_by_user': {'user_id': 3, 'name': 'المحاسب المالي'},
      };

      final model = NetworkWalletLogModel.fromJson(json);
      expect(model.logId, equals(88));
      expect(model.walletId, equals(5));
      expect(model.amount, equals(120000.0));
      expect(model.balanceBefore, equals(4500000.0));
      expect(model.balanceAfter, equals(4620000.0));
      expect(model.typedOperationType, equals(WalletOperationType.deposit));
      expect(model.createdByName, equals('المحاسب المالي'));

      final serialized = model.toJson();
      expect(serialized['wallet_id'], equals(5));
      expect(serialized['log_operation'], equals('DEPOSIT'));
    });

    test('Network Wallet UseCases delegate properly', () async {
      final mockRepo = MockNetworkWalletRepository();
      const testWallet = NetworkWalletEntity(
        walletId: 5,
        networkId: 12,
        walletUuid: 'NET-WAL-0012',
        walletBalance: 3000000.0,
        openingBalance: 0.0,
        currencyCode: 'YER',
        status: true,
      );
      mockRepo.stubbedWallet = testWallet;
      mockRepo.stubbedLogs = const PaginatedList<NetworkWalletLogEntity>(
        items: [],
      );

      final getWalletUseCase = GetNetworkWalletUseCase(mockRepo);
      final wallet = await getWalletUseCase(12);
      expect(wallet.walletId, equals(5));
      expect(wallet.walletBalance, equals(3000000.0));

      final getLogsUseCase = GetNetworkWalletLogsUseCase(mockRepo);
      await getLogsUseCase(
        walletId: 5,
        operationType: WalletOperationType.withdraw,
      );
      expect(
        mockRepo.capturedOperationType,
        equals(WalletOperationType.withdraw),
      );
    });
  });
}
