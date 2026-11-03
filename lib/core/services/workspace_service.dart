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

    final resolved = resolveWorkspaceForUser(currentUser);

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
  AppWorkspace resolveWorkspaceForUser(UserModel? user) {
    if (user == null) {
      return AppWorkspace.unsupported;
    }

    final roleKey = user.role?.roleKey.toUpperCase() ?? '';

    // 1. حسابات إدارة المنصة العامة مستبعدة كلياً ومحظورة على تطبيق الهاتف
    if (roleKey == AppRoles.superAdmin ||
        roleKey == AppRoles.supportAgent ||
        user.isSuperAdmin) {
      return AppWorkspace.unsupported;
    }

    // 2. أدوار مساحة عمل مزود الشبكة (NETWORK)
    if (roleKey == AppRoles.networkOwner ||
        roleKey == AppRoles.networkUser ||
        roleKey == 'NETWORK_ACCOUNTANT' ||
        user.isNetworkOwner) {
      return AppWorkspace.network;
    }

    // 3. أدوار مساحة عمل نقطة البيع والوكيل (POS)
    if (roleKey == AppRoles.posAgent ||
        roleKey == AppRoles.posUser ||
        roleKey == 'POS_ACCOUNTANT' ||
        user.isPosAgent) {
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
