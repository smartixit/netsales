import 'package:get/get.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source_impl.dart';
import 'package:netsales/features/more/data/repositories/more_repository_impl.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';
import 'package:netsales/features/more/domain/usecases/get_more_overview_use_case.dart';
import 'package:netsales/features/more/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';

/// ============================================================================
/// رابط حقن تبعيات قطاع المزيد (MoreBinding)
/// ============================================================================
/// يربط السلسلة المعمارية النظيفة:
/// DataSource -> Repository -> UseCases -> Controller.
class MoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreRemoteDataSource>(
      () => const MoreRemoteDataSourceImpl(),
      fenix: true,
    );

    Get.lazyPut<MoreRepository>(
      () => MoreRepositoryImpl(Get.find<MoreRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<GetMoreOverviewUseCase>(
      () => GetMoreOverviewUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<LogoutUseCase>(
      () => LogoutUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<MoreController>(
      () => MoreController(
        getMoreOverviewUseCase: Get.find<GetMoreOverviewUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
      ),
      fenix: true,
    );
  }
}
