import 'package:get/get.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source_impl.dart';
import 'package:netsales/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';
import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/features/operations/presentation/bindings/operations_binding.dart';
import 'package:netsales/features/partners/presentation/bindings/partners_binding.dart';

/// ============================================================================
/// رابط حقن تبعيات الشاشة الرئيسية (HomeLayoutBinding)
/// ============================================================================
/// يسجل كائنات الشاشة الرئيسية ولوحة القيادة وفق سريان الاعتمادية النظيف:
/// DataSource -> Repository -> UseCase -> Controller.
class HomeLayoutBinding extends Bindings {
  @override
  void dependencies() {
    // المتحكم الرئيسي للتنقل والتخطيط
    Get.lazyPut<HomeLayoutController>(
      () => HomeLayoutController(),
      fenix: true,
    );

    // سلسلة تبعيات لوحة القيادة التجميعية (Dashboard Vertical Slice)
    Get.lazyPut<DashboardRemoteDataSource>(
      () => const DashboardRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(Get.find<DashboardRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<GetDashboardOverviewUseCase>(
      () => GetDashboardOverviewUseCase(Get.find<DashboardRepository>()),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        getDashboardOverviewUseCase: Get.find<GetDashboardOverviewUseCase>(),
      ),
      fenix: true,
    );

    // Operations Vertical Slice
    OperationsBinding().dependencies();

    // Partners & Distribution Network Vertical Slice
    PartnersBinding().dependencies();
  }
}

