import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_workspace_dashboard_mapper.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

void main() {
  group('PosWorkspaceDashboardMapper', () {
    final now = DateTime(2026, 11, 22, 14, 0);

    test('maps daily procurement, wallet balance, and active orders', () {
      final invoices = [
        InvoiceEntity(
          invoiceId: 1,
          networkId: 10,
          posId: 20,
          invoiceUuid: 'INV-001',
          invoiceTotalAmount: 5000.0,
          invoiceDate: '2026-11-22T10:00:00Z',
        ),
        InvoiceEntity(
          invoiceId: 2,
          networkId: 10,
          posId: 20,
          invoiceUuid: 'INV-002',
          invoiceTotalAmount: 3000.0,
          invoiceDate: '2026-11-21T12:00:00Z',
        ),
      ];

      final requests = <RequestEntity>[
        RequestEntity(
          requestId: 101,
          networkId: 10,
          posId: 20,
          requestTotalAmount: 2000.0,
          requestUuid: 'REQ-001',
          statusRaw: RequestStatus.pending.wireValue,
        ),
        RequestEntity(
          requestId: 102,
          networkId: 10,
          posId: 20,
          requestTotalAmount: 3000.0,
          requestUuid: 'REQ-002',
          statusRaw: RequestStatus.approved.wireValue,
        ),
        RequestEntity(
          requestId: 103,
          networkId: 10,
          posId: 20,
          requestTotalAmount: 1500.0,
          requestUuid: 'REQ-003',
          statusRaw: RequestStatus.rejected.wireValue,
        ),
      ];

      const wallet = PosWalletEntity(
        walletId: 1,
        networkId: 10,
        posId: 20,
        walletUuid: 'W-001',
        walletBalance: 12500.0,
        openingBalance: 0.0,
        currencyCode: 'YER',
        creditLimit: 50000.0,
        availableOverdraftCapacity: 50000.0,
        totalPurchasingPower: 62500.0,
        status: true,
        accountingStatus: 'CREDIT',
        accountingStatusLabel: 'دائن',
        isOverdrawn: false,
        debitAmount: 0.0,
        creditAmount: 12500.0,
      );

      final result = PosWorkspaceDashboardMapper.map(
        wallet: wallet,
        recentInvoices: invoices,
        recentRequests: requests,
        now: now,
      );

      expect(result, hasLength(4));

      // 1. Today Procurement
      final procurement = result.firstWhere((m) => m.id == 'today_procurement');
      expect(procurement.title, 'مشتريات اليوم');
      expect(procurement.value, '5,000.00');
      expect(procurement.variant, DashboardMetricVariant.trend);
      expect(procurement.trend?.direction, DashboardMetricDirection.increase);
      expect(procurement.trend?.valueLabel, '+66.7%');

      // 2. Wallet Balance
      final walletMetric = result.firstWhere((m) => m.id == 'wallet');
      expect(walletMetric.title, 'رصيد المحفظة');
      expect(walletMetric.value, '12,500.00');
      expect(walletMetric.tone, DashboardMetricTone.success);

      // 3. Purchasing Power
      final power = result.firstWhere((m) => m.id == 'purchasing_power');
      expect(power.title, 'القوة الشرائية');
      expect(power.value, '62,500.00');

      // 4. Active Orders
      final active = result.firstWhere((m) => m.id == 'active_orders');
      expect(active.title, 'الطلبات النشطة');
      expect(active.value, '2'); // 1 pending + 1 approved
    });

    test('handles empty invoices and null wallet gracefully', () {
      final result = PosWorkspaceDashboardMapper.map(
        wallet: null,
        recentInvoices: const [],
        recentRequests: const [],
        now: now,
      );

      expect(result, hasLength(2)); // today_procurement and active_orders
      expect(result.any((m) => m.id == 'today_procurement'), isTrue);
      expect(result.any((m) => m.id == 'active_orders'), isTrue);
      expect(result.firstWhere((m) => m.id == 'today_procurement').value, '0.00');
    });
  });
}
