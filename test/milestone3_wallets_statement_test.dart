import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/routing/screen_registry.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_log_model.dart';
import 'package:netsales/features/wallets/data/models/network_wallet_model.dart';

void main() {
  group('Milestone 3 - Canonical Screen Registry & Scope Verification', () {
    test('NET-04 is canonically registered as implemented Network Wallet Statement', () {
      final screen = ScreenRegistry.findById('NET-04');
      expect(screen, isNotNull);
      expect(screen!.titleEn, equals('Network Wallet Statement'));
      expect(screen.route, equals('/network-wallets'));
      expect(screen.implementationState, equals(ScreenImplementationState.implemented));
      expect(screen.isReadOnlyVerified, isTrue);
      expect(screen.isBalanceMutation, isFalse);
    });

    test('POS-04 is canonically registered as implemented POS Wallet Statement', () {
      final screen = ScreenRegistry.findById('POS-04');
      expect(screen, isNotNull);
      expect(screen!.titleEn, equals('POS Wallet Statement'));
      expect(screen.route, equals('/pos-wallets'));
      expect(screen.implementationState, equals(ScreenImplementationState.implemented));
      expect(screen.isReadOnlyVerified, isTrue);
      expect(screen.isBalanceMutation, isFalse);
    });
  });

  group('Milestone 3 - Network Wallet & Log Serialization Tests', () {
    test('NetworkWalletModel parses authoritative server balance and details', () {
      final json = <String, dynamic>{
        'wallet_id': 10,
        'network_id': 2,
        'wallet_uuid': 'NET-WALL-2026-001',
        'wallet_balance': 750000.50,
        'status': true,
        'network': {
          'network_id': 2,
          'network_name': 'شبكة الريان المركزية',
        },
        'created_at': '2026-11-01 10:00:00',
        'updated_at': '2026-11-01 14:30:00',
      };

      final model = NetworkWalletModel.fromJson(json);
      expect(model.walletId, equals(10));
      expect(model.networkId, equals(2));
      expect(model.walletUuid, equals('NET-WALL-2026-001'));
      expect(model.walletBalance, equals(750000.50));
      expect(model.isActive, isTrue);
      expect(model.networkName, equals('شبكة الريان المركزية'));
      expect(model.createdAt, isNotNull);
    });

    test('NetworkWalletLogModel categorizes credit vs debit operations accurately', () {
      final depositJson = <String, dynamic>{
        'log_id': 101,
        'wallet_id': 10,
        'log_operation': 'DEPOSIT',
        'log_operation_label': 'إيداع نقدي',
        'log_amount': 200000.0,
        'log_statement': 'تغذية رصيد عبر الحساب المصرفي',
        'created_at': '2026-11-01 11:00:00',
      };

      final depositModel = NetworkWalletLogModel.fromJson(depositJson);
      expect(depositModel.logId, equals(101));
      expect(depositModel.isCredit, isTrue);
      expect(depositModel.isDebit, isFalse);
      expect(depositModel.logAmount, equals(200000.0));

      final withdrawJson = <String, dynamic>{
        'log_id': 102,
        'wallet_id': 10,
        'log_operation': 'EXPENSE',
        'log_operation_label': 'سند مصروفات',
        'log_amount': 15000.0,
        'log_statement': 'صيانة أبراج التغطية',
        'created_at': '2026-11-01 12:30:00',
      };

      final withdrawModel = NetworkWalletLogModel.fromJson(withdrawJson);
      expect(withdrawModel.logId, equals(102));
      expect(withdrawModel.isCredit, isFalse);
      expect(withdrawModel.isDebit, isTrue);
      expect(withdrawModel.logAmount, equals(15000.0));
    });
  });

  group('Milestone 3 - POS Current Account & Bilateral Isolation Tests', () {
    test('PosWalletModel reflects positive balance as available prepaid credit without debt', () {
      final json = <String, dynamic>{
        'wallet_id': 50,
        'network_id': 2,
        'pos_id': 8,
        'wallet_uuid': 'POS-WALL-2-8',
        'wallet_balance': 45000.0,
        'status': true,
        'accounting_status': 'CREDIT',
        'accounting_status_label': 'رصيد دائن',
        'is_overdrawn': false,
        'debit_amount': 0.0,
        'credit_amount': 45000.0,
        'network': {'network_name': 'شبكة الريان'},
        'pos': {'pos_name': 'نقطة الأمانة'},
      };

      final model = PosWalletModel.fromJson(json);
      expect(model.walletId, equals(50));
      expect(model.walletBalance, equals(45000.0));
      expect(model.isOverdrawn, isFalse);
      expect(model.debitAmount, equals(0.0));
      expect(model.creditAmount, equals(45000.0));
      expect(model.accountingStatus, equals('CREDIT'));
      expect(model.networkName, equals('شبكة الريان'));
      expect(model.posName, equals('نقطة الأمانة'));
    });

    test('PosWalletModel reflects negative balance as authoritative debt without local invoice math', () {
      final json = <String, dynamic>{
        'wallet_id': 51,
        'network_id': 2,
        'pos_id': 9,
        'wallet_uuid': 'POS-WALL-2-9',
        'wallet_balance': -85000.0,
        'status': true,
        'accounting_status': 'DEBIT',
        'accounting_status_label': 'مدين',
        'is_overdrawn': true,
        'debit_amount': 85000.0,
        'credit_amount': 0.0,
        'network': {'network_name': 'شبكة الريان'},
        'pos': {'pos_name': 'نقطة البركة'},
      };

      final model = PosWalletModel.fromJson(json);
      expect(model.walletId, equals(51));
      expect(model.walletBalance, equals(-85000.0));
      expect(model.isOverdrawn, isTrue);
      expect(model.debitAmount, equals(85000.0));
      expect(model.isDebtor, isTrue);
      // Absolute magnitude of negative balance is the authoritative debt
      expect(model.walletBalance.abs(), equals(85000.0));
    });

    test('PosWalletLogModel parses ledger movement correctly', () {
      final json = <String, dynamic>{
        'log_id': 205,
        'wallet_id': 51,
        'log_operation_type': 'INVOICE_PAYMENT',
        'log_operation_type_label': 'شراء كروت جملة',
        'log_amount': 50000.0,
        'log_statement': 'فاتورة مبيعات #1004',
        'created_at': '2026-11-01 13:00:00',
      };

      final log = PosWalletLogModel.fromJson(json);
      expect(log.logId, equals(205));
      expect(log.walletId, equals(51));
      expect(log.logAmount, equals(50000.0));
      expect(log.logOperationType, equals('INVOICE_PAYMENT'));
      expect(log.logOperationTypeLabel, equals('شراء كروت جملة'));
      expect(log.logStatement, equals('فاتورة مبيعات #1004'));
    });
  });
}

