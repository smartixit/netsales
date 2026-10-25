import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';

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
}
