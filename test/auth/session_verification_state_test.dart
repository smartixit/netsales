import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<SessionService>(SessionService.instance);
    await SessionService.instance.init();
    await WorkspaceService.instance.init();
  });

  tearDown(Get.reset);

  test('restored local credentials remain unverified until server validation', () async {
    final storage = StorageService.instance;
    final user = UserModel.fromJson({
      'user_id': 71,
      'user_full_name': 'مستخدم اختبار',
      'user_phone_number': '770000071',
      'workspace_roles': const <dynamic>[],
    });
    await storage.saveSession('cached-session-id');
    await storage.setModel(StorageKeys.userData, user, (value) => value.toJson());
    await storage.setStringList(StorageKeys.permissionsStorage, const <String>[]);

    final savedPosKey = '${StorageKeys.activePosTenantPrefix}_71';
    final savedPosNetworkKey = '${StorageKeys.activePosNetworkPrefix}_71_701';
    final savedNetworkKey = '${StorageKeys.activeNetworkTenantPrefix}_71';
    await storage.setInt(savedPosKey, 701);
    await storage.setInt(savedPosNetworkKey, 801);
    await storage.setInt(savedNetworkKey, 702);

    await SessionService.instance.init();

    expect(SessionService.instance.isAuthenticated, isTrue);
    expect(SessionService.instance.isSessionVerified, isFalse);
    expect(SessionService.instance.currentSessionId, 'cached-session-id');
    expect(storage.getInt(savedPosKey), 701);
    expect(storage.getInt(savedPosNetworkKey), 801);
    expect(storage.getInt(savedNetworkKey), 702);

    await SessionService.instance.syncSessionProfile(user: user, permissions: const <String>[]);
    expect(storage.getInt(savedPosKey), isNull);
    expect(storage.getInt(savedPosNetworkKey), isNull);
    expect(storage.getInt(savedNetworkKey), isNull);
  });

  test('403 blocked state preserves session and keeps the current device identity in memory', () async {
    final user = UserModel.fromJson({
      'user_id': 72,
      'user_full_name': 'مستخدم محظور',
      'user_phone_number': '770000072',
      'workspace_roles': const <dynamic>[],
    });
    await SessionService.instance.startSession(
      user: user,
      session: UserSessionModel(
        sessionId: 'blocked-session-id',
        userId: 72,
        deviceUuid: DeviceService.instance.deviceUuid,
      ),
      permissions: const <String>[],
    );
    SessionService.instance.markSessionAccessBlocked();

    expect(SessionService.instance.isAuthenticated, isTrue);
    expect(SessionService.instance.isSessionVerified, isFalse);
    expect(SessionService.instance.isAccessBlocked, isTrue);
    expect(StorageService.instance.sessionId, 'blocked-session-id');
    expect(
      SessionService.instance.currentSession?.deviceUuid,
      DeviceService.instance.deviceUuid,
    );
  });
}
