import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/catalog/data/models/package_model.dart';

/// واجهة مصدر البيانات البعيد لكتالوج الباقات
abstract class PackageCatalogRemoteDataSource {
  Future<ApiResponse<List<PackageModel>>> getPackages({
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<List<PackageModel>>> getNetworkPackages(
    int networkId, {
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<PackageModel>> getPackageDetails(int packageId);

  Future<ApiResponse<PackageModel>> createPackage(Map<String, dynamic> data);

  Future<ApiResponse<PackageModel>> updatePackage(
    int packageId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<PackageModel>> togglePackageStatus(int packageId);

  Future<ApiResponse<void>> deletePackage(int packageId);
}

