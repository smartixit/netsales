import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:netsales/features/reports/data/datasources/reports_remote_data_source_impl.dart';
import 'package:netsales/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:netsales/features/reports/domain/repositories/reports_repository.dart';
import 'package:netsales/features/reports/domain/usecases/get_report_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/request_report_export_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/get_report_export_status_use_case.dart';
import 'package:netsales/features/reports/domain/usecases/download_report_export_use_case.dart';
import 'package:netsales/features/reports/presentation/controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsRemoteDataSource>(
      () => const ReportsRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetReportUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RequestReportExportUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetReportExportStatusUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DownloadReportExportUseCase(Get.find()), fenix: true);
    Get.lazyPut(
      () => ReportsController(
        Get.find(),
        Get.find<GetMyNetworksUseCase>(),
        Get.find<GetPosNetworksListUseCase>(),
      ),
      fenix: true,
    );
  }
}
