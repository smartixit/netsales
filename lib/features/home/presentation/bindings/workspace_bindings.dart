import 'package:get/get.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source_impl.dart';
import 'package:netsales/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';
import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/home/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/more/presentation/bindings/more_binding.dart';
import 'package:netsales/features/operations/domain/usecases/get_sales_trend_use_case.dart';
import 'package:netsales/features/operations/presentation/bindings/operations_binding.dart';
import 'package:netsales/features/packages/presentation/bindings/packages_binding.dart';
import 'package:netsales/features/partners/presentation/bindings/partners_binding.dart';

void _injectSharedDashboardDependencies() {
  if (!Get.isRegistered<DashboardRemoteDataSource>()) {
    Get.lazyPut<DashboardRemoteDataSource>(
      () => const DashboardRemoteDataSourceImpl(),
      fenix: true,
    );
  }
  if (!Get.isRegistered<DashboardRepository>()) {
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(Get.find<DashboardRemoteDataSource>()),
      fenix: true,
    );
  }
  if (!Get.isRegistered<GetDashboardOverviewUseCase>()) {
    Get.lazyPut<GetDashboardOverviewUseCase>(
      () => GetDashboardOverviewUseCase(Get.find<DashboardRepository>()),
      fenix: true,
    );
  }
  if (!Get.isRegistered<DashboardController>()) {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        getDashboardOverviewUseCase: Get.find<GetDashboardOverviewUseCase>(),
        getSalesTrendUseCase: Get.find<GetSalesTrendUseCase>(),
      ),
      fenix: true,
    );
  }

  OperationsBinding().dependencies();
  PackagesBinding().dependencies();
  PartnersBinding().dependencies();
  MoreBinding().dependencies();
}

/// ============================================================================
/// رابط حقن تبعيات مساحة عمل مزود الشبكة (NetworkWorkspaceBinding)
/// ============================================================================
class NetworkWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkWorkspaceController>(
      () => NetworkWorkspaceController(),
      fenix: true,
    );
    _injectSharedDashboardDependencies();
  }
}

/// ============================================================================
/// رابط حقن تبعيات مساحة عمل نقطة البيع والوكيل (PosWorkspaceBinding)
/// ============================================================================
class PosWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosWorkspaceController>(
      () => PosWorkspaceController(),
      fenix: true,
    );
    _injectSharedDashboardDependencies();
  }
}

