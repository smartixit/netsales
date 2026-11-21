import 'dart:async';

import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';

/// Coordinates profile presentation and account-centre navigation.
class ProfileController extends GetxController {
  ProfileController({required this.getProfileUseCase});

  final GetProfileUseCase getProfileUseCase;

  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  int _loadRevision = 0;

  String get displayName {
    final name = profile.value?.fullName.trim() ??
        SessionService.to.currentUser?.userFullName.trim() ??
        '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(loadProfile());
  }

  Future<void> loadProfile() async {
    final revision = ++_loadRevision;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getProfileUseCase();
      if (revision != _loadRevision || isClosed) return;
      profile.value = result;
    } catch (error) {
      if (revision != _loadRevision || isClosed) return;
      errorMessage.value = AppException.sanitizeMessage(
        error,
        fallback: 'تعذر تحميل بيانات الحساب. حاول مرة أخرى.',
      );
    } finally {
      if (revision == _loadRevision && !isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> openMembership(ProfileMembershipEntity membership) async {
    if (membership.tenantId <= 0) return;

    final workspace = membership.scope == RoleScope.network
        ? AppWorkspace.network
        : membership.scope == RoleScope.pos
            ? AppWorkspace.pos
            : null;
    if (workspace == null) return;

    await WorkspaceService.to.setActiveWorkspace(workspace);
    await Get.offAllNamed<void>(
      workspace == AppWorkspace.network
          ? AppRoutes.networkWorkspace
          : AppRoutes.posWorkspace,
    );
  }

  Future<void> openSecuritySettings() =>
      Get.toNamed<void>(AppRoutes.securitySettings);

  Future<void> openActiveSessions() =>
      Get.toNamed<void>(AppRoutes.activeSessions);

  Future<void> openPasswordSettings() =>
      Get.toNamed<void>(AppRoutes.securitySettings);
}
