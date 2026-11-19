import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_document_repository_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:netsales/features/expenses/data/services/expense_document_service.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_attachment_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_summary_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';

/// ربط اعتمادات ميزة المصروفات التشغيلية (Expense Binding)
class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources
    registerLazyIfAbsent<ExpenseRemoteDataSource>(
      () => const ExpenseRemoteDataSourceImpl(),
      fenix: true,
    );

    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      registerLazyIfAbsent<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      registerLazyIfAbsent<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      registerLazyIfAbsent<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    // 2. Repositories & Services
    registerLazyIfAbsent<ExpenseRepository>(
      () => ExpenseRepositoryImpl(Get.find<ExpenseRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<ExpenseDocumentService>(
      () => ExpenseDocumentService.instance,
      fenix: true,
    );

    registerLazyIfAbsent<ExpenseDocumentRepository>(
      () => const ExpenseDocumentRepositoryImpl(),
      fenix: true,
    );

    // 3. Use Cases
    registerLazyIfAbsent<GetExpensesUseCase>(
      () => GetExpensesUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetExpenseDetailsUseCase>(
      () => GetExpenseDetailsUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetExpenseSummaryUseCase>(
      () => GetExpenseSummaryUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<CreateExpenseUseCase>(
      () => CreateExpenseUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<UpdateExpenseUseCase>(
      () => UpdateExpenseUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<DeleteExpenseUseCase>(
      () => DeleteExpenseUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<DeleteExpenseAttachmentUseCase>(
      () => DeleteExpenseAttachmentUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<ExpenseDocumentUseCase>(
      () => ExpenseDocumentUseCase(Get.find<ExpenseDocumentRepository>()),
      fenix: true,
    );

    // 4. Controllers
    registerLazyIfAbsent<NetworkOperatingExpensesController>(
      () => NetworkOperatingExpensesController(
        getExpensesUseCase: Get.find<GetExpensesUseCase>(),
        getExpenseSummaryUseCase: Get.find<GetExpenseSummaryUseCase>(),
        deleteExpenseUseCase: Get.find<DeleteExpenseUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkExpenseDetailsController>(
      () => NetworkExpenseDetailsController(
        getExpenseDetailsUseCase: Get.find<GetExpenseDetailsUseCase>(),
        deleteExpenseUseCase: Get.find<DeleteExpenseUseCase>(),
        expenseDocumentUseCase: Get.find<ExpenseDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkExpenseFormController>(
      () => NetworkExpenseFormController(
        createExpenseUseCase: Get.find<CreateExpenseUseCase>(),
        updateExpenseUseCase: Get.find<UpdateExpenseUseCase>(),
        getExpenseDetailsUseCase: Get.find<GetExpenseDetailsUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
      fenix: true,
    );
  }
}
