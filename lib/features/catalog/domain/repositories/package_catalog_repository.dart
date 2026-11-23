import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/create_package_input.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/entities/update_package_input.dart';

/// واجهة مستودع كتالوج الباقات النظيفة (Package Catalog Repository Contract)
abstract class PackageCatalogRepository {
  /// استرجاع قائمة الباقات مع الفلترة والبحث وترقيم المؤشر
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  });

  /// استرجاع باقات شبكة معينة
  Future<PaginatedList<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// استرجاع تفاصيل باقة محددة
  Future<PackageEntity> getPackageDetails(int packageId);

  /// استرجاع الخصومات التعاقدية المخصصة لنقطة بيع وشبكة
  Future<List<EffectivePackageDiscountEntity>> getEffectiveDiscountsForPos({
    required int networkId,
    required int posId,
  });

  /// استرجاع الخصم الفعلي المعتمد لنقطة بيع على باقة معينة
  Future<EffectivePackageDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  });

  /// إنشاء باقة كروت جديدة عبر كائن النطاق الصارم
  Future<PackageEntity> createPackage(CreatePackageInput input);

  /// تحديث بيانات باقة كروت قائمة عبر كائن النطاق الصارم
  Future<PackageEntity> updatePackage(int packageId, UpdatePackageInput input);

  /// تبديل حالة تفعيل الباقة ذرياً
  Future<PackageEntity> togglePackageStatus(int packageId);

  /// حذف باقة كروت ناعماً من النظام
  Future<bool> deletePackage(int packageId);
}
