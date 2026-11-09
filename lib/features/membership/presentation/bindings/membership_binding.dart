import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source_impl.dart';
import 'package:netsales/features/membership/data/repositories/membership_repository_impl.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';
import 'package:netsales/features/membership/domain/usecases/membership_use_cases.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';

class MembershipBinding extends Bindings {
  MembershipBinding({required this.isNetwork});
  final bool isNetwork;
  @override
  void dependencies() {
    Get.lazyPut<MembershipRemoteDataSource>(
      () => const MembershipRemoteDataSourceImpl(),
    );
    Get.lazyPut<MembershipRepository>(
      () => MembershipRepositoryImpl(Get.find<MembershipRemoteDataSource>()),
    );
    final repository = Get.find<MembershipRepository>();
    Get.lazyPut(() => GetMembersUseCase(repository));
    Get.lazyPut(() => GetAssignableMembershipRolesUseCase(repository));
    Get.lazyPut(() => AddMembershipUseCase(repository));
    Get.lazyPut(() => UpdateMembershipRoleUseCase(repository));
    Get.lazyPut(() => UpdateMembershipStatusUseCase(repository));
    Get.lazyPut(() => RemoveMembershipUseCase(repository));
    Get.lazyPut(
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
    );
  }
}
