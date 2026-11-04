import 'package:netsales/features/packages/domain/entities/effective_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';

/// واجهة مستودع باقات الكروت والخصومات التعاقدية (Clean Architecture Domain Contract)
abstract class PackagesRepository {
  /// استرجاع قائمة الباقات مع الفلترة والبحث
  Future<List<VoucherPackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    int? perPage,
  });

  /// استرجاع باقات شبكة معينة
  Future<List<VoucherPackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
  });

  /// استرجاع تفاصيل باقة محددة
  Future<VoucherPackageEntity> getPackageDetails(int packageId);

  /// إنشاء باقة كروت جديدة
  Future<VoucherPackageEntity> createPackage(Map<String, dynamic> data);

  /// تحديث بيانات باقة كروت
  Future<VoucherPackageEntity> updatePackage(
    int packageId,
    Map<String, dynamic> data,
  );

  /// تبديل حالة تفعيل الباقة
  Future<VoucherPackageEntity> togglePackageStatus(int packageId);

  /// حذف باقة كروت
  Future<bool> deletePackage(int packageId);

  /// استرجاع قائمة الخصومات المخصصة
  Future<List<VoucherPackageDiscountEntity>> getPackageDiscounts({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
    int? perPage,
  });

  /// استرجاع الخصم الفعلي لنقطة بيع على باقة محددة
  Future<EffectiveDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  });

  /// إنشاء خصم تعاقدي مخصص لنقطة بيع
  Future<VoucherPackageDiscountEntity> createPackageDiscount(
    Map<String, dynamic> data,
  );

  /// تحديث بيانات خصم مخصص
  Future<VoucherPackageDiscountEntity> updatePackageDiscount(
    int discountId,
    Map<String, dynamic> data,
  );

  /// تبديل حالة تفعيل الخصم المخصص
  Future<VoucherPackageDiscountEntity> togglePackageDiscountStatus(
    int discountId,
  );

  /// حذف خصم مخصص
  Future<bool> deletePackageDiscount(int discountId);
}

