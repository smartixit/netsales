import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source.dart';
import 'package:netsales/features/membership/data/datasources/membership_remote_data_source_impl.dart';
import 'package:netsales/features/membership/data/repositories/membership_repository_impl.dart';
import 'package:netsales/features/membership/domain/repositories/membership_repository.dart';
import 'package:netsales/features/membership/domain/usecases/network/add_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/get_network_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/get_network_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/remove_network_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/update_network_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/network/update_network_member_status_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/add_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/get_pos_assignable_roles_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/get_pos_members_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/remove_pos_member_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/update_pos_member_role_use_case.dart';
import 'package:netsales/features/membership/domain/usecases/pos/update_pos_member_status_use_case.dart';
import 'package:netsales/features/membership/presentation/controllers/network_members_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_members_controller.dart';

/// نطاق حقن التبعيات النظيف لإدارة أعضاء مساحات العمل
class MembershipBinding extends Bindings {
  MembershipBinding();

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

    // ── حالات استخدام شبكة التزويد ──
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

    // ── حالات استخدام نقطة البيع ──
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

    // ── المتحكمات المستقلة ──
    registerLazyIfAbsent<NetworkMembersController>(
      () => NetworkMembersController(
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
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

    registerLazyIfAbsent<PosMembersController>(
      () => PosMembersController(
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
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
  }
}
