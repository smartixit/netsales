import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/more/data/models/bank_account_model.dart';
import 'package:netsales/features/more/data/models/expense_model.dart';
import 'package:netsales/features/more/data/models/more_overview_model.dart';
import 'package:netsales/features/more/data/models/more_subscription_model.dart';
import 'package:netsales/features/more/data/models/more_wallet_model.dart';
import 'package:netsales/features/more/data/models/user_session_model.dart';

/// ============================================================================
/// عقد مصدر البيانات البعيد لقطاع المزيد (MoreRemoteDataSource)
/// ============================================================================
abstract class MoreRemoteDataSource {
  /// استرجاع الملخص المالي والتشغيلي المجمع
  Future<ApiResponse<MoreOverviewModel>> getMoreOverview();

  /// استرجاع رصيد المحفظة المالية للمستخدم الحالي
  Future<ApiResponse<MoreWalletModel>> getWalletSummary();

  /// استرجاع اشتراك النظام النشط للمزود
  Future<ApiResponse<MoreSubscriptionModel>> getActiveSubscription();

  /// إرسال طلب تسجيل الخروج للخادم لإنهاء الجلسة الرسمية
  Future<ApiResponse<void>> logout();

  /// استرجاع قائمة الحسابات المصرفية للمنشأة
  Future<ApiResponse<List<BankAccountModel>>> getBankAccounts();

  /// تبديل حالة تفعيل الحساب المصرفي
  Future<ApiResponse<BankAccountModel>> toggleBankAccountStatus(int accountId);

  /// استرجاع قائمة المصروفات التشغيلية
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    int page = 1,
    int perPage = 20,
  });

  /// إنشاء قيد مصروف تشغيلي جديد
  Future<ApiResponse<ExpenseModel>> createExpense({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  });

  /// استرجاع قائمة الجلسات النشطة للمستخدم
  Future<ApiResponse<List<UserSessionModel>>> getUserSessions(int userId);

  /// إنهاء جلسة محددة عن بُعد
  Future<ApiResponse<void>> terminateSession(int sessionId);
}

