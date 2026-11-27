import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/user_sessions/data/datasources/user_sessions_remote_data_source.dart';
import 'package:netsales/features/user_sessions/data/datasources/user_sessions_remote_data_source_impl.dart';
import 'package:netsales/features/user_sessions/data/repositories/user_sessions_repository_impl.dart';
import 'package:netsales/features/user_sessions/domain/repositories/user_sessions_repository.dart';
import 'package:netsales/features/user_sessions/domain/usecases/get_user_sessions_use_case.dart';
import 'package:netsales/features/user_sessions/domain/usecases/terminate_user_session_use_case.dart';
import 'package:netsales/features/user_sessions/presentation/controllers/user_sessions_controller.dart';

/// ربط تبعيات وحدة جلسات تسجيل الدخول.
class UserSessionsBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<UserSessionsRemoteDataSource>(
      UserSessionsRemoteDataSourceImpl.new,
      fenix: true,
    );

    registerLazyIfAbsent<UserSessionsRepository>(
      () => UserSessionsRepositoryImpl(Get.find<UserSessionsRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetUserSessionsUseCase>(
      () => GetUserSessionsUseCase(Get.find<UserSessionsRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<TerminateUserSessionUseCase>(
      () => TerminateUserSessionUseCase(Get.find<UserSessionsRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<UserSessionsController>(
      () => UserSessionsController(
        getSessionsUseCase: Get.find<GetUserSessionsUseCase>(),
        terminateSessionUseCase: Get.find<TerminateUserSessionUseCase>(),
      ),
      fenix: true,
    );
  }
}
