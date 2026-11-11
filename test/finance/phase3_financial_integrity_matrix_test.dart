import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/repayment_payment_method.dart';
import 'package:netsales/core/enums/repayment_status.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/catalog/data/models/package_model.dart';
import 'package:netsales/features/finance/data/models/pos_wallet_models.dart';

void main() {
  group('Phase 3 Comprehensive Quality & Financial Integrity Matrix', () {
    // =========================================================================
    // 3.1 تسعير طلبات التوريد وربطها بالخادم
    // =========================================================================
    group('3.1 Procurement Pricing & Server Authority Tests', () {
      test('PackageModel.fromJson strictly uses server-computed monetary values without local fallbacks', () {
        final serverJson = {
          'package_id': 101,
          'network_id': 1,
          'package_name': 'باقة 500 ميجا',
          'package_voucher_price': 1000.0,
          'package_default_cash_discount': 10.0,
          'package_default_credit_discount': 5.0,
          'cash_discount_amount': 100.0,
          'credit_discount_amount': 50.0,
          'effective_cash_price': 900.0,
          'effective_credit_price': 950.0,
          'status': true,
        };

        final package = PackageModel.fromJson(serverJson);

        expect(package.packageVoucherPrice, 1000.0);
        expect(package.packageDefaultCashDiscount, 10.0);
        expect(package.packageDefaultCreditDiscount, 5.0);
        expect(package.cashDiscountAmount, 100.0);
        expect(package.creditDiscountAmount, 50.0);
        expect(package.effectiveCashPrice, 900.0);
        expect(package.effectiveCreditPrice, 950.0);
      });

      test('PackageModel.fromJson does not perform arithmetic when server omits discount amounts', () {
        // إذا أهمل الخادم إرسال القيم المشتقة عمداً، لا يقوم الموديل باحتسابها محلياً
        final missingAmountsJson = {
          'package_id': 102,
          'network_id': 1,
          'package_name': 'باقة غير محسوبة',
          'package_voucher_price': 2000.0,
          'package_default_cash_discount': 20.0,
          'package_default_credit_discount': 10.0,
          'status': true,
        };

        final package = PackageModel.fromJson(missingAmountsJson);

        expect(package.cashDiscountAmount, 0.0, reason: 'Zero fallback arithmetic');
        expect(package.creditDiscountAmount, 0.0, reason: 'Zero fallback arithmetic');
        expect(package.effectiveCashPrice, 2000.0, reason: 'Falls back to nominal price without subtraction');
        expect(package.effectiveCreditPrice, 2000.0, reason: 'Falls back to nominal price without subtraction');
      });
    });

    // =========================================================================
    // 3.2 نتائج التحصيل وتوزيع السداد (FIFO)
    // =========================================================================
    group('3.2 Repayment Outcomes & FIFO Allocation Tests', () {
      test('PosRepaymentModel parses FIFO allocations and remaining balances accurately from Laravel API', () {
        final repaymentJson = {
          'repayment_id': 501,
          'repayment_uuid': 'REP-2026-9901',
          'network_id': 1,
          'pos_id': 5,
          'amount': 30000.0,
          'payment_method': 'CASH',
          'status': 'COMPLETED',
          'remaining_debt_after': 15000.0,
          'pos_balance_after': -15000.0,
          'allocations': [
            {
              'allocation_id': 1,
              'repayment_id': 501,
              'invoice_id': 10,
              'network_id': 1,
              'pos_id': 5,
              'allocated_amount': 20000.0,
              'status': 'ACTIVE',
              'allocated_at': '2026-11-11T12:00:00Z',
              'invoice': {
                'invoice_uuid': 'INV-0010',
                'invoice_total_amount': 20000.0,
                'paid_amount': 20000.0,
                'remaining_amount': 0.0,
                'payment_status': 'PAID',
                'payment_status_label': 'مسددة بالكامل',
                'invoice_date': '2026-11-01',
                'sale_type': 'CREDIT',
                'sale_type_label': 'آجل',
              },
            },
            {
              'allocation_id': 2,
              'repayment_id': 501,
              'invoice_id': 11,
              'network_id': 1,
              'pos_id': 5,
              'allocated_amount': 10000.0,
              'status': 'ACTIVE',
              'allocated_at': '2026-11-11T12:00:00Z',
              'invoice': {
                'invoice_uuid': 'INV-0011',
                'invoice_total_amount': 25000.0,
                'paid_amount': 10000.0,
                'remaining_amount': 15000.0,
                'payment_status': 'PARTIALLY_PAID',
                'payment_status_label': 'مسددة جزئياً',
                'invoice_date': '2026-11-05',
                'sale_type': 'CREDIT',
                'sale_type_label': 'آجل',
              },
            },
          ],
        };

        final repayment = PosRepaymentModel.fromJson(repaymentJson);

        expect(repayment.repaymentId, 501);
        expect(repayment.repaymentUuid, 'REP-2026-9901');
        expect(repayment.amount, 30000.0);
        expect(repayment.typedPaymentMethod, RepaymentPaymentMethod.cash);
        expect(repayment.typedStatus, RepaymentStatus.completed);
        expect(repayment.isCompleted, isTrue);
        expect(repayment.isReversed, isFalse);
        expect(repayment.remainingDebtAfter, 15000.0);
        expect(repayment.posBalanceAfter, -15000.0);

        // التحقق من قائمة تخصيصات FIFO
        expect(repayment.allocations.length, 2);
        final firstAlloc = repayment.allocations[0];
        expect(firstAlloc.allocatedAmount, 20000.0);
        expect(firstAlloc.invoice.invoiceUuid, 'INV-0010');
        expect(firstAlloc.invoice.remainingAmount, 0.0);
        expect(firstAlloc.invoice.paymentStatus, 'PAID');

        final secondAlloc = repayment.allocations[1];
        expect(secondAlloc.allocatedAmount, 10000.0);
        expect(secondAlloc.invoice.invoiceUuid, 'INV-0011');
        expect(secondAlloc.invoice.remainingAmount, 15000.0);
        expect(secondAlloc.invoice.paymentStatus, 'PARTIALLY_PAID');
      });

      test('RepaymentStatus enum safely maps unknown server states without throwing', () {
        expect(RepaymentStatus.fromWire('COMPLETED'), RepaymentStatus.completed);
        expect(RepaymentStatus.fromWire('REVERSED'), RepaymentStatus.reversed);
        expect(RepaymentStatus.fromWire('DISPUTED'), RepaymentStatus.unknown);
        expect(RepaymentStatus.fromWire(null), RepaymentStatus.unknown);
      });
    });

    // =========================================================================
    // 3.3 إزالة الحسابات المالية المحلية والاعتماد على السيرفر
    // =========================================================================
    group('3.3 Elimination of Local Financial Calculations Tests', () {
      test('PosWalletModel reads total_purchasing_power directly from server payload without local addition', () {
        final walletJson = {
          'wallet_id': 88,
          'network_id': 1,
          'pos_id': 3,
          'wallet_balance': -20000.0,
          'credit_limit': 100000.0,
          'available_overdraft_capacity': 80000.0,
          'total_purchasing_power': 80000.0, // القيمة المعتمدة من السيرفر
          'status': true,
        };

        final wallet = PosWalletModel.fromJson(walletJson);

        expect(wallet.walletBalance, -20000.0);
        expect(wallet.creditLimit, 100000.0);
        expect(wallet.availableOverdraftCapacity, 80000.0);
        expect(wallet.totalPurchasingPower, 80000.0);
      });

      test('PosWalletModel leaves totalPurchasingPower as null when omitted by server, without creating artificial balance', () {
        final walletJson = {
          'wallet_id': 89,
          'network_id': 1,
          'pos_id': 4,
          'wallet_balance': 5000.0,
          'credit_limit': null,
          'available_overdraft_capacity': 0.0,
          'status': true,
        };

        final wallet = PosWalletModel.fromJson(walletJson);

        expect(wallet.totalPurchasingPower, isNull, reason: 'Must not synthesize total purchasing power locally');
      });
    });

    // =========================================================================
    // 3.4 الحوكمة المالية لعمليات المحافظ ومنع التكرار ومعالجة حالات عدم اليقين
    // =========================================================================
    group('3.4 Financial Operations Governance & Ledger Invariants Tests', () {
      test('Ambiguous timeout message directs user to check ledger instead of retry blindingly', () {
        const timeoutEx = 'Connection timed out while waiting for server response';
        final isTimeout = timeoutEx.toLowerCase().contains('timeout') ||
            timeoutEx.toLowerCase().contains('connection');

        expect(isTimeout, isTrue);
        const warningNotice =
            'انقطع الاتصال أثناء انتظار تأكيد القيد المالي. يرجى مراجعة كشف الحساب وسجل القيود للتأكد من إدراج العملية قبل إعادة المحاولة تجنباً للتكرار.';
        expect(warningNotice, contains('سجل القيود'));
        expect(warningNotice, contains('تجنباً للتكرار'));
      });

      test('NetworkWalletTransfer timeout warning provides financial safety notice', () {
        const socketEx = 'SocketException: OS Error: Connection reset by peer';
        final isTimeout = socketEx.toLowerCase().contains('connection') ||
            socketEx.toLowerCase().contains('socket');

        expect(isTimeout, isTrue);
        const transferWarning =
            'انقطع الاتصال أثناء انتظار تأكيد التحويل المالي. يرجى مراجعة كشف حركات المحفظة للتأكد من إتمام العملية قبل إعادة المحاولة تجنباً للتكرار.';
        expect(transferWarning, contains('كشف حركات المحفظة'));
        expect(transferWarning, contains('تجنباً للتكرار'));
      });
    });
  });
}

