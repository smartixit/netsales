import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_document_repository_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:netsales/features/expenses/data/services/expense_document_service.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_summary_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expenses_controller.dart';

/// رابط حقن الاعتماديات لدورة حياة المصروفات التشغيلية (ExpenseBinding)
///
/// يتبع أسلوب كتابة ProcurementRequestBinding الموحد باستخدام registerLazyIfAbsent:
/// يضمن تسجيل الاعتماديات مرة واحدة فقط مع fenix: true للبقاء حياً عبر التنقل بين الشاشات.
class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Sources & Services
    registerLazyIfAbsent<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<ExpenseDocumentService>(
      () => const ExpenseDocumentService(),
      fenix: true,
    );

    // 2. Repositories
    registerLazyIfAbsent<ExpenseRepository>(
      () => ExpenseRepositoryImpl(
        remoteDataSource: Get.find<ExpenseRemoteDataSource>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<ExpenseDocumentRepository>(
      () => ExpenseDocumentRepositoryImpl(
        documentService: Get.find<ExpenseDocumentService>(),
      ),
      fenix: true,
    );

    // 3. Use Cases
    registerLazyIfAbsent<GetExpensesUseCase>(
      () => GetExpensesUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetExpenseSummaryUseCase>(
      () => GetExpenseSummaryUseCase(Get.find<ExpenseRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetExpenseDetailsUseCase>(
      () => GetExpenseDetailsUseCase(Get.find<ExpenseRepository>()),
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
    registerLazyIfAbsent<ExpenseDocumentUseCase>(
      () => ExpenseDocumentUseCase(Get.find<ExpenseDocumentRepository>()),
      fenix: true,
    );

    // 4. Controllers
    registerLazyIfAbsent<NetworkExpensesController>(
      () => NetworkExpensesController(
        getExpensesUseCase: Get.find<GetExpensesUseCase>(),
        getExpenseSummaryUseCase: Get.find<GetExpenseSummaryUseCase>(),
        deleteExpenseUseCase: Get.find<DeleteExpenseUseCase>(),
        expenseDocumentUseCase: Get.find<ExpenseDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<ExpenseDetailsController>(
      () => ExpenseDetailsController(
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
      ),
      fenix: true,
    );
  }
}
