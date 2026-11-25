import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/membership/domain/usecases/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_memberships_controller.dart';

import 'membership_use_cases_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PosMembershipsController controller;

  setUp(() {
    Get.reset();
    final repository = MockMembershipRepository();
    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    controller = PosMembershipsController(
      getPosMembersUseCase: GetPosMembersUseCase(repository),
      getPosAssignableRolesUseCase: GetPosAssignableRolesUseCase(repository),
      addPosMemberUseCase: AddPosMemberUseCase(repository),
      updatePosMemberRoleUseCase: UpdatePosMemberRoleUseCase(repository),
      updatePosMemberStatusUseCase: UpdatePosMemberStatusUseCase(repository),
      removePosMemberUseCase: RemovePosMemberUseCase(repository),
    );
  });

  tearDown(() {
    PermissionService.to.clear();
    Get.reset();
  });

  test('uses granular POS membership capabilities independently', () {
    PermissionService.to.setWorkspaceContext(
      scope: RoleScope.pos,
      tenantId: 12,
      roleKey: 'POS_AGENT',
      permissions: const [
        AppPermissions.posMembersView,
        AppPermissions.posMembersCreate,
        AppPermissions.posMembersChangeStatus,
      ],
    );

    expect(controller.canViewMembers, isTrue);
    expect(controller.canAddMember, isTrue);
    expect(controller.canChangeMemberRole, isFalse);
    expect(controller.canChangeMemberStatus, isTrue);
    expect(controller.canRemoveMember, isFalse);
  });
}
