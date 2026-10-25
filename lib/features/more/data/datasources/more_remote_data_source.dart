import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/more/data/models/more_overview_model.dart';
import 'package:netsales/features/more/data/models/more_subscription_model.dart';
import 'package:netsales/features/more/data/models/more_wallet_model.dart';

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
}
