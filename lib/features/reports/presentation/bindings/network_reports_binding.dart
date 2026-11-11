import 'package:get/get.dart';
import 'package:netsales/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:netsales/features/reports/data/datasources/report_remote_data_source_impl.dart';
import 'package:netsales/features/reports/data/repositories/report_repository_impl.dart';
import 'package:netsales/features/reports/domain/repositories/report_repository.dart';
import 'package:netsales/features/reports/domain/usecases/report_use_cases.dart';
import 'package:netsales/features/reports/presentation/controllers/network_reports_controller.dart';

class NetworkReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportRemoteDataSource>(() => const ReportRemoteDataSourceImpl());
    Get.lazyPut<ReportRepository>(
      () => ReportRepositoryImpl(Get.find<ReportRemoteDataSource>()),
    );
    Get.lazyPut(() => GetNetworkReportCatalogUseCase(Get.find<ReportRepository>()));
    Get.lazyPut(() => CreateNetworkReportRunUseCase(Get.find<ReportRepository>()));
    Get.lazyPut(() => GetNetworkReportRunUseCase(Get.find<ReportRepository>()));
    Get.lazyPut(() => DownloadReportArtifactUseCase(Get.find<ReportRepository>()));
    Get.lazyPut(
      () => NetworkReportsController(
        getCatalog: Get.find<GetNetworkReportCatalogUseCase>(),
        createRun: Get.find<CreateNetworkReportRunUseCase>(),
        getRun: Get.find<GetNetworkReportRunUseCase>(),
        downloadArtifact: Get.find<DownloadReportArtifactUseCase>(),
      ),
    );
  }
}
