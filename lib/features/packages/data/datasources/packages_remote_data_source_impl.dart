import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:netsales/features/packages/data/models/voucher_package_discount_model.dart';
import 'package:netsales/features/packages/data/models/voucher_package_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد للباقات والخصومات (PackagesRemoteDataSourceImpl)
/// ============================================================================
/// ينفذ استدعاءات الشبكة للواجهة الخلفية عبر [ApiService].
class PackagesRemoteDataSourceImpl implements PackagesRemoteDataSource {
  const PackagesRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<VoucherPackageModel>>> getVoucherPackages({
    int? networkId,
    bool? status,
    String? search,
  }) {
    final queryParams = <String, dynamic>{
      if (networkId != null && networkId > 0) 'network_id': networkId,
      if (status != null) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    return ApiService.instance.getList<VoucherPackageModel>(
      ApiConstants.voucherPackages,
      queryParameters: queryParams,
      fromJson: (json) => VoucherPackageModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageModel>> createVoucherPackage(
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<VoucherPackageModel>(
      ApiConstants.voucherPackages,
      data: data,
      fromJson: (json) => VoucherPackageModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageModel>> updateVoucherPackage(
    int packageId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<VoucherPackageModel>(
      ApiConstants.voucherPackage(packageId),
      data: data,
      fromJson: (json) => VoucherPackageModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageModel>> toggleVoucherPackageStatus(
    int packageId,
  ) {
    return ApiService.instance.post<VoucherPackageModel>(
      ApiConstants.voucherPackageToggleStatus(packageId),
      fromJson: (json) => VoucherPackageModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<void>> deleteVoucherPackage(int packageId) {
    return ApiService.instance.delete<void>(
      ApiConstants.voucherPackage(packageId),
    );
  }

  @override
  Future<ApiResponse<List<VoucherPackageDiscountModel>>>
      getVoucherPackageDiscounts({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
  }) {
    final queryParams = <String, dynamic>{
      if (networkId != null && networkId > 0) 'network_id': networkId,
      if (posId != null && posId > 0) 'pos_id': posId,
      if (packageId != null && packageId > 0) 'package_id': packageId,
      if (status != null) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    return ApiService.instance.getList<VoucherPackageDiscountModel>(
      ApiConstants.voucherPackageDiscounts,
      queryParameters: queryParams,
      fromJson: (json) => VoucherPackageDiscountModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageDiscountModel>> createVoucherPackageDiscount(
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<VoucherPackageDiscountModel>(
      ApiConstants.voucherPackageDiscounts,
      data: data,
      fromJson: (json) => VoucherPackageDiscountModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageDiscountModel>> updateVoucherPackageDiscount(
    int discountId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<VoucherPackageDiscountModel>(
      ApiConstants.voucherPackageDiscount(discountId),
      data: data,
      fromJson: (json) => VoucherPackageDiscountModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<VoucherPackageDiscountModel>>
      toggleVoucherPackageDiscountStatus(int discountId) {
    return ApiService.instance.post<VoucherPackageDiscountModel>(
      ApiConstants.voucherPackageDiscountToggleStatus(discountId),
      fromJson: (json) => VoucherPackageDiscountModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<void>> deleteVoucherPackageDiscount(int discountId) {
    return ApiService.instance.delete<void>(
      ApiConstants.voucherPackageDiscount(discountId),
    );
  }
}
