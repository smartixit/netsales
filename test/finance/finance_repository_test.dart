import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:netsales/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/finance/data/models/network_wallet_models.dart';
import 'package:netsales/features/finance/data/models/pos_wallet_models.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

class _DebtSummaryRemoteDataSource implements FinanceRemoteDataSource {
  ApiResponse<Map<String, dynamic>> response;
  Map<String, dynamic>? lastQuery;
  Map<String, dynamic>? lastOutstandingInvoicesQuery;
  Map<String, dynamic>? lastRepaymentsQuery;
  ApiResponse<List<PosWalletModel>>? posWalletsResponse;
  ApiResponse<List<PosWalletLogModel>>? posWalletLogsResponse;
  ApiResponse<List<NetworkWalletModel>>? networkWalletsResponse;
  ApiResponse<List<NetworkWalletLogModel>>? networkWalletLogsResponse;
  ApiResponse<List<InvoiceModel>>? outstandingInvoicesResponse;
  ApiResponse<List<PosRepaymentModel>>? repaymentsResponse;

  _DebtSummaryRemoteDataSource(this.response);

  @override
  Future<ApiResponse<List<InvoiceModel>>> getOutstandingInvoices({
    Map<String, dynamic>? query,
  }) async {
    lastOutstandingInvoicesQuery = query;
    return outstandingInvoicesResponse ??
        ApiResponse<List<InvoiceModel>>(
          success: true,
          message: 'ok',
          data: const [],
        );
  }

  @override
  Future<ApiResponse<List<PosRepaymentModel>>> getRepayments({
    Map<String, dynamic>? query,
  }) async {
    lastRepaymentsQuery = query;
    return repaymentsResponse ??
        ApiResponse<List<PosRepaymentModel>>(
          success: true,
          message: 'ok',
          data: const [],
        );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getDebtSummary({
    Map<String, dynamic>? query,
  }) async {
    lastQuery = query;
    return response;
  }


  @override
  Future<ApiResponse<List<PosWalletModel>>> getPosWallets({
    Map<String, dynamic>? query,
  }) async =>
      posWalletsResponse ??
      ApiResponse<List<PosWalletModel>>(
        success: true,
        message: 'ok',
        data: const [],
      );

  @override
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) async =>
      posWalletLogsResponse ??
      ApiResponse<List<PosWalletLogModel>>(
        success: true,
        message: 'ok',
        data: const [],
      );

  @override
  Future<ApiResponse<List<NetworkWalletModel>>> getNetworkWallets({
    Map<String, dynamic>? query,
  }) async =>
      networkWalletsResponse ??
      ApiResponse<List<NetworkWalletModel>>(
        success: true,
        message: 'ok',
        data: const [],
      );

  @override
  Future<ApiResponse<List<NetworkWalletLogModel>>> getNetworkWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) async =>
      networkWalletLogsResponse ??
      ApiResponse<List<NetworkWalletLogModel>>(
        success: true,
        message: 'ok',
        data: const [],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FinanceRepositoryImpl cursor pagination contract', () {
    test('enables Laravel cursor pagination for outstanding invoices', () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: {
            'total_outstanding_debt': 0,
            'unpaid_invoices_count': 0,
            'partially_paid_invoices_count': 0,
            'aging_buckets': {
              'days_0_30': 0,
              'days_31_60': 0,
              'days_61_90': 0,
              'days_over_90': 0,
            },
          },
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      await repository.getOutstandingInvoices(
        networkId: 10,
        posId: 20,
        bucket: '31_60',
        search: 'INV-20',
        cursor: 'invoice-cursor',
        perPage: 25,
      );

      expect(remote.lastOutstandingInvoicesQuery, {
        'network_id': 10,
        'pos_id': 20,
        'bucket': '31_60',
        'search': 'INV-20',
        'cursor': 'invoice-cursor',
        'paginate': true,
        'limit': 25,
      });
    });

    test('enables Laravel cursor pagination for repayment history', () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: {
            'total_outstanding_debt': 0,
            'unpaid_invoices_count': 0,
            'partially_paid_invoices_count': 0,
            'aging_buckets': {
              'days_0_30': 0,
              'days_31_60': 0,
              'days_61_90': 0,
              'days_over_90': 0,
            },
          },
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      await repository.getRepayments(
        networkId: 10,
        posId: 20,
        status: 'COMPLETED',
        search: 'REC-20',
        cursor: 'repayment-cursor',
        perPage: 30,
      );

      expect(remote.lastRepaymentsQuery, {
        'network_id': 10,
        'pos_id': 20,
        'status': 'COMPLETED',
        'search': 'REC-20',
        'cursor': 'repayment-cursor',
        'paginate': true,
        'limit': 30,
      });
    });
  });


  group('FinanceRepositoryImpl list failure contracts', () {
    test('surfaces unsuccessful wallet and ledger responses as failures', () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: const {},
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      remote.posWalletsResponse = ApiResponse<List<PosWalletModel>>(
        success: false,
        message: 'POS wallet list unavailable',
      );
      await expectLater(
        repository.getPosWallets(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'POS_WALLET_LIST_REQUEST_FAILED',
          ),
        ),
      );

      remote.networkWalletsResponse = ApiResponse<List<NetworkWalletModel>>(
        success: false,
        message: 'Network wallet list unavailable',
      );
      await expectLater(
        repository.getNetworkWallets(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'NETWORK_WALLET_LIST_REQUEST_FAILED',
          ),
        ),
      );

      remote.posWalletLogsResponse = ApiResponse<List<PosWalletLogModel>>(
        success: false,
        message: 'POS wallet logs unavailable',
      );
      await expectLater(
        repository.getPosWalletLogs(1),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'POS_WALLET_LOGS_REQUEST_FAILED',
          ),
        ),
      );

      remote.networkWalletLogsResponse =
          ApiResponse<List<NetworkWalletLogModel>>(
            success: false,
            message: 'Network wallet logs unavailable',
          );
      await expectLater(
        repository.getNetworkWalletLogs(1),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'NETWORK_WALLET_LOGS_REQUEST_FAILED',
          ),
        ),
      );
    });

    test('surfaces unsuccessful debt invoice and repayment pages', () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: const {},
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      remote.outstandingInvoicesResponse = ApiResponse<List<InvoiceModel>>(
        success: false,
        message: 'Outstanding invoices unavailable',
      );
      await expectLater(
        repository.getOutstandingInvoices(networkId: 1, posId: 2),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'OUTSTANDING_INVOICE_LIST_REQUEST_FAILED',
          ),
        ),
      );

      remote.repaymentsResponse = ApiResponse<List<PosRepaymentModel>>(
        success: false,
        message: 'Repayment history unavailable',
      );
      await expectLater(
        repository.getRepayments(networkId: 1, posId: 2),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'REPAYMENT_HISTORY_REQUEST_FAILED',
          ),
        ),
      );
    });
  });

  group('FinanceRepositoryImpl debt summary contract', () {
    test('maps Laravel names, counts and aging buckets without data loss',
        () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: {
            'total_outstanding_debt': 12345.67,
            'unpaid_invoices_count': 3,
            'partially_paid_invoices_count': 2,
            'aging_buckets': {
              'days_0_30': 1000.0,
              'days_31_60': 2000.0,
              'days_61_90': 3000.0,
              'days_over_90': 6345.67,
            },
            'oldest_outstanding_invoice_date': '2026-09-01 10:00:00',
          },
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      final summary = await repository.getDebtSummary(
        networkId: 10,
        posId: 20,
      );

      expect(remote.lastQuery, {'network_id': 10, 'pos_id': 20});
      expect(summary.totalReceivables, 12345.67);
      expect(summary.unpaidInvoicesCount, 3);
      expect(summary.partiallyPaidInvoicesCount, 2);
      expect(summary.totalOutstandingInvoices, 5);
      expect(summary.agingBuckets, {
        '0_30': 1000.0,
        '31_60': 2000.0,
        '61_90': 3000.0,
        'over_90': 6345.67,
      });
      expect(
        summary.oldestOutstandingInvoiceDate,
        '2026-09-01 10:00:00',
      );
    });

    test('rejects missing required Laravel fields instead of showing zero',
        () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'ok',
          data: {
            'total_outstanding_debt': 0,
            'unpaid_invoices_count': 0,
            'partially_paid_invoices_count': 0,
            'aging_buckets': {
              'days_0_30': 0,
              'days_31_60': 0,
              'days_61_90': 0,
              // days_over_90 deliberately missing
            },
          },
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      await expectLater(
        repository.getDebtSummary(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'INVALID_DEBT_SUMMARY_CONTRACT',
          ),
        ),
      );
    });

    test('surfaces unsuccessful or empty API summary responses', () async {
      final remote = _DebtSummaryRemoteDataSource(
        ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'تعذر استرجاع ملخص المديونية.',
        ),
      );
      final repository = FinanceRepositoryImpl(remoteDataSource: remote);

      await expectLater(
        repository.getDebtSummary(),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'تعذر استرجاع ملخص المديونية.',
          ),
        ),
      );
    });
  });
}
