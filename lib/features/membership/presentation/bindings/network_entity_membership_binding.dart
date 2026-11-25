import 'package:get/get.dart';
import 'package:netsales/features/membership/domain/usecases/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/network_memberships_controller.dart';

class NetworkEntityMembershipBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null || id <= 0) return;
    final tag = 'network-members-$id';
    Get.lazyPut<NetworkMembershipsController>(
      () => NetworkMembershipsController(
        getNetworkMembersUseCase: Get.find<GetNetworkMembersUseCase>(),
        getNetworkAssignableRolesUseCase: Get.find<GetNetworkAssignableRolesUseCase>(),
        addNetworkMemberUseCase: Get.find<AddNetworkMemberUseCase>(),
        updateNetworkMemberRoleUseCase: Get.find<UpdateNetworkMemberRoleUseCase>(),
        updateNetworkMemberStatusUseCase: Get.find<UpdateNetworkMemberStatusUseCase>(),
        removeNetworkMemberUseCase: Get.find<RemoveNetworkMemberUseCase>(),
        initialNetworkId: id,
      ),
      tag: tag,
    );
    Get.lazyPut<BaseMembershipsController>(
      () => Get.find<NetworkMembershipsController>(tag: tag),
      tag: tag,
    );
  }
}
