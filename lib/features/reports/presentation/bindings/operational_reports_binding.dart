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
    if (!Get.isRegistered<GetOperationalReportCatalogUseCase>()) {
      Get.lazyPut<GetOperationalReportCatalogUseCase>(
        () => GetOperationalReportCatalogUseCase(
          Get.find<OperationalReportRepository>(),
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
    if (!Get.isRegistered<SaveOperationalReportSummaryPdfUseCase>()) {
      Get.lazyPut<SaveOperationalReportSummaryPdfUseCase>(
        () => SaveOperationalReportSummaryPdfUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SaveOperationalReportDetailedPdfUseCase>()) {
      Get.lazyPut<SaveOperationalReportDetailedPdfUseCase>(
        () => SaveOperationalReportDetailedPdfUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ShareOperationalReportSummaryPdfUseCase>()) {
      Get.lazyPut<ShareOperationalReportSummaryPdfUseCase>(
        () => ShareOperationalReportSummaryPdfUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PrintOperationalReportSummaryPdfUseCase>()) {
      Get.lazyPut<PrintOperationalReportSummaryPdfUseCase>(
        () => PrintOperationalReportSummaryPdfUseCase(
          Get.find<OperationalReportRepository>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetOperationalReportPresetsUseCase>()) {
      Get.lazyPut<GetOperationalReportPresetsUseCase>(() => GetOperationalReportPresetsUseCase(Get.find<OperationalReportRepository>()), fenix: true);
    }
    if (!Get.isRegistered<SaveOperationalReportPresetUseCase>()) {
      Get.lazyPut<SaveOperationalReportPresetUseCase>(() => SaveOperationalReportPresetUseCase(Get.find<OperationalReportRepository>()), fenix: true);
    }
    if (!Get.isRegistered<UpdateOperationalReportPresetUseCase>()) {
      Get.lazyPut<UpdateOperationalReportPresetUseCase>(() => UpdateOperationalReportPresetUseCase(Get.find<OperationalReportRepository>()), fenix: true);
    }
    if (!Get.isRegistered<DeleteOperationalReportPresetUseCase>()) {
      Get.lazyPut<DeleteOperationalReportPresetUseCase>(() => DeleteOperationalReportPresetUseCase(Get.find<OperationalReportRepository>()), fenix: true);
    }
    if (!Get.isRegistered<OperationalReportsController>()) {
      Get.lazyPut<OperationalReportsController>(
        () => OperationalReportsController(
          getReportCatalogUseCase: Get.find<GetOperationalReportCatalogUseCase>(),
          getReportUseCase: Get.find<GetOperationalReportUseCase>(),
          getSummaryUseCase: Get.find<GetOperationalReportSummaryUseCase>(),
          requestExportUseCase:
              Get.find<RequestOperationalReportExportUseCase>(),
          getExportStatusUseCase:
              Get.find<GetOperationalReportExportStatusUseCase>(),
          downloadExportUseCase:
              Get.find<DownloadOperationalReportExportUseCase>(),
          getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
          saveSummaryPdfUseCase:
              Get.find<SaveOperationalReportSummaryPdfUseCase>(),
          saveDetailedPdfUseCase:
              Get.find<SaveOperationalReportDetailedPdfUseCase>(),
          shareSummaryPdfUseCase:
              Get.find<ShareOperationalReportSummaryPdfUseCase>(),
          printSummaryPdfUseCase:
              Get.find<PrintOperationalReportSummaryPdfUseCase>(),
          getPresetsUseCase: Get.find<GetOperationalReportPresetsUseCase>(),
          savePresetUseCase: Get.find<SaveOperationalReportPresetUseCase>(),
          updatePresetUseCase: Get.find<UpdateOperationalReportPresetUseCase>(),
          deletePresetUseCase: Get.find<DeleteOperationalReportPresetUseCase>(),

        ),
      );
    }
  }
}
