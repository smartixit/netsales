import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';

/// ============================================================================
/// عقد مستودع باقات الكروت والخصومات المخصصة (PackagesRepository)
/// ============================================================================
/// واجهة تجريدية نقية تمثل العقد المعماري لعمليات الباقات والخصومات المخصصة،
/// معزولة تماماً عن أي تفاصيل تقنية أو مصادر بيانات.
abstract interface class PackagesRepository {
  /// جلب قائمة باقات الكروت مع الفلترة والبحث
  Future<List<VoucherPackageEntity>> getVoucherPackages({
    int? networkId,
    bool? status,
    String? search,
  });

  /// إنشاء باقة كروت جديدة
  Future<VoucherPackageEntity> createVoucherPackage({
    required int networkId,
    required String packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    required double packageVoucherPrice,
    required double packageDefaultCashDiscount,
    required double packageDefaultCreditDiscount,
    bool? status,
  });

  /// تحديث بيانات باقة كروت
  Future<VoucherPackageEntity> updateVoucherPackage({
    required int packageId,
    String? packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    double? packageVoucherPrice,
    double? packageDefaultCashDiscount,
    double? packageDefaultCreditDiscount,
    bool? status,
  });

  /// تبديل حالة تفعيل باقة الكروت
  Future<VoucherPackageEntity> toggleVoucherPackageStatus(int packageId);

  /// حذف باقة كروت
  Future<bool> deleteVoucherPackage(int packageId);

  /// جلب قائمة الخصومات المخصصة لنقاط البيع
  Future<List<VoucherPackageDiscountEntity>> getVoucherPackageDiscounts({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
  });

  /// إنشاء خصم مخصص لنقطة بيع على باقة
  Future<VoucherPackageDiscountEntity> createVoucherPackageDiscount({
    required int networkId,
    required int posId,
    required int packageId,
    required double discountCash,
    required double discountCredit,
    bool? status,
  });

  /// تحديث خصم مخصص لنقطة بيع
  Future<VoucherPackageDiscountEntity> updateVoucherPackageDiscount({
    required int discountId,
    double? discountCash,
    double? discountCredit,
    bool? status,
  });

  /// تبديل حالة تفعيل خصم مخصص
  Future<VoucherPackageDiscountEntity> toggleVoucherPackageDiscountStatus(
    int discountId,
  );

  /// حذف خصم مخصص
  Future<bool> deleteVoucherPackageDiscount(int discountId);
}
