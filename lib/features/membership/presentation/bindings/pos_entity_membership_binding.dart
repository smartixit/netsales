import 'package:get/get.dart';
import 'package:netsales/features/membership/domain/usecases/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_memberships_controller.dart';

class PosEntityMembershipBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null || id <= 0) return;
    final tag = 'pos-members-$id';
    Get.lazyPut<PosMembershipsController>(
      () => PosMembershipsController(
        getPosMembersUseCase: Get.find<GetPosMembersUseCase>(),
        getPosAssignableRolesUseCase: Get.find<GetPosAssignableRolesUseCase>(),
        addPosMemberUseCase: Get.find<AddPosMemberUseCase>(),
        updatePosMemberRoleUseCase: Get.find<UpdatePosMemberRoleUseCase>(),
        updatePosMemberStatusUseCase: Get.find<UpdatePosMemberStatusUseCase>(),
        removePosMemberUseCase: Get.find<RemovePosMemberUseCase>(),
        initialPosId: id,
      ),
      tag: tag,
    );
    Get.lazyPut<BaseMembershipsController>(
      () => Get.find<PosMembershipsController>(tag: tag),
      tag: tag,
    );
  }
}
