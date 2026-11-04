import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// واجهة مستودع كتالوج باقات الكروت (Clean Architecture Domain Contract)
abstract class PackageCatalogRepository {
  /// استرجاع قائمة الباقات مع الفلترة والبحث
  Future<List<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    int? perPage,
  });

  /// استرجاع باقات شبكة معينة
  Future<List<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    int? perPage,
  });

  /// استرجاع تفاصيل باقة محددة
  Future<PackageEntity> getPackageDetails(int packageId);

  /// إنشاء باقة كروت جديدة
  Future<PackageEntity> createPackage(Map<String, dynamic> data);

  /// تحديث بيانات باقة كروت
  Future<PackageEntity> updatePackage(
    int packageId,
    Map<String, dynamic> data,
  );

  /// تبديل حالة تفعيل الباقة
  Future<PackageEntity> togglePackageStatus(int packageId);

  /// حذف باقة كروت من النظام
  Future<bool> deletePackage(int packageId);
}

