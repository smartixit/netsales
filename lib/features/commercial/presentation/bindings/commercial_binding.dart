import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
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
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_pos_details_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';

/// ربط التبعيات لميزة الكيانات والعلاقات التجارية
class CommercialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    registerLazyIfAbsent<CommercialRemoteDataSource>(
      () => const CommercialRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Repository
    registerLazyIfAbsent<CommercialRepository>(
      () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
      fenix: true,
    );

    // 3. Use Cases
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
    );
    registerLazyIfAbsent<GetPosNetworksListUseCase>(
      () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<CreateNetworkPosLinkUseCase>(
      () => CreateNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<ToggleNetworkPosLinkStatusUseCase>(
      () => ToggleNetworkPosLinkStatusUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<DeleteNetworkPosLinkUseCase>(
      () => DeleteNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<GetNetworkDetailsUseCase>(
      () => GetNetworkDetailsUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<GetPosDetailsUseCase>(() => GetPosDetailsUseCase(Get.find<CommercialRepository>()));
    registerLazyIfAbsent<UpdateNetworkDetailsUseCase>(
      () => UpdateNetworkDetailsUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<UpdatePosDetailsUseCase>(
      () => UpdatePosDetailsUseCase(Get.find<CommercialRepository>()),
    );
    registerLazyIfAbsent<CreateNetworkPosLinkChallengeUseCase>(
      () => CreateNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    registerLazyIfAbsent<PreviewNetworkPosLinkChallengeUseCase>(
      () => PreviewNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    registerLazyIfAbsent<ConfirmNetworkPosLinkChallengeUseCase>(
      () => ConfirmNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    registerLazyIfAbsent<RevokeNetworkPosLinkChallengeUseCase>(
      () => RevokeNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );

    // 4. Geography (المحافظات والمديريات)
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      registerLazyIfAbsent<AuthRemoteDataSource>(() => const AuthRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<AuthRepository>()) {
      registerLazyIfAbsent<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      );
    }
    if (!Get.isRegistered<GetGovernoratesUseCase>()) {
      registerLazyIfAbsent<GetGovernoratesUseCase>(() => GetGovernoratesUseCase(Get.find<AuthRepository>()));
    }
    if (!Get.isRegistered<GetDirectoratesUseCase>()) {
      registerLazyIfAbsent<GetDirectoratesUseCase>(() => GetDirectoratesUseCase(Get.find<AuthRepository>()));
    }

    // 5. Controller
    registerLazyIfAbsent<CommercialDirectoryController>(
      () => CommercialDirectoryController(
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        createNetworkPosLinkUseCase: Get.find<CreateNetworkPosLinkUseCase>(),
        toggleNetworkPosLinkStatusUseCase:
            Get.find<ToggleNetworkPosLinkStatusUseCase>(),
        deleteNetworkPosLinkUseCase: Get.find<DeleteNetworkPosLinkUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getNetworkDetailsUseCase: Get.find<GetNetworkDetailsUseCase>(),
        getPosDetailsUseCase: Get.find<GetPosDetailsUseCase>(),
        updateNetworkDetailsUseCase: Get.find<UpdateNetworkDetailsUseCase>(),
        updatePosDetailsUseCase: Get.find<UpdatePosDetailsUseCase>(),
        createNetworkPosLinkChallengeUseCase:
            Get.find<CreateNetworkPosLinkChallengeUseCase>(),
        previewNetworkPosLinkChallengeUseCase:
            Get.find<PreviewNetworkPosLinkChallengeUseCase>(),
        confirmNetworkPosLinkChallengeUseCase:
            Get.find<ConfirmNetworkPosLinkChallengeUseCase>(),
        revokeNetworkPosLinkChallengeUseCase:
            Get.find<RevokeNetworkPosLinkChallengeUseCase>(),
        getGovernoratesUseCase: Get.find<GetGovernoratesUseCase>(),
        getDirectoratesUseCase: Get.find<GetDirectoratesUseCase>(),
      ),
    );
  }
}
