import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/domain/entities/create_package_input.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/entities/update_package_input.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// تطبيق مستودع كتالوج الباقات (Package Catalog Repository Implementation)
///
/// مسؤولية طبقة البيانات الوحيدة:
/// - تحويل كائنات النطاق النقية [CreatePackageInput] و [UpdatePackageInput] إلى حمولات JSON ومفاتيح الباكيند.
/// - عزل المتحكم وطبقة النطاق تماماً عن تفاصيل الشبكة وقاعدة البيانات.
class PackageCatalogRepositoryImpl implements PackageCatalogRepository {
  final PackageCatalogRemoteDataSource _remoteDataSource;

  const PackageCatalogRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  }) async {
    final query = <String, dynamic>{};
    if (networkId != null) query['network_id'] = networkId;
    if (posId != null) query['pos_id'] = posId;
    if (status != null) query['status'] = status ? '1' : '0';
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (perPage != null) query['per_page'] = perPage;
    if (packageIds != null && packageIds.isNotEmpty) {
      query['package_ids[]'] = packageIds;
    }

    final response = await _remoteDataSource.getPackages(
      query: query.isEmpty ? null : query,
    );

    if (response.success && response.data != null) {
      return PaginatedList<PackageEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<PaginatedList<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status ? '1' : '0';
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (perPage != null) query['per_page'] = perPage;

    final response = await _remoteDataSource.getNetworkPackages(
      networkId,
      query: query.isEmpty ? null : query,
    );

    if (response.success && response.data != null) {
      return PaginatedList<PackageEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> getPackageDetails(int packageId) async {
    final response = await _remoteDataSource.getPackageDetails(packageId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<List<EffectivePackageDiscountEntity>> getEffectiveDiscountsForPos({
    required int networkId,
    required int posId,
  }) async {
    final response = await _remoteDataSource.getEffectiveDiscountsForPos(
      networkId: networkId,
      posId: posId,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<EffectivePackageDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  }) async {
    final response = await _remoteDataSource.getEffectiveDiscount(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> createPackage(CreatePackageInput input) async {
    // تشكيل حمولة الـ JSON ومفاتيح الباكيند داخل طبقة البيانات حصراً
    final payload = <String, dynamic>{
      'network_id': input.networkId,
      'package_name': input.packageName,
      if (input.packageColor != null && input.packageColor!.isNotEmpty)
        'package_color': input.packageColor,
      'package_balance': input.packageBalance,
      if (input.packageUptime != null) 'package_uptime': input.packageUptime,
      if (input.packageValidity != null)
        'package_validity': input.packageValidity,
      'package_voucher_count': input.packageVoucherCount,
      'package_voucher_price': input.packageVoucherPrice,
      'package_default_cash_discount': input.packageDefaultCashDiscount,
      'package_default_credit_discount': input.packageDefaultCreditDiscount,
      'status': input.status,
    };

    final response = await _remoteDataSource.createPackage(payload);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> updatePackage(
    int packageId,
    UpdatePackageInput input,
  ) async {
    // تشكيل حمولة التحديث الجزئي داخل طبقة البيانات حصراً
    final payload = <String, dynamic>{
      if (input.packageName != null) 'package_name': input.packageName,
      if (input.packageColor != null) 'package_color': input.packageColor,
      if (input.packageBalance != null) 'package_balance': input.packageBalance,
      if (input.packageUptime != null) 'package_uptime': input.packageUptime,
      if (input.packageValidity != null)
        'package_validity': input.packageValidity,
      if (input.packageVoucherCount != null)
        'package_voucher_count': input.packageVoucherCount,
      if (input.packageVoucherPrice != null)
        'package_voucher_price': input.packageVoucherPrice,
      if (input.packageDefaultCashDiscount != null)
        'package_default_cash_discount': input.packageDefaultCashDiscount,
      if (input.packageDefaultCreditDiscount != null)
        'package_default_credit_discount': input.packageDefaultCreditDiscount,
      if (input.status != null) 'status': input.status,
    };

    final response = await _remoteDataSource.updatePackage(packageId, payload);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> togglePackageStatus(int packageId) async {
    final response = await _remoteDataSource.togglePackageStatus(packageId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<bool> deletePackage(int packageId) async {
    final response = await _remoteDataSource.deletePackage(packageId);

    if (response.success) {
      return true;
    }

    throw AppException(response.message);
  }
}
