import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';
import 'package:netsales/features/more/domain/entities/expense_entity.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/domain/entities/user_session_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// تطبيق مستودع قطاع المزيد والمركز المالي (MoreRepositoryImpl)
/// ============================================================================
class MoreRepositoryImpl implements MoreRepository {
  final MoreRemoteDataSource _remoteDataSource;

  const MoreRepositoryImpl(this._remoteDataSource);

  @override
  Future<MoreOverviewEntity> getMoreOverview() async {
    try {
      final response = await _remoteDataSource.getMoreOverview();
      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (_) {
      // إخفاق صامت والرجوع للقيم الافتراضية لمنع تجميد الشاشة
    }
    return const MoreOverviewEntity();
  }

  @override
  Future<MoreWalletEntity?> getWalletSummary() async {
    try {
      final response = await _remoteDataSource.getWalletSummary();
      if (response.success) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<MoreSubscriptionEntity?> getActiveSubscription() async {
    try {
      final response = await _remoteDataSource.getActiveSubscription();
      if (response.success) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // نتجاهل أخطاء الشبكة أثناء تسجيل الخروج لضمان تنظيف الجلسة محلياً دائماً
    }
    await SessionService.instance.terminateSession();
    return true;
  }

  @override
  Future<List<BankAccountEntity>> getBankAccounts() async {
    final response = await _remoteDataSource.getBankAccounts();
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر استرجاع الحسابات المصرفية',
      );
    }
    return response.data ?? <BankAccountEntity>[];
  }

  @override
  Future<bool> toggleBankAccountStatus(int accountId) async {
    final response = await _remoteDataSource.toggleBankAccountStatus(accountId);
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'فشل تبديل حالة الحساب المصرفي',
      );
    }
    return true;
  }

  @override
  Future<List<ExpenseEntity>> getExpenses({
    int page = 1,
    int perPage = 20,
  }) async {
    final response =
        await _remoteDataSource.getExpenses(page: page, perPage: perPage);
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة المصروفات التشغيلية',
      );
    }
    return response.data ?? <ExpenseEntity>[];
  }

  @override
  Future<bool> createExpense({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  }) async {
    final response = await _remoteDataSource.createExpense(
      networkId: networkId,
      totalAmount: totalAmount,
      expenseDate: expenseDate,
      notes: notes,
    );
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل قيد المصروف',
      );
    }
    return true;
  }

  @override
  Future<List<UserSessionEntity>> getUserSessions(int userId) async {
    final response = await _remoteDataSource.getUserSessions(userId);
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب الجلسات النشطة',
      );
    }
    return response.data ?? <UserSessionEntity>[];
  }

  @override
  Future<bool> terminateSession(int sessionId) async {
    final response = await _remoteDataSource.terminateSession(sessionId);
    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل إنهاء الجلسة',
      );
    }
    return true;
  }
}

