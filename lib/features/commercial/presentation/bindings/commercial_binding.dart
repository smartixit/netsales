import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_link_challenge_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/search_network_linkable_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_commercial_directory_controller.dart';

/// ربط التبعيات لدورة حياة دليل العلاقات التجارية والشركاء (Commercial Module Binding)
class CommercialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. مصدر البيانات والمستودع
    registerLazyIfAbsent<CommercialRemoteDataSource>(
      () => const CommercialRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<CommercialRepository>(
      () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
      fenix: true,
    );

    // 2. حالات الاستخدام (Use Cases)
    registerLazyIfAbsent<GetMyNetworksUseCase>(
      () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetMyPosUseCase>(
      () => GetMyPosUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkPosListUseCase>(
      () => GetNetworkPosListUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosNetworksListUseCase>(
      () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<CreateNetworkPosLinkUseCase>(
      () => CreateNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<ToggleNetworkPosLinkStatusUseCase>(
      () => ToggleNetworkPosLinkStatusUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<DeleteNetworkPosLinkUseCase>(
      () => DeleteNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<SearchNetworkLinkablePosUseCase>(
      () => SearchNetworkLinkablePosUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<CreateNetworkPosLinkChallengeUseCase>(
      () => CreateNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<PreviewNetworkPosLinkChallengeUseCase>(
      () => PreviewNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<ConfirmNetworkPosLinkChallengeUseCase>(
      () => ConfirmNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkPosLinkChallengeStatusUseCase>(
      () => GetNetworkPosLinkChallengeStatusUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<RevokeNetworkPosLinkChallengeUseCase>(
      () => RevokeNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkDetailsUseCase>(
      () => GetNetworkDetailsUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosDetailsUseCase>(
      () => GetPosDetailsUseCase(Get.find<CommercialRepository>()),
      fenix: true,
    );

    // 3. المتحكمات (Controllers)
    registerLazyIfAbsent<NetworkCommercialDirectoryController>(
      () => NetworkCommercialDirectoryController(
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        toggleNetworkPosLinkStatusUseCase:
            Get.find<ToggleNetworkPosLinkStatusUseCase>(),
        deleteNetworkPosLinkUseCase: Get.find<DeleteNetworkPosLinkUseCase>(),
        createNetworkPosLinkChallengeUseCase:
            Get.find<CreateNetworkPosLinkChallengeUseCase>(),
        searchNetworkLinkablePosUseCase:
            Get.find<SearchNetworkLinkablePosUseCase>(),
        revokeNetworkPosLinkChallengeUseCase:
            Get.find<RevokeNetworkPosLinkChallengeUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getNetworkPosLinkChallengeStatusUseCase:
            Get.find<GetNetworkPosLinkChallengeStatusUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<PosCommercialDirectoryController>(
      () => PosCommercialDirectoryController(
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        deleteNetworkPosLinkUseCase: Get.find<DeleteNetworkPosLinkUseCase>(),
        previewNetworkPosLinkChallengeUseCase:
            Get.find<PreviewNetworkPosLinkChallengeUseCase>(),
        confirmNetworkPosLinkChallengeUseCase:
            Get.find<ConfirmNetworkPosLinkChallengeUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
      ),
      fenix: true,
    );

    // تسجيل BaseCommercialDirectoryController وفق مساحة العمل أو المسار الحالي (Strategy Provider)
    registerLazyIfAbsent<BaseCommercialDirectoryController>(() {
      final currentRoute = Get.currentRoute;
      final isPos =
          currentRoute == AppRoutes.linkedNetworksCatalog ||
          (Get.isRegistered<WorkspaceService>() &&
              WorkspaceService.to.activeWorkspace == AppWorkspace.pos);

      if (isPos) {
        return Get.find<PosCommercialDirectoryController>();
      }
      return Get.find<NetworkCommercialDirectoryController>();
    }, fenix: true);
  }
}
