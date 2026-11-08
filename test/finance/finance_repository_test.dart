import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:netsales/features/finance/data/repositories/finance_repository_impl.dart';

class _DebtSummaryRemoteDataSource implements FinanceRemoteDataSource {
  ApiResponse<Map<String, dynamic>> response;
  Map<String, dynamic>? lastQuery;

  _DebtSummaryRemoteDataSource(this.response);

  @override
  Future<ApiResponse<Map<String, dynamic>>> getDebtSummary({
    Map<String, dynamic>? query,
  }) async {
    lastQuery = query;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
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
