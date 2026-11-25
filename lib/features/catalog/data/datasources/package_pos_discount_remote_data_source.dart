import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/catalog/data/models/package_pos_discount_model.dart';

abstract class PackagePosDiscountRemoteDataSource {
  Future<ApiResponse<List<PackagePosDiscountModel>>> getForPos({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  });

  Future<ApiResponse<List<PackagePosDiscountModel>>> getTrashedForPos({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  });

  Future<ApiResponse<dynamic>> restore(int discountId);
  Future<ApiResponse<PackagePosDiscountModel>> create(Map<String, dynamic> payload);
  Future<ApiResponse<PackagePosDiscountModel>> update(int discountId, Map<String, dynamic> payload);
  Future<ApiResponse<PackagePosDiscountModel>> toggleStatus(int discountId);
  Future<ApiResponse<dynamic>> delete(int discountId);

  Future<ApiResponse<List<PackagePosDiscountModel>>> getForPackage({
    required int networkId, required int packageId,
    String? search, String? cursor, String? status, String? validityState,
  });
}
