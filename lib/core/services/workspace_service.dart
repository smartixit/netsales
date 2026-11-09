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
/// تحدد مساحة العمل الفعالة للمستخدم (NETWORK أم POS) بناءً على عضوياته النشطة،
/// وتمنع وصول حسابات إدارة المنصة.
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

  /// تحديد مساحة العمل تلقائياً وبشكل حتمي بناءً على عضويات المستخدم وهويته
  AppWorkspace resolveWorkspaceForUser(
    UserModel? user, {
    String? preferredWorkspace,
  }) {
    if (user == null) {
      return AppWorkspace.unsupported;
    }

    // 1. حسابات إدارة المنصة العامة مستبعدة كلياً ومحظورة على تطبيق الهاتف
    if (user.isSuperAdmin ||
        user.role?.roleKey == AppRoles.superAdmin ||
        user.role?.roleKey == AppRoles.supportAgent) {
      return AppWorkspace.unsupported;
    }

    final preferred =
        preferredWorkspace ??
        (currentWorkspace.value != AppWorkspace.unsupported
            ? currentWorkspace.value.name
            : StorageService.instance.getString(
                StorageKeys.activeWorkspaceKey,
              ));

    // 2. فحص العضويات التشغيلية عبر WorkspaceMembershipModel أولاً
    final hasNetworkRole =
        user.hasNetworkMembership ||
        user.role?.roleKey == AppRoles.networkOwner ||
        user.role?.roleKey == AppRoles.networkUser ||
        user.role?.roleKey == AppRoles.networkAccountant;

    final hasPosRole =
        user.hasPosMembership ||
        user.role?.roleKey == AppRoles.posAgent ||
        user.role?.roleKey == AppRoles.posUser ||
        user.role?.roleKey == AppRoles.posAccountant;

    // الحالة 3: يملك كلا النطاقين -> احترام التفضيل السابق إذا كان لا يزال سارياً
    if (hasNetworkRole && hasPosRole) {
      if (preferred == 'pos') return AppWorkspace.pos;
      if (preferred == 'network') return AppWorkspace.network;
      return AppWorkspace.network;
    }

    // الحالة 1: عضوية شبكة فقط
    if (hasNetworkRole) {
      return AppWorkspace.network;
    }

    // الحالة 2: عضوية نقطة بيع فقط
    if (hasPosRole) {
      return AppWorkspace.pos;
    }

    // Fallback آمن إن تطابق مفتاح الدور
    final roleKey = user.role?.roleKey.toUpperCase() ?? '';
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

  /// مزامنة سياق مساحة العمل والمستأجر مع عضويات المستخدم النشطة
  Future<void> syncWithUserMemberships(UserModel? user) async {
    if (user == null) {
      await setActiveWorkspace(AppWorkspace.unsupported);
      return;
    }

    final storage = StorageService.instance;
    final savedWorkspace = storage.getString(StorageKeys.activeWorkspaceKey);
    final resolved = resolveWorkspaceForUser(
      user,
      preferredWorkspace: savedWorkspace,
    );

    // الحالة 5: التحقق من سريان العضوية السابقة لنقاط البيع ومسح السياق الملغى
    final activePosMemberships = user.workspaceMemberships
        .where((m) => m.isPos)
        .toList();
    final savedPosId = storage.getInt(
      '${StorageKeys.activePosTenantPrefix}_${user.userId}',
    );
    if (savedPosId != null &&
        !activePosMemberships.any((m) => m.tenantId == savedPosId)) {
      await storage.remove(
        '${StorageKeys.activePosTenantPrefix}_${user.userId}',
      );
      await storage.remove(
        '${StorageKeys.activePosNetworkPrefix}_${user.userId}_$savedPosId',
      );
      log(
        '🧹 [WorkspaceService] Inactive/removed POS membership context #$savedPosId purged.',
      );
    }

    await setActiveWorkspace(resolved);
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

  /// مفتاح التخزين الموحد لنقطة البيع النشطة للمستخدم الحالي
  String get activePosStorageKey =>
      '${StorageKeys.activePosTenantPrefix}_${SessionService.to.currentUser?.userId ?? 0}';

  /// قراءة معرف نقطة البيع النشطة المحفوظة بأمان
  int? get savedActivePosId {
    try {
      return StorageService.instance.getInt(activePosStorageKey);
    } catch (_) {
      return null;
    }
  }

  /// حفظ معرف نقطة البيع النشطة بأمان
  Future<void> saveActivePosId(int posId) async {
    try {
      await StorageService.instance.setInt(activePosStorageKey, posId);
    } catch (_) {}
  }

  /// مسح معرف نقطة البيع النشطة بأمان
  Future<void> clearActivePosId() async {
    try {
      await StorageService.instance.remove(activePosStorageKey);
    } catch (_) {}
  }

  /// تحديد معرف نقطة البيع النشطة حتمياً دون اعتماد على first أو ترتيب الاستجابة:
  /// 1. نقطة بيع واحدة فقط -> اختيار تلقائي.
  /// 2. عدة نقاط بيع -> استعادة المعرف المحفوظ إن كان موجوداً ضمن القائمة المصرح بها.
  /// 3. عدة نقاط بيع دون اختيار محفوظ صالح -> إرجاع null لإلزام المستخدم بالاختيار الصريح.
  int? resolveActivePosId(List<int> availablePosIds) {
    if (availablePosIds.isEmpty) return null;

    final savedId = savedActivePosId;
    if (savedId != null && availablePosIds.contains(savedId)) {
      return savedId;
    }

    if (availablePosIds.length == 1) {
      return availablePosIds.first;
    }

    // لا يتم اختيار first أبداً عند تعدد نقاط البيع دون اختيار محفوظ
    return null;
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
