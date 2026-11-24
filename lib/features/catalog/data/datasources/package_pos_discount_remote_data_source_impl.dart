import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/catalog/data/datasources/package_pos_discount_remote_data_source.dart';
import 'package:netsales/features/catalog/data/models/package_pos_discount_model.dart';

class PackagePosDiscountRemoteDataSourceImpl implements PackagePosDiscountRemoteDataSource {
  const PackagePosDiscountRemoteDataSourceImpl();
  @override
  Future<ApiResponse<List<PackagePosDiscountModel>>> getForPackage({
    required int networkId, required int packageId, String? search, String? cursor, String? status, String? validityState,
  }) => ApiService.instance.getList<PackagePosDiscountModel>(
    ApiConstants.voucherPackageDiscounts,
    fromJson: (json) => PackagePosDiscountModel.fromJson(Map<String,dynamic>.from(json as Map)),
    queryParameters: {
      'network_id': networkId, 'package_id': packageId,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'status': ?status,
      'validity_state': ?validityState,
    },
    cursor: cursor, perPage: 15,
  );
}
