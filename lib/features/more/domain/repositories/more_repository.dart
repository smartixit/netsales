import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';
import 'package:netsales/features/more/domain/entities/expense_entity.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/domain/entities/user_session_entity.dart';

/// ============================================================================
/// عقد مستودع قطاع المزيد الدوميني المجرد (MoreRepository)
/// ============================================================================
/// العقد الحصري لطبقة الدومين لإدارة البيانات المالية والاشتراكات وإنهاء الجلسة.
abstract class MoreRepository {
  /// جلب الملخص المالي والتشغيلي الشامل لشاشة المزيد
  Future<MoreOverviewEntity> getMoreOverview();

  /// جلب ملخص المحفظة المالية للمستخدم الحالي
  Future<MoreWalletEntity?> getWalletSummary();

  /// جلب اشتراك المزود النشط حالياً
  Future<MoreSubscriptionEntity?> getActiveSubscription();

  /// تسجيل خروج المستخدم وإنهاء الجلسة الرسمية
  Future<bool> logout();

  /// جلب قائمة الحسابات المصرفية للمنشأة
  Future<List<BankAccountEntity>> getBankAccounts();

  /// تبديل حالة الحساب المصرفي (تفعيل / تجميد)
  Future<bool> toggleBankAccountStatus(int accountId);

  /// جلب قائمة المصروفات التشغيلية
  Future<List<ExpenseEntity>> getExpenses({
    int page = 1,
    int perPage = 20,
  });

  /// إنشاء قيد مصروف تشغيلي جديد
  Future<bool> createExpense({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  });

  /// جلب قائمة الجلسات النشطة للمستخدم
  Future<List<UserSessionEntity>> getUserSessions(int userId);

  /// إنهاء جلسة معينة عن بُعد
  Future<bool> terminateSession(int sessionId);
}

