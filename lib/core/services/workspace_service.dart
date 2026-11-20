import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// The single runtime authority for the currently selected workspace.
///
/// Workspace selection is a navigation preference only. Tenant identifiers
/// are resolved independently against server-returned authorized entities.
class WorkspaceService extends GetxService {
  WorkspaceService._();

  static WorkspaceService instance = WorkspaceService._();

  static WorkspaceService get to => Get.isRegistered<WorkspaceService>()
      ? Get.find<WorkspaceService>()
      : instance;

  static const Set<String> _networkRoleKeys = {
    AppRoles.networkOwner,
    AppRoles.networkUser,
    AppRoles.networkAccountant,
  };

  static const Set<String> _posRoleKeys = {
    AppRoles.posAgent,
    AppRoles.posUser,
    AppRoles.posAccountant,
  };

  final Rx<AppWorkspace> currentWorkspace = AppWorkspace.network.obs;

  AppWorkspace get activeWorkspace => currentWorkspace.value;

  Future<WorkspaceService> init() async {
    final savedWorkspace = StorageService.instance.getString(
      StorageKeys.activeWorkspaceKey,
    );
    final currentUser = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final resolved = resolveWorkspaceForUser(
      currentUser,
      preferredWorkspace: savedWorkspace,
    );
    currentWorkspace.value = resolved;

    log(
      '🏢 [WorkspaceService] Initialized with workspace: ${resolved.name}',
    );
    return this;
  }

  /// Resolves a supported workspace from exact backend role keys and scopes.
  ///
  /// A dual-scope user keeps a valid saved/current workspace preference. This
  /// never selects a Network or POS tenant; tenant selection is handled by the
  /// strict workspace-specific resolvers below.
  AppWorkspace resolveWorkspaceForUser(
    UserModel? user, {
    String? preferredWorkspace,
  }) {
    if (user == null) return currentWorkspace.value;

    final hasNetworkRole = _hasNetworkScope(user);
    final hasPosRole = _hasPosScope(user);

    if (!hasNetworkRole && !hasPosRole) {
      throw StateError(
        'The authenticated user has no supported Network or POS membership.',
      );
    }

    if (hasNetworkRole && hasPosRole) {
      final preferred = preferredWorkspace ??
          StorageService.instance.getString(StorageKeys.activeWorkspaceKey);

      if (preferred == AppWorkspace.network.name) return AppWorkspace.network;
      if (preferred == AppWorkspace.pos.name) return AppWorkspace.pos;

      // The currently active workspace is a valid UX preference for a user
      // authorized for both scopes; it is not a tenant/entity selection.
      return currentWorkspace.value;
    }

    return hasNetworkRole ? AppWorkspace.network : AppWorkspace.pos;
  }

  bool canSwitchWorkspace(UserModel? user) =>
      user != null &&
      !user.isSuperAdmin &&
      _hasNetworkScope(user) &&
      _hasPosScope(user);

  bool _hasNetworkScope(UserModel user) {
    final hasScopedMembership = user.workspaceMemberships.any(
      (membership) =>
          membership.scope == RoleScope.network &&
          membership.tenantId > 0 &&
          _networkRoleKeys.contains(membership.roleKey),
    );
    final topLevelRole = user.role?.roleKey ?? user.generalRoleKey;
    return hasScopedMembership || _networkRoleKeys.contains(topLevelRole);
  }

  bool _hasPosScope(UserModel user) {
    final hasScopedMembership = user.workspaceMemberships.any(
      (membership) =>
          membership.scope == RoleScope.pos &&
          membership.tenantId > 0 &&
          _posRoleKeys.contains(membership.roleKey),
    );
    final topLevelRole = user.role?.roleKey ?? user.generalRoleKey;
    return hasScopedMembership || _posRoleKeys.contains(topLevelRole);
  }

  Future<void> syncWithUserMemberships(UserModel? user) async {
    if (user == null) {
      return;
    }

    final storage = StorageService.instance;
    final savedWorkspace = storage.getString(StorageKeys.activeWorkspaceKey);
    final resolved = resolveWorkspaceForUser(
      user,
      preferredWorkspace: savedWorkspace,
    );

    final activePosMemberships = user.workspaceMemberships
        .where((membership) => membership.isPos && membership.tenantId > 0)
        .toList(growable: false);
    final savedPosId = storage.getInt(
      '${StorageKeys.activePosTenantPrefix}_${user.userId}',
    );
    if (savedPosId != null &&
        !activePosMemberships.any((membership) => membership.tenantId == savedPosId)) {
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

    final activeNetworkMemberships = user.workspaceMemberships
        .where((membership) => membership.isNetwork && membership.tenantId > 0)
        .toList(growable: false);
    final savedNetworkId = storage.getInt(
      '${StorageKeys.activeNetworkTenantPrefix}_${user.userId}',
    );
    if (savedNetworkId != null &&
        !activeNetworkMemberships.any((membership) => membership.tenantId == savedNetworkId)) {
      await storage.remove(
        '${StorageKeys.activeNetworkTenantPrefix}_${user.userId}',
      );
      log(
        '🧹 [WorkspaceService] Inactive/removed Network membership context #$savedNetworkId purged.',
      );
    }

    await setActiveWorkspace(resolved);
  }

  Future<void> setActiveWorkspace(AppWorkspace workspace) async {
    currentWorkspace.value = workspace;
    await StorageService.instance.setString(
      StorageKeys.activeWorkspaceKey,
      workspace.name,
    );
    log('🏢 [WorkspaceService] Active workspace set to: ${workspace.name}');
  }

  String get activePosStorageKey =>
      '${StorageKeys.activePosTenantPrefix}_${SessionService.to.currentUser?.userId ?? 0}';

  int? get savedActivePosId {
    try {
      return StorageService.instance.getInt(activePosStorageKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActivePosId(int posId) async {
    try {
      await StorageService.instance.setInt(activePosStorageKey, posId);
    } catch (_) {}
  }

  Future<void> clearActivePosId() async {
    try {
      await StorageService.instance.remove(activePosStorageKey);
    } catch (_) {}
  }

  /// Workspace-only resolution: restore a valid saved tenant, or select the
  /// sole authorized tenant. Multiple candidates require explicit user choice.
  int? resolveWorkspaceActivePosId(List<int> availablePosIds) {
    final savedId = savedActivePosId;
    if (savedId != null && availablePosIds.contains(savedId)) return savedId;
    if (availablePosIds.length == 1) return availablePosIds.single;
    return null;
  }

  String get activeNetworkStorageKey =>
      '${StorageKeys.activeNetworkTenantPrefix}_${SessionService.to.currentUser?.userId ?? 0}';

  int? get savedActiveNetworkId {
    try {
      return StorageService.instance.getInt(activeNetworkStorageKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveNetworkId(int networkId) async {
    try {
      await StorageService.instance.setInt(activeNetworkStorageKey, networkId);
    } catch (_) {}
  }

  Future<void> clearActiveNetworkId() async {
    try {
      await StorageService.instance.remove(activeNetworkStorageKey);
    } catch (_) {}
  }

  /// Workspace-only resolution: restore a valid saved tenant, or select the
  /// sole authorized tenant. Multiple candidates require explicit user choice.
  int? resolveWorkspaceActiveNetworkId(List<int> availableNetworkIds) {
    final savedId = savedActiveNetworkId;
    if (savedId != null && availableNetworkIds.contains(savedId)) return savedId;
    if (availableNetworkIds.length == 1) return availableNetworkIds.single;
    return null;
  }

  /// Legacy resolver retained for other features; Workspace controllers must
  /// use the strict resolvers above and must never select the first tenant.
  int? resolveActivePosId(List<int> availablePosIds) {
    if (availablePosIds.isEmpty) return null;
    final savedId = savedActivePosId;
    if (savedId != null && availablePosIds.contains(savedId)) return savedId;
    return availablePosIds.first;
  }

  /// Legacy resolver retained for other features; Workspace controllers must
  /// use the strict resolvers above and must never select the first tenant.
  int? resolveActiveNetworkId(List<int> availableNetworkIds) {
    if (availableNetworkIds.isEmpty) return null;
    final savedId = savedActiveNetworkId;
    if (savedId != null && availableNetworkIds.contains(savedId)) return savedId;
    return availableNetworkIds.first;
  }

  String get workspaceRoute {
    switch (currentWorkspace.value) {
      case AppWorkspace.network:
        return AppRoutes.networkWorkspace;
      case AppWorkspace.pos:
        return AppRoutes.posWorkspace;
    }
  }
}
