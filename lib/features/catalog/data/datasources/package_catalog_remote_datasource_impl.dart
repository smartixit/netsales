import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/models/package_model.dart';

/// تطبيق مصدر البيانات البعيد لكتالوج الباقات عبر ApiService
class PackageCatalogRemoteDataSourceImpl
    implements PackageCatalogRemoteDataSource {
  const PackageCatalogRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<PackageModel>>> getPackages({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PackageModel>>(
      ApiConstants.voucherPackages,
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) => PackageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<List<PackageModel>>> getNetworkPackages(
    int networkId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PackageModel>>(
      ApiConstants.networkVoucherPackages(networkId),
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map((item) => PackageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<PackageModel>> getPackageDetails(int packageId) {
    return ApiService.instance.get<PackageModel>(
      ApiConstants.voucherPackage(packageId),
      fromJson: (data) => PackageModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PackageModel>> createPackage(Map<String, dynamic> data) {
    return ApiService.instance.post<PackageModel>(
      ApiConstants.voucherPackages,
      data: data,
      fromJson: (resData) =>
          PackageModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PackageModel>> updatePackage(
    int packageId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<PackageModel>(
      ApiConstants.voucherPackage(packageId),
      data: data,
      fromJson: (resData) =>
          PackageModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PackageModel>> togglePackageStatus(int packageId) {
    return ApiService.instance.post<PackageModel>(
      ApiConstants.voucherPackageToggleStatus(packageId),
      fromJson: (resData) =>
          PackageModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> deletePackage(int packageId) {
    return ApiService.instance.delete<void>(
      ApiConstants.voucherPackage(packageId),
    );
  }
}

