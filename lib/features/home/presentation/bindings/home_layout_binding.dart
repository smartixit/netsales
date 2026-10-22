import 'package:get/get.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source_impl.dart';
import 'package:netsales/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';
import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';

/// ============================================================================
/// رابط حقن تبعيات الشاشة الرئيسية (HomeLayoutBinding)
/// ============================================================================
/// يسجل كائنات الشاشة الرئيسية ولوحة القيادة وفق سريان الاعتمادية النظيف:
/// DataSource -> Repository -> UseCase -> Controller.
class HomeLayoutBinding extends Bindings {
  @override
  void dependencies() {
    // المتحكم الرئيسي للتنقل والتخطيط
    Get.lazyPut<HomeLayoutController>(() => HomeLayoutController());

    // سلسلة تبعيات لوحة القيادة التجميعية (Dashboard Vertical Slice)
    Get.lazyPut<DashboardRemoteDataSource>(
      () => const DashboardRemoteDataSourceImpl(),
    );
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(Get.find<DashboardRemoteDataSource>()),
    );
    Get.lazyPut<GetDashboardOverviewUseCase>(
      () => GetDashboardOverviewUseCase(Get.find<DashboardRepository>()),
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        getDashboardOverviewUseCase: Get.find<GetDashboardOverviewUseCase>(),
      ),
    );
  }
}
