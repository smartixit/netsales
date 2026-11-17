import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source_impl.dart';
import 'package:netsales/features/membership/data/repositories/membership_repository_impl.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';
import 'package:netsales/features/membership/domain/usecases/membership_use_cases.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';

/// Dependency scope for membership screens embedded in each workspace.
class MembershipBinding extends Bindings {
  MembershipBinding({required this.isNetwork});

  final bool isNetwork;

  static const networkTag = 'membership-network-workspace';
  static const posTag = 'membership-pos-workspace';

  String get controllerTag => isNetwork ? networkTag : posTag;

  @override
  void dependencies() {
    registerLazyIfAbsent<MembershipRemoteDataSource>(
      () => const MembershipRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<MembershipRepository>(
      () => MembershipRepositoryImpl(Get.find<MembershipRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetMembersUseCase>(
      () => GetMembersUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetAssignableMembershipRolesUseCase>(
      () =>
          GetAssignableMembershipRolesUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<AddMembershipUseCase>(
      () => AddMembershipUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateMembershipRoleUseCase>(
      () => UpdateMembershipRoleUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateMembershipStatusUseCase>(
      () => UpdateMembershipStatusUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<RemoveMembershipUseCase>(
      () => RemoveMembershipUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<MembershipController>(
      () => MembershipController(
        isNetwork: isNetwork,
        getMyNetworks: Get.find<GetMyNetworksUseCase>(),
        getMyPos: Get.find<GetMyPosUseCase>(),
        getMembers: Get.find<GetMembersUseCase>(),
        getRoles: Get.find<GetAssignableMembershipRolesUseCase>(),
        addMember: Get.find<AddMembershipUseCase>(),
        updateRole: Get.find<UpdateMembershipRoleUseCase>(),
        updateStatus: Get.find<UpdateMembershipStatusUseCase>(),
        removeMember: Get.find<RemoveMembershipUseCase>(),
      ),
      tag: controllerTag,
      fenix: true,
    );
  }
}
