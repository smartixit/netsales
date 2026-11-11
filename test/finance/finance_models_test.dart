import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/data/models/network_wallet_models.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/finance/data/models/pos_wallet_models.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';

void main() {
  group('M8 Finance Models Test Suite', () {
    test('PosWalletModel.fromJson parses server response correctly', () {
      final json = {
        'wallet_id': 10,
        'network_id': 1,
        'pos_id': 2,
        'wallet_uuid': 'w-uuid-10',
        'wallet_balance': 250000.50,
        'credit_limit': 500000.00,
        'available_overdraft_capacity': 250000.00,
        'total_purchasing_power': 500000.50,
        'status': true,
        'accounting_status': 'NORMAL',
        'accounting_status_label': 'طبيعي',
        'is_overdrawn': false,
        'debit_amount': 0.0,
        'credit_amount': 250000.50,
        'network': {'network_name': 'شبكة النور'},
        'pos': {'pos_name': 'نقطة الأمل'},
        'created_at': '2026-11-07T12:00:00Z',
        'updated_at': '2026-11-07T12:00:00Z',
      };

      final model = PosWalletModel.fromJson(json);

      expect(model.walletId, 10);
      expect(model.networkId, 1);
      expect(model.posId, 2);
      expect(model.walletBalance, 250000.50);
      expect(model.creditLimit, 500000.00);
      expect(model.availableOverdraftCapacity, 250000.00);
      expect(model.totalPurchasingPower, 500000.50);
      expect(model.networkName, 'شبكة النور');
      expect(model.posName, 'نقطة الأمل');
    });

    test('PosWalletLogModel.fromJson parses movement entries correctly', () {
      final json = {
        'log_id': 101,
        'wallet_id': 10,
        'log_operation_type': 'DEPOSIT',
        'log_operation_type_label': 'إيداع نقدي',
        'log_amount': 50000.00,
        'log_statement': 'دفعة نقدية في حساب نقطة البيع',
        'log_date': '2026-11-07',
        'created_by': 1,
        'created_by_user': {'full_name': 'محاسب الشبكة'},
        'created_at': '2026-11-07T12:30:00Z',
      };

      final log = PosWalletLogModel.fromJson(json);

      expect(log.logId, 101);
      expect(log.walletId, 10);
      expect(log.logOperationType, 'DEPOSIT');
      expect(log.logOperationTypeLabel, 'إيداع نقدي');
      expect(log.logAmount, 50000.00);
      expect(log.logStatement, 'دفعة نقدية في حساب نقطة البيع');
      expect(log.createdByName, 'محاسب الشبكة');
    });

    test('Wallet ledger operation direction uses the enum, not amount sign', () {
      const networkWithdrawal = NetworkWalletLogEntity(
        logId: 1,
        walletId: 10,
        logOperation: 'WITHDRAW',
        logAmount: 50000,
      );
      const posWithdrawal = PosWalletLogEntity(
        logId: 2,
        walletId: 20,
        logOperationType: 'WITHDRAW',
        logAmount: 50000,
      );
      const unknownOperation = NetworkWalletLogEntity(
        logId: 3,
        walletId: 10,
        logOperation: 'FUTURE_OPERATION',
        logAmount: 50000,
      );

      expect(networkWithdrawal.typedLogOperation, WalletOperationType.withdraw);
      expect(posWithdrawal.typedLogOperationType, WalletOperationType.withdraw);
      expect(unknownOperation.typedLogOperation, WalletOperationType.unknown);
      expect(networkWithdrawal.logAmount, 50000);
      expect(posWithdrawal.logAmount, 50000);
    });

    test('DebtSummaryEntity parses aging summary buckets correctly', () {
      const summary = DebtSummaryEntity(
        totalReceivables: 1250000.00,
        unpaidInvoicesCount: 10,
        partiallyPaidInvoicesCount: 5,
        agingBuckets: {
          '0_30': 500000.00,
          '31_60': 350000.00,
          '61_90': 250000.00,
          'over_90': 150000.00,
        },
      );

      expect(summary.totalReceivables, 1250000.00);
      expect(summary.totalOutstandingInvoices, 15);
      expect(summary.unpaidInvoicesCount, 10);
      expect(summary.partiallyPaidInvoicesCount, 5);
      expect(summary.agingBuckets['0_30'], 500000.00);
      expect(summary.agingBuckets['31_60'], 350000.00);
      expect(summary.agingBuckets['61_90'], 250000.00);
      expect(summary.agingBuckets['over_90'], 150000.00);
    });

    test('PosRepaymentModel.fromJson parses repayment and FIFO allocations correctly', () {
      final json = {
        'repayment_id': 50,
        'repayment_uuid': 'rep-uuid-50',
        'network_id': 1,
        'pos_id': 2,
        'amount': 300000.00,
        'payment_method': 'CASH',
        'reference_number': 'REC-99881',
        'notes': 'تسديد مستحقات فواتير سابقة',
        'status': 'COMPLETED',
        'repayment_date': '2026-11-07',
        'network': {'network_name': 'شبكة النور'},
        'pos': {'pos_name': 'نقطة الأمل'},
        'allocations': [
          {
            'allocation_id': 1,
            'repayment_id': 50,
            'invoice_id': 100,
            'network_id': 1,
            'pos_id': 2,
            'allocated_amount': 200000.00,
            'status': 'COMPLETED',
            'allocated_at': '2026-11-07T14:00:00Z',
            '''invoice''': {
              'invoice_uuid': 'inv-uuid-100',
              'invoice_total_amount': 250000.00,
              'paid_amount': 250000.00,
              'remaining_amount': 0.00,
              'payment_status': 'PAID',
              'payment_status_label': 'مدفوعة بالكامل',
              'invoice_date': '2026-11-07 13:00:00',
              'sale_type': 'CREDIT',
              'sale_type_label': 'آجل',
            },
          },
          {
            'allocation_id': 2,
            'repayment_id': 50,
            'invoice_id': 101,
            'network_id': 1,
            'pos_id': 2,
            'allocated_amount': 100000.00,
            'status': 'COMPLETED',
            'allocated_at': '2026-11-07T14:00:00Z',
            '''invoice''': {
              'invoice_uuid': 'inv-uuid-101',
              'invoice_total_amount': 200000.00,
              'paid_amount': 100000.00,
              'remaining_amount': 100000.00,
              'payment_status': 'PARTIALLY_PAID',
              'payment_status_label': 'مدفوعة جزئياً',
              'invoice_date': '2026-11-06 13:00:00',
              'sale_type': 'CREDIT',
              'sale_type_label': 'آجل',
            },
          },
        ],
      };

      final repayment = PosRepaymentModel.fromJson(json);

      expect(repayment.repaymentId, 50);
      expect(repayment.repaymentUuid, 'rep-uuid-50');
      expect(repayment.amount, 300000.00);
      expect(repayment.paymentMethod, 'CASH');
      expect(repayment.status, 'COMPLETED');
      expect(repayment.isCompleted, isTrue);
      expect(repayment.allocations.length, 2);
      expect(repayment.allocations[0].invoiceId, 100);
      expect(repayment.allocations[0].allocatedAmount, 200000.00);
      expect(repayment.allocations[0].invoice.totalAmount, 250000.00);
      expect(repayment.allocations[0].invoice.paymentStatusLabel, 'مدفوعة بالكامل');
      expect(repayment.allocations[1].invoiceId, 101);
      expect(repayment.allocations[1].allocatedAmount, 100000.00);
      expect(repayment.allocations[1].invoice.remainingAmount, 100000.00);
    });

    test('NetworkWalletModel.fromJson parses network wallet correctly', () {
      final json = {
        'wallet_id': 5,
        'network_id': 1,
        'wallet_uuid': 'nw-uuid-5',
        'wallet_balance': 9800000.00,
        'status': true,
        'network': {'network_name': 'شبكة النور'},
        'created_at': '2026-11-07T15:00:00Z',
      };

      final model = NetworkWalletModel.fromJson(json);

      expect(model.walletId, 5);
      expect(model.networkId, 1);
      expect(model.walletBalance, 9800000.00);
      expect(model.networkName, 'شبكة النور');
    });

    test('NetworkWalletLogModel.fromJson parses network logs correctly', () {
      final json = {
        'log_id': 301,
        'wallet_id': 5,
        'log_operation': 'REPAYMENT_CREDIT',
        'log_operation_label': 'تحصيل سداد دين',
        'log_amount': 300000.00,
        'log_statement': 'تحصيل سند تسديد من نقطة بيع',
        'log_date': '2026-11-07',
        'created_by': 1,
        'created_by_user': {'full_name': 'المسؤول المالي'},
        'created_at': '2026-11-07T15:00:00Z',
      };

      final log = NetworkWalletLogModel.fromJson(json);

      expect(log.logId, 301);
      expect(log.walletId, 5);
      expect(log.logOperation, 'REPAYMENT_CREDIT');
      expect(log.logOperationLabel, 'تحصيل سداد دين');
      expect(log.logAmount, 300000.00);
      expect(log.createdByName, 'المسؤول المالي');
    });
  });
}
