import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/reports/data/datasources/operational_report_remote_data_source.dart';
import 'package:netsales/features/reports/data/datasources/operational_report_remote_data_source_impl.dart';
import 'package:netsales/features/reports/data/repositories/operational_report_repository_impl.dart';
import 'package:netsales/features/reports/domain/repositories/operational_report_repository.dart';
import 'package:netsales/features/reports/domain/usecases/operational_report_use_cases.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';

class OperationalReportsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OperationalReportRemoteDataSource>()) {
      Get.lazyPut<OperationalReportRemoteDataSource>(
        () => const OperationalReportRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OperationalReportRepository>()) {
      Get.lazyPut<OperationalReportRepository>(
        () => OperationalReportRepositoryImpl(
          Get.find<OperationalReportRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOperationalReportUseCase>()) {
      Get.lazyPut<GetOperationalReportUseCase>(
        () => GetOperationalReportUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOperationalReportSummaryUseCase>()) {
      Get.lazyPut<GetOperationalReportSummaryUseCase>(
        () => GetOperationalReportSummaryUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RequestOperationalReportExportUseCase>()) {
      Get.lazyPut<RequestOperationalReportExportUseCase>(
        () => RequestOperationalReportExportUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOperationalReportExportStatusUseCase>()) {
      Get.lazyPut<GetOperationalReportExportStatusUseCase>(
        () => GetOperationalReportExportStatusUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DownloadOperationalReportExportUseCase>()) {
      Get.lazyPut<DownloadOperationalReportExportUseCase>(
        () => DownloadOperationalReportExportUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<OperationalReportsController>()) {
      Get.lazyPut<OperationalReportsController>(
        () => OperationalReportsController(
          getReportUseCase: Get.find<GetOperationalReportUseCase>(),
          getSummaryUseCase: Get.find<GetOperationalReportSummaryUseCase>(),
          requestExportUseCase:
              Get.find<RequestOperationalReportExportUseCase>(),
          getExportStatusUseCase:
              Get.find<GetOperationalReportExportStatusUseCase>(),
          downloadExportUseCase:
              Get.find<DownloadOperationalReportExportUseCase>(),
          getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        ),
      );
    }
  }
}
