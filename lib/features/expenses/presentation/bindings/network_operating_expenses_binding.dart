import 'package:get/get.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';

class NetworkOperatingExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseRemoteDataSource>(
      () => const ExpenseRemoteDataSourceImpl(),
    );
    Get.lazyPut<ExpenseRepository>(
      () => ExpenseRepositoryImpl(
        remoteDataSource: Get.find<ExpenseRemoteDataSource>(),
      ),
    );
    Get.lazyPut(
      () => GetExpensesUseCase(Get.find<ExpenseRepository>()),
    );
    Get.lazyPut(
      () => NetworkOperatingExpensesController(
        getExpensesUseCase: Get.find<GetExpensesUseCase>(),
      ),
    );
  }
}
