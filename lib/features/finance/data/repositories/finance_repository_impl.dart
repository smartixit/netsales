import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  const FinanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedList<PosWalletEntity>> getPosWallets({
    int? networkId,
    int? posId,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getPosWallets(query: query);
    return PaginatedList<PosWalletEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<PosWalletEntity> getPosWalletByNetworkAndPos(
    int networkId,
    int posId,
  ) async {
    final res = await remoteDataSource.getPosWalletByNetworkAndPos(
      networkId,
      posId,
    );
    return res.data!;
  }

  @override
  Future<PaginatedList<PosWalletLogEntity>> getPosWalletLogs(
    int walletId, {
    String? operationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      if (operationType?.isNotEmpty ?? false)
        'log_operation_type': operationType,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getPosWalletLogs(walletId, query: query);
    return PaginatedList<PosWalletLogEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<PaginatedList<NetworkWalletEntity>> getNetworkWallets({
    int? networkId,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'network_id': ?networkId,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getNetworkWallets(query: query);
    return PaginatedList<NetworkWalletEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<NetworkWalletEntity> getNetworkWalletById(int walletId) async {
    final res = await remoteDataSource.getNetworkWalletById(walletId);
    return res.data!;
  }

  @override
  Future<PaginatedList<NetworkWalletLogEntity>> getNetworkWalletLogs(
    int walletId, {
    String? operation,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      if (operation?.isNotEmpty ?? false) 'log_operation': operation,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getNetworkWalletLogs(
      walletId,
      query: query,
    );
    return PaginatedList<NetworkWalletLogEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<DebtSummaryEntity> getDebtSummary({int? networkId, int? posId}) async {
    final query = <String, dynamic>{'network_id': ?networkId, 'pos_id': ?posId};
    final res = await remoteDataSource.getDebtSummary(query: query);
    final data = res.data ?? {};
    final rawBuckets = data['aging_buckets'] as Map<String, dynamic>? ?? {};
    final buckets = <String, double>{};
    rawBuckets.forEach((k, v) {
      buckets[k] = (v as num?)?.toDouble() ?? 0.0;
    });

    return DebtSummaryEntity(
      totalReceivables: (data['total_receivables'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingInvoices:
          (data['total_outstanding_invoices'] as num?)?.toInt() ?? 0,
      agingBuckets: buckets,
      networkId: networkId,
      posId: posId,
    );
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
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (bucket?.isNotEmpty ?? false) 'bucket': bucket,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getOutstandingInvoices(query: query);
    return PaginatedList<InvoiceEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
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
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (status?.isNotEmpty ?? false) 'status': status,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      'cursor': ?cursor,
      'per_page': ?perPage,
    };
    final res = await remoteDataSource.getRepayments(query: query);
    return PaginatedList<PosRepaymentEntity>(
      items: res.data ?? [],
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<PosRepaymentEntity> getRepaymentById(int repaymentId) async {
    final res = await remoteDataSource.getRepaymentById(repaymentId);
    return res.data!;
  }

  @override
  Future<PosRepaymentEntity> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'amount': amount,
      'payment_method': paymentMethod ?? 'CASH',
      'reference_number': ?referenceNumber,
      'notes': ?notes,
    };
    final res = await remoteDataSource.collectRepayment(payload);
    return res.data!;
  }

  @override
  Future<PosRepaymentEntity> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
  }) async {
    final payload = <String, dynamic>{'reversal_reason': reversalReason};
    final res = await remoteDataSource.reverseRepayment(repaymentId, payload);
    return res.data!;
  }

  @override
  Future<void> transferFromNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'amount': amount,
      'statement': ?statement,
    };
    await remoteDataSource.transferFromNetworkToPos(payload);
  }
}
