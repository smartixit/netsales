import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
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

  AppException _listRequestFailure<T>(
    ApiResponse<List<T>> response, {
    required String fallback,
    required String code,
  }) {
    return AppException(
      response.message.isNotEmpty ? response.message : fallback,
      code: code,
      details: response.errors,
    );
  }

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
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع محافظ نقطة البيع من الخادم.',
        code: 'POS_WALLET_LIST_REQUEST_FAILED',
      );
    }
    return PaginatedList<PosWalletEntity>(
      items: res.data!,
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
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع حركات محفظة نقطة البيع.',
        code: 'POS_WALLET_LOGS_REQUEST_FAILED',
      );
    }
    return PaginatedList<PosWalletLogEntity>(
      items: res.data!,
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
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع محافظ الشبكة من الخادم.',
        code: 'NETWORK_WALLET_LIST_REQUEST_FAILED',
      );
    }
    return PaginatedList<NetworkWalletEntity>(
      items: res.data!,
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
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع حركات محفظة الشبكة.',
        code: 'NETWORK_WALLET_LOGS_REQUEST_FAILED',
      );
    }
    return PaginatedList<NetworkWalletLogEntity>(
      items: res.data!,
      nextCursor: res.nextCursor,
      prevCursor: res.prevCursor,
    );
  }

  @override
  Future<DebtSummaryEntity> getDebtSummary({int? networkId, int? posId}) async {
    final query = <String, dynamic>{'network_id': ?networkId, 'pos_id': ?posId};
    final res = await remoteDataSource.getDebtSummary(query: query);

    if (!res.success || res.data == null) {
      throw AppException(
        res.message.isNotEmpty
            ? res.message
            : 'تعذر استرجاع ملخص المديونية من الخادم.',
        code: 'DEBT_SUMMARY_REQUEST_FAILED',
        details: res.errors,
      );
    }

    final data = res.data!;
    final totalDebt = _requiredDebtNumber(data, 'total_outstanding_debt');
    final unpaidCount = _requiredDebtCount(data, 'unpaid_invoices_count');
    final partialCount =
        _requiredDebtCount(data, 'partially_paid_invoices_count');

    final rawBuckets = data['aging_buckets'];
    if (rawBuckets is! Map) {
      throw const AppException(
        'استجابة ملخص المديونية لا تحتوي على aging_buckets صالح.',
        code: 'INVALID_DEBT_SUMMARY_CONTRACT',
      );
    }

    final buckets = <String, double>{
      '0_30': _requiredDebtNumber(rawBuckets, 'days_0_30'),
      '31_60': _requiredDebtNumber(rawBuckets, 'days_31_60'),
      '61_90': _requiredDebtNumber(rawBuckets, 'days_61_90'),
      'over_90': _requiredDebtNumber(rawBuckets, 'days_over_90'),
    };

    return DebtSummaryEntity(
      totalReceivables: totalDebt,
      unpaidInvoicesCount: unpaidCount,
      partiallyPaidInvoicesCount: partialCount,
      agingBuckets: buckets,
      oldestOutstandingInvoiceDate:
          data['oldest_outstanding_invoice_date']?.toString(),
      networkId: networkId,
      posId: posId,
    );
  }

  double _requiredDebtNumber(Map<dynamic, dynamic> data, String key) {
    final value = data[key];
    if (value is! num || !value.isFinite) {
      throw AppException(
        'حقل ملخص المديونية "$key" مفقود أو غير رقمي.',
        code: 'INVALID_DEBT_SUMMARY_CONTRACT',
      );
    }
    return value.toDouble();
  }

  int _requiredDebtCount(Map<dynamic, dynamic> data, String key) {
    final value = data[key];
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value != value.toInt()) {
      throw AppException(
        'حقل ملخص المديونية "$key" مفقود أو غير صحيح.',
        code: 'INVALID_DEBT_SUMMARY_CONTRACT',
      );
    }
    return value.toInt();
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
      'paginate': true,
      'limit': ?perPage,
    };
    final res = await remoteDataSource.getOutstandingInvoices(query: query);
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع فواتير الذمم المستحقة.',
        code: 'OUTSTANDING_INVOICE_LIST_REQUEST_FAILED',
      );
    }
    return PaginatedList<InvoiceEntity>(
      items: res.data!,
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
      'paginate': true,
      'limit': ?perPage,
    };
    final res = await remoteDataSource.getRepayments(query: query);
    if (!res.success || res.data == null) {
      throw _listRequestFailure(
        res,
        fallback: 'تعذر استرجاع سجل سندات السداد.',
        code: 'REPAYMENT_HISTORY_REQUEST_FAILED',
      );
    }
    return PaginatedList<PosRepaymentEntity>(
      items: res.data!,
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
