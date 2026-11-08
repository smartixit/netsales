import 'package:get/get.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source_impl.dart';
import 'package:netsales/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_use_cases.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';

class NetworkOperatingExpensesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      Get.lazyPut<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      Get.lazyPut<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    Get.lazyPut<ExpenseRemoteDataSource>(() => const ExpenseRemoteDataSourceImpl());
    Get.lazyPut<ExpenseRepository>(() => ExpenseRepositoryImpl(
      remoteDataSource: Get.find<ExpenseRemoteDataSource>(),
    ));
    Get.lazyPut(() => GetExpensesUseCase(Get.find<ExpenseRepository>()));
    Get.lazyPut(() => GetExpenseDetailsUseCase(Get.find<ExpenseRepository>()));
    Get.lazyPut(() => CreateExpenseUseCase(Get.find<ExpenseRepository>()));
    Get.lazyPut(() => UpdateExpenseUseCase(Get.find<ExpenseRepository>()));
    Get.lazyPut(() => DeleteExpenseAttachmentUseCase(Get.find<ExpenseRepository>()));
    Get.lazyPut(() => NetworkOperatingExpensesController(
      getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      getExpensesUseCase: Get.find<GetExpensesUseCase>(),
      getExpenseDetailsUseCase: Get.find<GetExpenseDetailsUseCase>(),
      createExpenseUseCase: Get.find<CreateExpenseUseCase>(),
      updateExpenseUseCase: Get.find<UpdateExpenseUseCase>(),
      deleteExpenseAttachmentUseCase: Get.find<DeleteExpenseAttachmentUseCase>(),
    ));
  }
}
