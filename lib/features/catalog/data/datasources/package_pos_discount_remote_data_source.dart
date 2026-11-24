import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/catalog/data/models/package_pos_discount_model.dart';

abstract class PackagePosDiscountRemoteDataSource {
  Future<ApiResponse<List<PackagePosDiscountModel>>> getForPackage({
    required int networkId, required int packageId,
    String? search, String? cursor,
  });
}
