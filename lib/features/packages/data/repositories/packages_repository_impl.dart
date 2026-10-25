import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:netsales/features/packages/domain/entities/effective_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';

/// ============================================================================
/// تطبيق مستودع باقات الكروت والخصومات (PackagesRepositoryImpl)
/// ============================================================================
/// ينفذ عقد النطاق PackagesRepository ويحوّل استجابات مصدر البيانات
/// إلى كيانات دومينية مباشرة عبر التعددية الشكلية (Polymorphic Entities).
class PackagesRepositoryImpl implements PackagesRepository {
  final PackagesRemoteDataSource remoteDataSource;

  const PackagesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<VoucherPackageEntity>> getVoucherPackages({
    int? networkId,
    bool? status,
    String? search,
  }) async {
    final response = await remoteDataSource.getVoucherPackages(
      networkId: networkId,
      status: status,
      search: search,
    );

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<VoucherPackageEntity> getVoucherPackageDetails(int packageId) async {
    final response =
        await remoteDataSource.getVoucherPackageDetails(packageId);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
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
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'package_name': packageName,
      if (packageColor != null) 'package_color': packageColor,
      if (packageBalance != null) 'package_balance': packageBalance,
      if (packageUptime != null) 'package_uptime': packageUptime,
      if (packageValidity != null) 'package_validity': packageValidity,
      if (packageVoucherCount != null)
        'package_voucher_count': packageVoucherCount,
      'package_voucher_price': packageVoucherPrice,
      'package_default_cash_discount': packageDefaultCashDiscount,
      'package_default_credit_discount': packageDefaultCreditDiscount,
      if (status != null) 'status': status,
    };

    final response = await remoteDataSource.createVoucherPackage(payload);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
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
  }) async {
    final payload = <String, dynamic>{
      if (packageName != null) 'package_name': packageName,
      if (packageColor != null) 'package_color': packageColor,
      if (packageBalance != null) 'package_balance': packageBalance,
      if (packageUptime != null) 'package_uptime': packageUptime,
      if (packageValidity != null) 'package_validity': packageValidity,
      if (packageVoucherCount != null)
        'package_voucher_count': packageVoucherCount,
      if (packageVoucherPrice != null)
        'package_voucher_price': packageVoucherPrice,
      if (packageDefaultCashDiscount != null)
        'package_default_cash_discount': packageDefaultCashDiscount,
      if (packageDefaultCreditDiscount != null)
        'package_default_credit_discount': packageDefaultCreditDiscount,
      if (status != null) 'status': status,
    };

    final response =
        await remoteDataSource.updateVoucherPackage(packageId, payload);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<VoucherPackageEntity> toggleVoucherPackageStatus(int packageId) async {
    final response =
        await remoteDataSource.toggleVoucherPackageStatus(packageId);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<bool> deleteVoucherPackage(int packageId) async {
    final response = await remoteDataSource.deleteVoucherPackage(packageId);

    if (!response.success) {
      throw AppException(response.message);
    }

    return true;
  }

  @override
  Future<List<VoucherPackageDiscountEntity>> getVoucherPackageDiscounts({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
  }) async {
    final response = await remoteDataSource.getVoucherPackageDiscounts(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
      status: status,
      search: search,
    );

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<VoucherPackageDiscountEntity> createVoucherPackageDiscount({
    required int networkId,
    required int posId,
    required int packageId,
    required double discountCash,
    required double discountCredit,
    bool? status,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'package_id': packageId,
      'discount_cash': discountCash,
      'discount_credit': discountCredit,
      if (status != null) 'status': status,
    };

    final response =
        await remoteDataSource.createVoucherPackageDiscount(payload);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<VoucherPackageDiscountEntity> updateVoucherPackageDiscount({
    required int discountId,
    double? discountCash,
    double? discountCredit,
    bool? status,
  }) async {
    final payload = <String, dynamic>{
      if (discountCash != null) 'discount_cash': discountCash,
      if (discountCredit != null) 'discount_credit': discountCredit,
      if (status != null) 'status': status,
    };

    final response = await remoteDataSource.updateVoucherPackageDiscount(
      discountId,
      payload,
    );

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<VoucherPackageDiscountEntity> toggleVoucherPackageDiscountStatus(
    int discountId,
  ) async {
    final response = await remoteDataSource
        .toggleVoucherPackageDiscountStatus(discountId);

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }

  @override
  Future<bool> deleteVoucherPackageDiscount(int discountId) async {
    final response =
        await remoteDataSource.deleteVoucherPackageDiscount(discountId);

    if (!response.success) {
      throw AppException(response.message);
    }

    return true;
  }

  @override
  Future<EffectiveDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  }) async {
    final response = await remoteDataSource.getEffectiveDiscount(
      networkId: networkId,
      posId: posId,
      packageId: packageId,
    );

    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }

    return response.data!;
  }
}
