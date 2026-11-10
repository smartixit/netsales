import 'package:get/get.dart';
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
    Get.lazyPut<CommercialRemoteDataSource>(
      () => const CommercialRemoteDataSourceImpl(),
    );

    // 2. Repository
    Get.lazyPut<CommercialRepository>(
      () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
    );

    // 3. Use Cases
    Get.lazyPut(() => GetMyNetworksUseCase(Get.find<CommercialRepository>()));
    Get.lazyPut(() => GetMyPosUseCase(Get.find<CommercialRepository>()));
    Get.lazyPut(() => GetMyNetworksUseCase(Get.find<CommercialRepository>()));
    Get.lazyPut(() => GetMyPosUseCase(Get.find<CommercialRepository>()));
    Get.lazyPut(
      () => GetNetworkPosListUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => CreateNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => ToggleNetworkPosLinkStatusUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => DeleteNetworkPosLinkUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => GetNetworkDetailsUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(() => GetPosDetailsUseCase(Get.find<CommercialRepository>()));
    Get.lazyPut(
      () => UpdateNetworkDetailsUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => UpdatePosDetailsUseCase(Get.find<CommercialRepository>()),
    );
    Get.lazyPut(
      () => CreateNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    Get.lazyPut(
      () => PreviewNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    Get.lazyPut(
      () => ConfirmNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );
    Get.lazyPut(
      () => RevokeNetworkPosLinkChallengeUseCase(
        Get.find<CommercialRepository>(),
      ),
    );

    // 4. Geography (المحافظات والمديريات)
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.lazyPut<AuthRemoteDataSource>(() => const AuthRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      );
    }
    if (!Get.isRegistered<GetGovernoratesUseCase>()) {
      Get.lazyPut(() => GetGovernoratesUseCase(Get.find<AuthRepository>()));
    }
    if (!Get.isRegistered<GetDirectoratesUseCase>()) {
      Get.lazyPut(() => GetDirectoratesUseCase(Get.find<AuthRepository>()));
    }

    // 5. Controller
    Get.lazyPut<CommercialDirectoryController>(
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
