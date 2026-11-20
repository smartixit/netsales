import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
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

  test('restored local credentials are not marked server-verified', () async {
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

    await SessionService.instance.init();

    expect(SessionService.instance.isAuthenticated, isTrue);
    expect(SessionService.instance.isSessionVerified, isFalse);
    expect(SessionService.instance.currentSessionId, 'cached-session-id');
  });

  test('a 403 blocked state preserves the local session but blocks verification', () async {
    final user = UserModel.fromJson({
      'user_id': 72,
      'user_full_name': 'مستخدم محظور',
      'user_phone_number': '770000072',
      'workspace_roles': const <dynamic>[],
    });
    await SessionService.instance.startSession(
      user: user,
      session: const UserSessionModel(
        sessionId: 'blocked-session-id',
        userId: 72,
        deviceUuid: 'device-72',
      ),
      permissions: const <String>[],
    );

    SessionService.instance.markSessionAccessBlocked();

    expect(SessionService.instance.isAuthenticated, isTrue);
    expect(SessionService.instance.isSessionVerified, isFalse);
    expect(SessionService.instance.isAccessBlocked, isTrue);
    expect(StorageService.instance.sessionId, 'blocked-session-id');
  });
}
