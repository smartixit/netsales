import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/packages/data/models/voucher_package_discount_model.dart';
import 'package:netsales/features/packages/data/models/voucher_package_model.dart';

/// ============================================================================
/// عقد مصدر البيانات البعيد للباقات والخصومات (PackagesRemoteDataSource)
/// ============================================================================
abstract interface class PackagesRemoteDataSource {
  /// جلب باقات الكروت
  Future<ApiResponse<List<VoucherPackageModel>>> getVoucherPackages({
    int? networkId,
    bool? status,
    String? search,
  });

  /// إنشاء باقة كروت
  Future<ApiResponse<VoucherPackageModel>> createVoucherPackage(
    Map<String, dynamic> data,
  );

  /// تحديث باقة كروت
  Future<ApiResponse<VoucherPackageModel>> updateVoucherPackage(
    int packageId,
    Map<String, dynamic> data,
  );

  /// تبديل حالة باقة كروت
  Future<ApiResponse<VoucherPackageModel>> toggleVoucherPackageStatus(
    int packageId,
  );

  /// حذف باقة كروت
  Future<ApiResponse<void>> deleteVoucherPackage(int packageId);

  /// جلب الخصومات المخصصة لنقاط البيع
  Future<ApiResponse<List<VoucherPackageDiscountModel>>>
      getVoucherPackageDiscounts({
    int? networkId,
    int? posId,
    int? packageId,
    bool? status,
    String? search,
  });

  /// إنشاء خصم مخصص لنقطة بيع
  Future<ApiResponse<VoucherPackageDiscountModel>> createVoucherPackageDiscount(
    Map<String, dynamic> data,
  );

  /// تحديث خصم مخصص لنقطة بيع
  Future<ApiResponse<VoucherPackageDiscountModel>> updateVoucherPackageDiscount(
    int discountId,
    Map<String, dynamic> data,
  );

  /// تبديل حالة تفعيل خصم مخصص
  Future<ApiResponse<VoucherPackageDiscountModel>>
      toggleVoucherPackageDiscountStatus(int discountId);

  /// حذف خصم مخصص
  Future<ApiResponse<void>> deleteVoucherPackageDiscount(int discountId);
}
