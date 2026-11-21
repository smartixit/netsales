import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source_impl.dart';
import 'package:netsales/features/membership/data/repositories/membership_repository_impl.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';
import 'package:netsales/features/membership/domain/usecases/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/update_pos_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/network_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_memberships_controller.dart';

/// ربط التبعيات لدورة حياة إدارة أعضاء مساحات العمل
class MembershipBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source & Repository
    registerLazyIfAbsent<MembershipRemoteDataSource>(
      () => const MembershipRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<MembershipRepository>(
      () => MembershipRepositoryImpl(Get.find<MembershipRemoteDataSource>()),
      fenix: true,
    );

    // 2. حالات استخدام شبكة التزويد
    registerLazyIfAbsent<GetNetworkMembersUseCase>(
      () => GetNetworkMembersUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetNetworkAssignableRolesUseCase>(
      () => GetNetworkAssignableRolesUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<AddNetworkMemberUseCase>(
      () => AddNetworkMemberUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateNetworkMemberRoleUseCase>(
      () => UpdateNetworkMemberRoleUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateNetworkMemberStatusUseCase>(
      () => UpdateNetworkMemberStatusUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<RemoveNetworkMemberUseCase>(
      () => RemoveNetworkMemberUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );

    // 3. حالات استخدام نقطة البيع
    registerLazyIfAbsent<GetPosMembersUseCase>(
      () => GetPosMembersUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosAssignableRolesUseCase>(
      () => GetPosAssignableRolesUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<AddPosMemberUseCase>(
      () => AddPosMemberUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdatePosMemberRoleUseCase>(
      () => UpdatePosMemberRoleUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdatePosMemberStatusUseCase>(
      () => UpdatePosMemberStatusUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<RemovePosMemberUseCase>(
      () => RemovePosMemberUseCase(Get.find<MembershipRepository>()),
      fenix: true,
    );

    // 4. المتحكمات الملموسة
    registerLazyIfAbsent<NetworkMembershipsController>(
      () => NetworkMembershipsController(
        getNetworkMembersUseCase: Get.find<GetNetworkMembersUseCase>(),
        getNetworkAssignableRolesUseCase:
            Get.find<GetNetworkAssignableRolesUseCase>(),
        addNetworkMemberUseCase: Get.find<AddNetworkMemberUseCase>(),
        updateNetworkMemberRoleUseCase:
            Get.find<UpdateNetworkMemberRoleUseCase>(),
        updateNetworkMemberStatusUseCase:
            Get.find<UpdateNetworkMemberStatusUseCase>(),
        removeNetworkMemberUseCase: Get.find<RemoveNetworkMemberUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<PosMembershipsController>(
      () => PosMembershipsController(
        getPosMembersUseCase: Get.find<GetPosMembersUseCase>(),
        getPosAssignableRolesUseCase:
            Get.find<GetPosAssignableRolesUseCase>(),
        addPosMemberUseCase: Get.find<AddPosMemberUseCase>(),
        updatePosMemberRoleUseCase:
            Get.find<UpdatePosMemberRoleUseCase>(),
        updatePosMemberStatusUseCase:
            Get.find<UpdatePosMemberStatusUseCase>(),
        removePosMemberUseCase: Get.find<RemovePosMemberUseCase>(),
      ),
      fenix: true,
    );

    // 5. الاستراتيجية الافتراضية
    registerLazyIfAbsent<BaseMembershipsController>(
      () => Get.isRegistered<PosMembershipsController>()
          ? Get.find<PosMembershipsController>()
          : Get.find<NetworkMembershipsController>(),
      fenix: true,
    );
  }
}
