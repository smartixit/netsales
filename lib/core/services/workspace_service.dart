import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/permission_service.dart';
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
    final savedWorkspace = _readSavedWorkspacePreference();
    final currentUser = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    if (currentUser == null) {
      currentWorkspace.value = savedWorkspace == AppWorkspace.pos.name
          ? AppWorkspace.pos
          : AppWorkspace.network;
    } else {
      try {
        currentWorkspace.value = resolveWorkspaceForUser(
          currentUser,
          preferredWorkspace: savedWorkspace,
        );
      } on StateError catch (error) {
        // No supported or unambiguous workspace must not block application
        // bootstrap. Protected workspace navigation still fails closed.
        log('ℹ️ [WorkspaceService] No workspace selected: $error');
      }
    }

    if (currentUser != null) bindDefaultActiveMembership(currentUser);

    log(
      '🏢 [WorkspaceService] Initialized with workspace: ${currentWorkspace.value.name}',
    );
    return this;
  }

  String? _readSavedWorkspacePreference() {
    try {
      return StorageService.instance.getString(StorageKeys.activeWorkspaceKey);
    } catch (_) {
      // Workspace-role resolution can run in isolated tests before storage
      // initialization; the backend primary role remains authoritative.
      return null;
    }
  }

  /// Resolves a supported workspace from exact backend role keys and scopes.
  ///
  /// A dual-scope user keeps a valid saved preference, then may use the exact
  /// primary role returned by the backend. No in-memory default is inferred.
  /// This never selects a Network or POS tenant; tenant selection is handled
  /// by the strict workspace-specific resolvers below.
  AppWorkspace resolveWorkspaceForUser(
    UserModel? user, {
    String? preferredWorkspace,
  }) {
    if (user == null) {
      throw StateError(
        'Cannot resolve a workspace without an authenticated user.',
      );
    }
    if (user.isPlatformUser) {
      throw StateError(
        'Platform identities cannot enter operational mobile workspaces.',
      );
    }

    final hasNetworkRole = _hasNetworkScope(user);
    final hasPosRole = _hasPosScope(user);

    if (!hasNetworkRole && !hasPosRole) {
      throw StateError(
        'The authenticated user has no supported Network or POS membership.',
      );
    }

    if (hasNetworkRole && hasPosRole) {
      final preferred = preferredWorkspace ?? _readSavedWorkspacePreference();

      if (preferred == AppWorkspace.network.name) return AppWorkspace.network;
      if (preferred == AppWorkspace.pos.name) return AppWorkspace.pos;

      // When no explicit workspace preference exists, use only the exact
      // primary role supplied by the authenticated backend response.
      // Never infer a default from the in-memory initial value.
      final primaryRoleKey = user.role?.roleKey ?? user.generalRoleKey;
      if (_networkRoleKeys.contains(primaryRoleKey)) {
        return AppWorkspace.network;
      }
      if (_posRoleKeys.contains(primaryRoleKey)) {
        return AppWorkspace.pos;
      }

      throw StateError(
        'A dual-scope account requires a saved workspace preference or an exact primary role.',
      );
    }

    return hasNetworkRole ? AppWorkspace.network : AppWorkspace.pos;
  }

  bool canSwitchWorkspace(UserModel? user) =>
      user != null &&
      !user.isPlatformUser &&
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

    final activePosMemberships = user.workspaceMemberships
        .where((membership) => membership.isPos && membership.tenantId > 0)
        .toList(growable: false);
    final savedPosId = storage.getInt(
      '${StorageKeys.activePosTenantPrefix}_${user.userId}',
    );
    if (savedPosId != null &&
        !activePosMemberships.any(
          (membership) => membership.tenantId == savedPosId,
        )) {
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
        !activeNetworkMemberships.any(
          (membership) => membership.tenantId == savedNetworkId,
        )) {
      await storage.remove(
        '${StorageKeys.activeNetworkTenantPrefix}_${user.userId}',
      );
      log(
        '🧹 [WorkspaceService] Inactive/removed Network membership context #$savedNetworkId purged.',
      );
    }

    AppWorkspace? resolvedWorkspace;
    try {
      resolvedWorkspace = resolveWorkspaceForUser(
        user,
        preferredWorkspace: _readSavedWorkspacePreference(),
      );
    } on StateError catch (error) {
      // Authentication and permission synchronization must not fail merely
      // because this account has no supported or unambiguous mobile workspace.
      // Do not invent a default; the workspace route guard remains fail-closed.
      log('ℹ️ [WorkspaceService] Skipping workspace selection: $error');
    }

    if (resolvedWorkspace != null) {
      await setActiveWorkspace(resolvedWorkspace);
      bindDefaultActiveMembership(user);
    } else {
      await storage.remove(StorageKeys.activeWorkspaceKey);
    }
  }

  void bindDefaultActiveMembership(UserModel user) {
    if (currentWorkspace.value == AppWorkspace.network) {
      final memberships = user.workspaceMemberships
          .where((item) => item.isNetwork && item.tenantId > 0)
          .toList(growable: false);
      final selectedId = savedActiveNetworkId;
      final selected = memberships.firstWhereOrNull(
            (item) => item.tenantId == selectedId,
          ) ??
          (memberships.isEmpty ? null : memberships.first);
      bindActiveMembership(RoleScope.network, selected?.tenantId);
      return;
    }

    final memberships = user.workspaceMemberships
        .where((item) => item.isPos && item.tenantId > 0)
        .toList(growable: false);
    final selectedId = savedActivePosId;
    final selected = memberships.firstWhereOrNull(
          (item) => item.tenantId == selectedId,
        ) ??
        (memberships.isEmpty ? null : memberships.first);
    bindActiveMembership(RoleScope.pos, selected?.tenantId);
  }

  /// Rebind UI permissions to the exact active tenant membership.
  /// Missing or inactive membership is represented by an empty permission set.
  void bindActiveMembership(RoleScope scope, int? tenantId) {
    final user = SessionService.to.currentUser;
    final membership = tenantId == null || tenantId <= 0
        ? null
        : user?.workspaceMemberships.firstWhereOrNull(
            (item) => item.scope == scope && item.tenantId == tenantId,
          );

    PermissionService.to.setWorkspaceContext(
      scope: scope,
      tenantId: membership?.tenantId ?? 0,
      roleKey: membership?.roleKey ?? '',
      permissions: membership?.permissions ?? const <String>[],
    );
  }

  Future<void> setActiveWorkspace(AppWorkspace workspace) async {
    final workspaceChanged = currentWorkspace.value != workspace;
    currentWorkspace.value = workspace;
    if (workspaceChanged) {
      bindActiveMembership(
        workspace == AppWorkspace.network ? RoleScope.network : RoleScope.pos,
        null,
      );
    }
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

  /// Restores a valid saved POS, otherwise selects the first authorized POS
  /// in the order returned by the server. An empty list remains unselected.
  int? resolveWorkspaceActivePosId(List<int> availablePosIds) =>
      _resolveSavedOrFirstTenant(availablePosIds, savedActivePosId);

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

  /// Restores a valid saved Network, otherwise selects the first authorized
  /// Network in the order returned by the server. An empty list stays null.
  int? resolveWorkspaceActiveNetworkId(List<int> availableNetworkIds) =>
      _resolveSavedOrFirstTenant(availableNetworkIds, savedActiveNetworkId);

  /// Shared tenant-selection policy: preserve a valid saved selection, and
  /// otherwise fall back to the first authorized item supplied by the server.
  int? resolveActivePosId(List<int> availablePosIds) =>
      _resolveSavedOrFirstTenant(availablePosIds, savedActivePosId);

  int? resolveActiveNetworkId(List<int> availableNetworkIds) =>
      _resolveSavedOrFirstTenant(availableNetworkIds, savedActiveNetworkId);

  int? _resolveSavedOrFirstTenant(
    List<int> availableTenantIds,
    int? savedTenantId,
  ) {
    if (savedTenantId != null && availableTenantIds.contains(savedTenantId)) {
      return savedTenantId;
    }
    return availableTenantIds.isEmpty ? null : availableTenantIds.first;
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
