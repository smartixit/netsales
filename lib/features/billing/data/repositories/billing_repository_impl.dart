import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/data/models/billing_models.dart';
import 'package:netsales/features/billing/domain/entities/billing_entities.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(this.remoteDataSource);
  final BillingRemoteDataSource remoteDataSource;

  AppException _failure<T>(ApiResponse<T> response, String fallback, String code) =>
      AppException(
        response.message.isNotEmpty ? response.message : fallback,
        code: code,
        details: response.errors,
      );

  PaginatedList<T> _page<T>(ApiResponse<List<T>> response, String fallback, String code) {
    if (!response.success || response.data == null) {
      throw _failure(response, fallback, code);
    }
    return PaginatedList<T>(
      items: response.data!,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }

  @override
  Future<List<BillingCurrencyEntity>> getCurrencies() async {
    final response = await remoteDataSource.getCurrencies();
    return _page(response, 'تعذر تحميل العملات المتاحة.', 'BILLING_CURRENCIES_FAILED').items;
  }

  @override
  Future<List<BillingAccountEntity>> getAccounts(int networkId) async {
    final response = await remoteDataSource.getAccounts(networkId);
    return _page(response, 'تعذر تحميل حسابات فوترة الشبكة.', 'BILLING_ACCOUNTS_FAILED').items;
  }

  @override
  Future<BillingAccountEntity> createAccount(int networkId, int currencyId) async {
    final response = await remoteDataSource.createAccount(networkId, currencyId);
    if (!response.success || response.data == null) {
      throw _failure(response, 'تعذر إنشاء حساب الفوترة.', 'BILLING_ACCOUNT_CREATE_FAILED');
    }
    return response.data!;
  }

  @override
  Future<PaginatedList<BillingSubscriptionEntity>> getSubscriptions(int accountId, {String? cursor}) async {
    final response = await remoteDataSource.getSubscriptions(accountId, cursor: cursor);
    return _page(response, 'تعذر تحميل اشتراكات الحساب.', 'BILLING_SUBSCRIPTIONS_FAILED');
  }

  @override
  Future<PaginatedList<BillingInvoiceEntity>> getInvoices(int accountId, {String? cursor}) async {
    final response = await remoteDataSource.getInvoices(accountId, cursor: cursor);
    return _page(response, 'تعذر تحميل فواتير الاشتراك.', 'BILLING_INVOICES_FAILED');
  }

  @override
  Future<PaginatedList<BillingPaymentEntity>> getPayments(int accountId, {String? cursor}) async {
    final response = await remoteDataSource.getPayments(accountId, cursor: cursor);
    return _page(response, 'تعذر تحميل مدفوعات الاشتراك.', 'BILLING_PAYMENTS_FAILED');
  }

  @override
  Future<PaginatedList<BillingCreditNoteEntity>> getCreditNotes(int accountId, {String? cursor}) async {
    final response = await remoteDataSource.getCreditNotes(accountId, cursor: cursor);
    return _page(response, 'تعذر تحميل الإشعارات الدائنة.', 'BILLING_CREDIT_NOTES_FAILED');
  }

  @override
  Future<PaginatedList<BillingRefundEntity>> getRefunds(int accountId, {String? cursor}) async {
    final response = await remoteDataSource.getRefunds(accountId, cursor: cursor);
    return _page(response, 'تعذر تحميل عمليات الاسترداد.', 'BILLING_REFUNDS_FAILED');
  }
  @override
  Future<BillingStatementEntity> getStatement(
    int accountId, {
    String? from,
    String? to,
    int? currencyId,
  }) async {
    final response = await remoteDataSource.getStatement(
      accountId,
      from: from,
      to: to,
      currencyId: currencyId,
    );
    if (!response.success || response.data == null) {
      throw _failure(
        response,
        'تعذر تحميل كشف حساب الاشتراك.',
        'BILLING_STATEMENT_FAILED',
      );
    }
    return response.data!;
  }

}
