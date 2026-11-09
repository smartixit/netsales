import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// ============================================================================
/// خدمة إدارة وتوجيه مساحات العمل التشغيلية (Workspace Routing & Resolution Service)
/// ============================================================================
/// تحدد مساحة العمل الفعالة للمستخدم (NETWORK أم POS) وتمنع وصول حسابات إدارة المنصة.
class WorkspaceService extends GetxService {
  WorkspaceService._();

  static WorkspaceService instance = WorkspaceService._();

  static WorkspaceService get to => Get.isRegistered<WorkspaceService>()
      ? Get.find<WorkspaceService>()
      : instance;

  final Rx<AppWorkspace> currentWorkspace = AppWorkspace.unsupported.obs;

  AppWorkspace get activeWorkspace => currentWorkspace.value;

  /// تهيئة الخدمة واستعادة آخر مساحة عمل تم حفظها للمستخدم
  Future<WorkspaceService> init() async {
    final storage = StorageService.instance;
    final savedWorkspace = storage.getString(StorageKeys.activeWorkspaceKey);

    final currentUser = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final resolved = resolveWorkspaceForUser(
      currentUser,
      preferredWorkspace: savedWorkspace,
    );

    if (savedWorkspace == 'pos' && resolved == AppWorkspace.pos) {
      currentWorkspace.value = AppWorkspace.pos;
    } else if (savedWorkspace == 'network' &&
        resolved == AppWorkspace.network) {
      currentWorkspace.value = AppWorkspace.network;
    } else {
      currentWorkspace.value = resolved;
    }

    log(
      '🏢 [WorkspaceService] Initialized with workspace: ${currentWorkspace.value.name}',
    );
    return this;
  }

  /// تحديد مساحة العمل تلقائياً بناءً على دور المستخدم وهويته
  AppWorkspace resolveWorkspaceForUser(
    UserModel? user, {
    String? preferredWorkspace,
  }) {
    if (user == null) {
      return AppWorkspace.unsupported;
    }

    final roleKey = user.role?.roleKey.toUpperCase() ?? '';
    final scopedRoleKeys = user.workspaceRoles.map((key) => key.toUpperCase()).toSet();
    final preferred = preferredWorkspace ??
        (currentWorkspace.value != AppWorkspace.unsupported
            ? currentWorkspace.value.name
            : StorageService.instance.getString(StorageKeys.activeWorkspaceKey));

    // 1. حسابات إدارة المنصة العامة مستبعدة كلياً ومحظورة على تطبيق الهاتف
    if (roleKey == AppRoles.superAdmin ||
        roleKey == AppRoles.supportAgent ||
        user.isSuperAdmin) {
      return AppWorkspace.unsupported;
    }

    // 2. Resolve operational workspaces from tenant-scoped memberships.
    final hasNetworkRole = scopedRoleKeys.any((key) =>
        key == AppRoles.networkOwner ||
        key == AppRoles.networkUser ||
        key == 'NETWORK_ACCOUNTANT');
    final hasPosRole = scopedRoleKeys.any((key) =>
        key == AppRoles.posAgent ||
        key == AppRoles.posUser ||
        key == 'POS_ACCOUNTANT');

    if (hasNetworkRole && hasPosRole) {
      if (preferred == 'pos') return AppWorkspace.pos;
      if (preferred == 'network') return AppWorkspace.network;
      return AppWorkspace.network;
    }
    if (hasNetworkRole || roleKey == AppRoles.networkOwner ||
        roleKey == AppRoles.networkUser || roleKey == 'NETWORK_ACCOUNTANT') {
      return AppWorkspace.network;
    }
    if (hasPosRole || roleKey == AppRoles.posAgent ||
        roleKey == AppRoles.posUser || roleKey == 'POS_ACCOUNTANT') {
      return AppWorkspace.pos;
    }

    // fallback: إذا احتوى اسم الدور أو وصفه على NETWORK أو POS
    if (roleKey.contains('NET') ||
        (user.role?.roleName.contains('شبك') ?? false)) {
      return AppWorkspace.network;
    }
    if (roleKey.contains('POS') ||
        (user.role?.roleName.contains('نقط') ?? false)) {
      return AppWorkspace.pos;
    }

    return AppWorkspace.unsupported;
  }

  /// تعيين وحفظ مساحة العمل النشطة
  Future<void> setActiveWorkspace(AppWorkspace workspace) async {
    currentWorkspace.value = workspace;
    await StorageService.instance.setString(
      StorageKeys.activeWorkspaceKey,
      workspace.name,
    );
    log('🏢 [WorkspaceService] Active workspace set to: ${workspace.name}');
  }

  /// المسار المستهدف عند توجيه مساحة العمل
  String get workspaceRoute {
    switch (currentWorkspace.value) {
      case AppWorkspace.network:
        return AppRoutes.networkWorkspace;
      case AppWorkspace.pos:
        return AppRoutes.posWorkspace;
      case AppWorkspace.unsupported:
        return AppRoutes.unsupportedPlatform;
    }
  }
}
