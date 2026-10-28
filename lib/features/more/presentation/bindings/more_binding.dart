import 'package:get/get.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source_impl.dart';
import 'package:netsales/features/more/data/repositories/more_repository_impl.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';
import 'package:netsales/features/more/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_bank_accounts_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_more_overview_use_case.dart';
import 'package:netsales/features/more/domain/usecases/get_user_sessions_use_case.dart';
import 'package:netsales/features/more/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/more/domain/usecases/terminate_session_use_case.dart';
import 'package:netsales/features/more/domain/usecases/toggle_bank_account_status_use_case.dart';
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

    Get.lazyPut<GetBankAccountsUseCase>(
      () => GetBankAccountsUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<ToggleBankAccountStatusUseCase>(
      () => ToggleBankAccountStatusUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetExpensesUseCase>(
      () => GetExpensesUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<CreateExpenseUseCase>(
      () => CreateExpenseUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetUserSessionsUseCase>(
      () => GetUserSessionsUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<TerminateSessionUseCase>(
      () => TerminateSessionUseCase(Get.find<MoreRepository>()),
      fenix: true,
    );

    Get.lazyPut<MoreController>(
      () => MoreController(
        getMoreOverviewUseCase: Get.find<GetMoreOverviewUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getBankAccountsUseCase: Get.find<GetBankAccountsUseCase>(),
        toggleBankAccountStatusUseCase: Get.find<ToggleBankAccountStatusUseCase>(),
        getExpensesUseCase: Get.find<GetExpensesUseCase>(),
        createExpenseUseCase: Get.find<CreateExpenseUseCase>(),
        getUserSessionsUseCase: Get.find<GetUserSessionsUseCase>(),
        terminateSessionUseCase: Get.find<TerminateSessionUseCase>(),
      ),
      fenix: true,
    );
  }
}
