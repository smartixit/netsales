/// Local storage keys.
abstract final class StorageKeys {
  StorageKeys._();
  static const String session = 'session_id';
  static const String activeDeviceUuid = 'active_device_uuid';

  /// Browser-installation identity for Web only. Native identity is read from
  /// the platform on each initialization and is never persisted separately.
  static const String webDeviceUuid = 'web_device_uuid';
  static const String userId = 'user_id';
  static const String permissionsStorage = 'user_permissions';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String serverBoxPublicKey = 'server_box_public_key';
  static const String serverSignPublicKey = 'server_sign_public_key';
  static const String fcmTokenStorage = 'fcm_token_storage';
  static const String publicSettings = 'public_settings_cache';
  static const String activeWorkspaceKey = 'active_workspace_key';
  static const String activePosTenantPrefix = 'active_pos_tenant';
  static const String activeNetworkTenantPrefix = 'active_network_tenant';
  static const String activePosNetworkPrefix = 'active_pos_network';
  static const String lastServerCatchupRun = 'last_server_catchup_run_ms';
  static const String serverCatchupFailuresCount =
      'server_catchup_failures_count';
}
