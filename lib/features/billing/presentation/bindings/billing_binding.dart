import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source_impl.dart';
import 'package:netsales/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';

/// Owns Billing feature dependencies while the workspace supplies active network scope.
class BillingBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<BillingRemoteDataSource>(
      () => const BillingRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<BillingRepository>(
      () => BillingRepositoryImpl(Get.find<BillingRemoteDataSource>()),
      fenix: true,
    );
    registerLazyIfAbsent<BillingUseCases>(
      () => BillingUseCases(Get.find<BillingRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<BillingReportsController>(
      () => BillingReportsController(
        useCases: Get.find<BillingUseCases>(),
        networkId: () =>
            Get.find<NetworkWorkspaceController>().selectedNetworkId.value,
        networkIdSignal:
            Get.find<NetworkWorkspaceController>().selectedNetworkId,
      ),
      fenix: true,
    );
    registerLazyIfAbsent<BillingController>(
      () => BillingController(
        useCases: Get.find<BillingUseCases>(),
        networkId: () =>
            Get.find<NetworkWorkspaceController>().selectedNetworkId.value,
        networkIdSignal:
            Get.find<NetworkWorkspaceController>().selectedNetworkId,
      ),
      fenix: true,
    );
  }
}
