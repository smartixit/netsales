import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// واجهة مستودع العمليات المالية والائتمان وسداد الديون (Finance Repository)
abstract interface class FinanceRepository {
  // 1. محافظ نقاط البيع
  Future<PaginatedList<PosWalletEntity>> getPosWallets({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  });

  Future<PosWalletEntity> getPosWalletByNetworkAndPos(int networkId, int posId);

  Future<PaginatedList<PosWalletLogEntity>> getPosWalletLogs(
    int walletId, {
    String? operationType,
    String? search,
    String? cursor,
    int? perPage,
  });

  // 2. محافظ الشبكات
  Future<PaginatedList<NetworkWalletEntity>> getNetworkWallets({
    int? networkId,
    String? search,
    String? cursor,
    int? perPage,
  });

  Future<NetworkWalletEntity> getNetworkWalletById(int walletId);

  Future<PaginatedList<NetworkWalletLogEntity>> getNetworkWalletLogs(
    int walletId, {
    String? operation,
    String? search,
    String? cursor,
    int? perPage,
  });

  // 3. الديون والذمم المدينة والشرائح العمرية
  Future<DebtSummaryEntity> getDebtSummary({int? networkId, int? posId});

  Future<PaginatedList<InvoiceEntity>> getOutstandingInvoices({
    int? networkId,
    int? posId,
    String? bucket,
    String? search,
    String? cursor,
    int? perPage,
  });

  // 4. سندات سداد الديون وتوزيعات FIFO
  Future<PaginatedList<PosRepaymentEntity>> getRepayments({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  Future<PosRepaymentEntity> getRepaymentById(int repaymentId);

  Future<PosRepaymentEntity> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
  });

  Future<PosRepaymentEntity> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
  });

  // 5. التحويل والتغذية المباشرة
  Future<void> transferFromNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });
}
