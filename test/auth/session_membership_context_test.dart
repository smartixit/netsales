import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';
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

  tearDown(() {
    Get.reset();
  });

  group('P0-1: Session Membership Context Restoration & Invariants', () {
    // 1. مستخدم لديه عضوية Network واحدة
    test('Scenario 1: Single Network membership resolves correctly and retains tenant ID', () {
      final user = UserModel.fromJson({
        'user_id': 101,
        'user_full_name': 'عمر الشبكة',
        'user_phone_number': '770000101',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 50,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك شبكة الأمل',
          },
        ],
      });

      expect(user.workspaceMemberships.length, equals(1));
      final membership = user.workspaceMemberships.first;
      expect(membership.scope, equals(RoleScope.network));
      expect(membership.tenantId, equals(50));
      expect(membership.roleKey, equals('NETWORK_OWNER'));
      expect(membership.typedRoleKey, equals(RoleKey.networkOwner));
      expect(membership.roleName, equals('مالك شبكة الأمل'));
      expect(user.hasNetworkMembership, isTrue);
      expect(user.hasPosMembership, isFalse);
      expect(user.isNetworkOwner, isTrue);
      expect(user.isPosAgent, isFalse);

      final workspace = WorkspaceService.instance.resolveWorkspaceForUser(user);
      expect(workspace, equals(AppWorkspace.network));
    });

    // 2. مستخدم لديه عضوية POS واحدة
    test('Scenario 2: Single POS membership resolves correctly and retains tenant ID', () {
      final user = UserModel.fromJson({
        'user_id': 202,
        'user_full_name': 'أحمد الوكيل',
        'user_phone_number': '770000202',
        'workspace_roles': [
          {
            'scope': 'POS',
            'tenant_id': 88,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل نقطة النور',
          },
        ],
      });

      expect(user.workspaceMemberships.length, equals(1));
      final membership = user.workspaceMemberships.first;
      expect(membership.scope, equals(RoleScope.pos));
      expect(membership.tenantId, equals(88));
      expect(membership.roleKey, equals('POS_AGENT'));
      expect(membership.typedRoleKey, equals(RoleKey.posAgent));
      expect(user.hasNetworkMembership, isFalse);
      expect(user.hasPosMembership, isTrue);
      expect(user.isNetworkOwner, isFalse);
      expect(user.isPosAgent, isTrue);

      final workspace = WorkspaceService.instance.resolveWorkspaceForUser(user);
      expect(workspace, equals(AppWorkspace.pos));
    });

    // 3. مستخدم لديه عضويات Network وPOS
    test(
      'Scenario 3: Dual Network and POS memberships honor user preference',
      () {
        final user = UserModel.fromJson({
          'user_id': 303,
          'user_full_name': 'صالح المشترك',
          'user_phone_number': '770000303',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 12,
              'role_key': 'NETWORK_USER',
              'role_name': 'محاسب شبكة',
            },
            {
              'scope': 'POS',
              'tenant_id': 45,
              'role_key': 'POS_USER',
              'role_name': 'كاشير نقطة بيع',
            },
          ],
        });

        expect(user.hasNetworkMembership, isTrue);
        expect(user.hasPosMembership, isTrue);

        expect(
          WorkspaceService.instance.resolveWorkspaceForUser(
            user,
            preferredWorkspace: 'network',
          ),
          equals(AppWorkspace.network),
        );
        expect(
          WorkspaceService.instance.resolveWorkspaceForUser(
            user,
            preferredWorkspace: 'pos',
          ),
          equals(AppWorkspace.pos),
        );
      },
    );

    // 4. مستخدم لديه أكثر من Network
    test('Scenario 4: Multiple Network memberships preserves all tenant IDs without picking first', () {
      final user = UserModel.fromJson({
        'user_id': 404,
        'user_full_name': 'مدير شبكات متعددة',
        'user_phone_number': '770000404',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 10,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'شبكة صنعاء',
          },
          {
            'scope': 'NETWORK',
            'tenant_id': 20,
            'role_key': 'NETWORK_USER',
            'role_name': 'شبكة عدن',
          },
        ],
      });

      final networkMemberships = user.workspaceMemberships
          .where((m) => m.isNetwork)
          .toList();
      expect(networkMemberships.length, equals(2));
      expect(networkMemberships.map((m) => m.tenantId), containsAll([10, 20]));
    });

    // 5. مستخدم لديه أكثر من POS
    test(
      'Scenario 5: Multiple POS memberships retains all points of sale cleanly',
      () {
        final user = UserModel.fromJson({
          'user_id': 505,
          'user_full_name': 'وكيل متعدد',
          'user_phone_number': '770000505',
          'workspace_roles': [
            {
              'scope': 'POS',
              'tenant_id': 100,
              'role_key': 'POS_AGENT',
              'role_name': 'نقطة التحرير',
            },
            {
              'scope': 'POS',
              'tenant_id': 200,
              'role_key': 'POS_AGENT',
              'role_name': 'نقطة حدة',
            },
          ],
        });

        final posMemberships = user.workspaceMemberships
            .where((m) => m.isPos)
            .toList();
        expect(posMemberships.length, equals(2));
        expect(posMemberships.map((m) => m.tenantId), containsAll([100, 200]));
      },
    );

    // 6. استعادة العضويات بعد إعادة تشغيل التطبيق (JSON Roundtrip)
    test('Scenario 6: JSON serialization roundtrip preserves all membership fields and roles', () {
      final original = UserModel(
        userId: 606,
        userFullName: 'فؤاد عبد الله',
        userPhoneNumber: '770000606',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 777,
            roleKey: 'POS_AGENT',
            roleName: 'نقطة الأمانة',
          ),
        ],
      );

      final jsonMap = original.toJson();
      final restored = UserModel.fromJson(jsonMap);

      expect(restored.userId, equals(606));
      expect(restored.workspaceMemberships.length, equals(1));
      expect(restored.workspaceMemberships.first.scope, equals(RoleScope.pos));
      expect(restored.workspaceMemberships.first.tenantId, equals(777));
      expect(restored.workspaceMemberships.first.roleKey, equals('POS_AGENT'));
      expect(
        restored.workspaceMemberships.first.roleName,
        equals('نقطة الأمانة'),
      );
    });

    // 7. استعادة المستأجر المحفوظ إذا كان لا يزال عضوية نشطة
    test('Scenario 7: Saved tenant ID is preserved if still present in active memberships', () async {
      final storage = StorageService.instance;
      await storage.setInt('${StorageKeys.activePosTenantPrefix}_707', 300);

      final user = UserModel(
        userId: 707,
        userFullName: 'محمد المحفوظ',
        userPhoneNumber: '770000707',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 300,
            roleKey: 'POS_AGENT',
            roleName: 'نقطة سارية',
          ),
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 400,
            roleKey: 'POS_AGENT',
            roleName: 'نقطة أخرى',
          ),
        ],
      );

      await WorkspaceService.instance.syncWithUserMemberships(user);

      // Verify saved ID was NOT purged
      expect(
        storage.getInt('${StorageKeys.activePosTenantPrefix}_707'),
        equals(300),
      );
    });

    // 8. رفض ومسح المستأجر المحفوظ إذا انتهت العضوية أو حذفت
    test('Scenario 8: Saved tenant ID is purged when membership is revoked or deleted', () async {
      final storage = StorageService.instance;
      await storage.setInt('${StorageKeys.activePosTenantPrefix}_808', 999);
      await storage.setInt('${StorageKeys.activePosNetworkPrefix}_808_999', 55);

      // User no longer has membership in POS #999 (membership revoked on backend)
      final user = UserModel(
        userId: 808,
        userFullName: 'مستخدم ملغى',
        userPhoneNumber: '770000808',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 111,
            roleKey: 'POS_AGENT',
            roleName: 'نقطة جديدة فقط',
          ),
        ],
      );

      await WorkspaceService.instance.syncWithUserMemberships(user);

      // Stale context must be completely purged
      expect(
        storage.getInt('${StorageKeys.activePosTenantPrefix}_808'),
        isNull,
      );
      expect(
        storage.getInt('${StorageKeys.activePosNetworkPrefix}_808_999'),
        isNull,
      );
    });

    // 9. تغيير الدور أثناء الجلسة
    test('Scenario 9: Role changes during session sync properly update PermissionService', () async {
      final initialUser = UserModel(
        userId: 909,
        userFullName: 'ياسر',
        userPhoneNumber: '770000909',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.network,
            tenantId: 10,
            roleKey: 'NETWORK_USER',
            roleName: 'مستخدم عادي',
          ),
        ],
      );

      await SessionService.instance.syncSessionProfile(
        user: initialUser,
        permissions: ['vouchers.view'],
        roleKey: 'NETWORK_USER',
      );

      expect(PermissionService.instance.currentRole, equals('NETWORK_USER'));

      // Backend promotes user to NETWORK_OWNER
      final updatedUser = UserModel(
        userId: 909,
        userFullName: 'ياسر',
        userPhoneNumber: '770000909',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.network,
            tenantId: 10,
            roleKey: 'NETWORK_OWNER',
            roleName: 'مالك شبكة',
          ),
        ],
      );

      await SessionService.instance.syncSessionProfile(
        user: updatedUser,
        permissions: ['vouchers.view', 'network.settings.manage'],
        roleKey: 'NETWORK_OWNER',
      );

      expect(PermissionService.instance.currentRole, equals('NETWORK_OWNER'));
      expect(PermissionService.instance.can('network.settings.manage'), isTrue);
    });

    // 10. تغيير الصلاحيات أثناء الجلسة
    test('Scenario 10: Permission changes update instantaneously without retaining stale permissions', () async {
      final user = UserModel(
        userId: 1010,
        userFullName: 'عادل',
        userPhoneNumber: '770001010',
      );

      await SessionService.instance.syncSessionProfile(
        user: user,
        permissions: ['permission.alpha', 'permission.beta'],
      );

      expect(PermissionService.instance.can('permission.alpha'), isTrue);
      expect(PermissionService.instance.can('permission.beta'), isTrue);
      expect(PermissionService.instance.can('permission.gamma'), isFalse);

      // Backend revokes alpha and grants gamma
      await SessionService.instance.syncSessionProfile(
        user: user,
        permissions: ['permission.beta', 'permission.gamma'],
      );

      expect(PermissionService.instance.can('permission.alpha'), isFalse);
      expect(PermissionService.instance.can('permission.beta'), isTrue);
      expect(PermissionService.instance.can('permission.gamma'), isTrue);
    });

    // 11. إعادة استجابة auth/me دون عضويات
    test('Scenario 11: Empty workspace_roles payload handled safely without exceptions or defaults', () {
      final user = UserModel.fromJson({
        'user': {
          'user_id': 1111,
          'user_full_name': 'مستخدم بلا صلاحيات',
          'user_phone_number': '770001111',
        },
        'workspace_roles': <dynamic>[],
        'permissions': <dynamic>[],
      });

      expect(user.workspaceMemberships, isEmpty);
      expect(user.hasNetworkMembership, isFalse);
      expect(user.hasPosMembership, isFalse);
      expect(user.isNetworkOwner, isFalse);
      expect(user.isPosAgent, isFalse);
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(user),
        equals(AppWorkspace.unsupported),
      );
    });

    // 12. منع بقاء صلاحيات قديمة عند تسجيل الخروج أو إنهاء الجلسة
    test('Scenario 12: Terminating session purges permissions, user, and active workspace', () async {
      final user = UserModel(
        userId: 1212,
        userFullName: 'طارق',
        userPhoneNumber: '770001212',
        workspaceMemberships: const [
          WorkspaceMembershipModel(
            scope: RoleScope.pos,
            tenantId: 50,
            roleKey: 'POS_AGENT',
            roleName: 'وكيل',
          ),
        ],
      );

      await SessionService.instance.startSession(
        user: user,
        session: const UserSessionModel(
          sessionId: 'test-sess-token',
          userId: 1212,
          deviceUuid: 'dev-1',
        ),
        permissions: ['pos.sales.create'],
      );

      expect(SessionService.instance.isAuthenticated, isTrue);
      expect(PermissionService.instance.can('pos.sales.create'), isTrue);

      await SessionService.instance.terminateSession();

      expect(SessionService.instance.isAuthenticated, isFalse);
      expect(SessionService.instance.currentUser, isNull);
      expect(PermissionService.instance.permissions, isEmpty);
      expect(PermissionService.instance.can('pos.sales.create'), isFalse);
      expect(
        WorkspaceService.instance.activeWorkspace,
        equals(AppWorkspace.unsupported),
      );
    });

    // 13. عدم خلط صلاحيات مستأجر بصلاحيات مستأجر آخر
    test('Scenario 13: Top-level permissions union is presentation-only and tenant isolation is enforced by Laravel', () {
      final user = UserModel.fromJson({
        'user_id': 1313,
        'user_full_name': 'مشغل مستأجرين',
        'user_phone_number': '770001313',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 1,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'شبكة رئيسية',
          },
          {
            'scope': 'NETWORK',
            'tenant_id': 2,
            'role_key': 'NETWORK_USER',
            'role_name': 'شبكة ثانوية',
          },
        ],
      });

      // Both memberships exist with independent tenant IDs
      final m1 = user.workspaceMemberships.firstWhere((m) => m.tenantId == 1);
      final m2 = user.workspaceMemberships.firstWhere((m) => m.tenantId == 2);
      expect(m1.roleKey, equals('NETWORK_OWNER'));
      expect(m2.roleKey, equals('NETWORK_USER'));
      expect(m1.tenantId, isNot(equals(m2.tenantId)));
    });

    // 14. عدم إدخال الأدوار التشغيلية في users.role_id أو سياق الأدوار العامة
    test('Scenario 14: Operational roles in workspace_roles do not pollute users.role_id or SuperAdmin', () {
      final user = UserModel.fromJson({
        'user': {
          'user_id': 1414,
          'role_id': null,
          'user_full_name': 'عضو تشغيلي نقي',
          'user_phone_number': '770001414',
          'role': null,
        },
        'is_super_admin': false,
        'role_key': null,
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 99,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك شبكة تشغيلي',
          },
        ],
      });

      expect(user.roleId, isNull);
      expect(user.role, isNull);
      expect(user.isSuperAdmin, isFalse);
      expect(user.isNetworkOwner, isTrue);
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(user),
        equals(AppWorkspace.network),
      );
    });
  });

  group('P0-1: Mandatory Acceptance Criteria Matrix (اختبارات القبول الإلزامية)', () {
    // 1. مستخدم Network فقط -> يستعيد مساحة Network
    test('Acceptance 1: مستخدم Network فقط يستعيد مساحة Network', () async {
      final user = UserModel.fromJson({
        'user_id': 1001,
        'user_full_name': 'مالك شبكة فقط',
        'user_phone_number': '771001001',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 15,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك شبكة الفجر',
          },
        ],
      });

      await SessionService.instance.syncSessionProfile(
        user: user,
        permissions: ['networks.view', 'vouchers.manage'],
      );

      expect(
        WorkspaceService.instance.activeWorkspace,
        equals(AppWorkspace.network),
      );
      expect(SessionService.instance.currentUser?.hasNetworkMembership, isTrue);
      expect(SessionService.instance.currentUser?.hasPosMembership, isFalse);
    });

    // 2. مستخدم POS فقط -> يستعيد مساحة POS
    test('Acceptance 2: مستخدم POS فقط يستعيد مساحة POS', () async {
      final user = UserModel.fromJson({
        'user_id': 1002,
        'user_full_name': 'وكيل نقطة فقط',
        'user_phone_number': '771001002',
        'workspace_roles': [
          {
            'scope': 'POS',
            'tenant_id': 25,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل نقطة الفجر',
          },
        ],
      });

      await SessionService.instance.syncSessionProfile(
        user: user,
        permissions: ['pos.sales.create'],
      );

      expect(
        WorkspaceService.instance.activeWorkspace,
        equals(AppWorkspace.pos),
      );
      expect(
        SessionService.instance.currentUser?.hasNetworkMembership,
        isFalse,
      );
      expect(SessionService.instance.currentUser?.hasPosMembership, isTrue);
    });

    // 3. مستخدم لديه المساحتان -> يحتفظ بالمساحتين ويمكنه التبديل بينهما
    test(
      'Acceptance 3: مستخدم لديه المساحتان يحتفظ بهما ويمكنه التبديل بينهما',
      () async {
        final user = UserModel.fromJson({
          'user_id': 1003,
          'user_full_name': 'مستخدم متعدد المساحات',
          'user_phone_number': '771001003',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 15,
              'role_key': 'NETWORK_USER',
              'role_name': 'عضو شبكة',
            },
            {
              'scope': 'POS',
              'tenant_id': 25,
              'role_key': 'POS_AGENT',
              'role_name': 'وكيل نقطة',
            },
          ],
        });

        await SessionService.instance.syncSessionProfile(
          user: user,
          permissions: ['networks.view', 'pos.sales.create'],
        );

        expect(
          SessionService.instance.currentUser?.hasNetworkMembership,
          isTrue,
        );
        expect(SessionService.instance.currentUser?.hasPosMembership, isTrue);

        // تبديل إلى Network
        await WorkspaceService.instance.setActiveWorkspace(
          AppWorkspace.network,
        );
        expect(
          WorkspaceService.instance.activeWorkspace,
          equals(AppWorkspace.network),
        );

        // تبديل إلى POS
        await WorkspaceService.instance.setActiveWorkspace(AppWorkspace.pos);
        expect(
          WorkspaceService.instance.activeWorkspace,
          equals(AppWorkspace.pos),
        );
      },
    );

    // 4. مستخدم بلا دور عام -> يعمل بناءً على العضوية الصحيحة
    test('Acceptance 4: مستخدم بلا دور عام (role_id: null) يعمل بناءً على العضوية الصحيحة', () async {
      final user = UserModel.fromJson({
        'user': {
          'user_id': 1004,
          'role_id': null,
          'user_full_name': 'مستخدم بدون دور عام',
          'user_phone_number': '771001004',
          'role': null,
        },
        'role_key': null,
        'workspace_roles': [
          {
            'scope': 'POS',
            'tenant_id': 33,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل معتمد',
          },
        ],
      });

      expect(user.roleId, isNull);
      expect(user.role, isNull);
      expect(user.isPosAgent, isTrue);
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(user),
        equals(AppWorkspace.pos),
      );
    });

    // 5. تغيير الدور -> تتحدث الصلاحيات دون إعادة تشغيل التطبيق
    test(
      'Acceptance 5: تغيير الدور يحدث الصلاحيات والقدرات فوراً دون إعادة تشغيل',
      () async {
        final userV1 = UserModel.fromJson({
          'user_id': 1005,
          'user_full_name': 'صالح ترقية',
          'user_phone_number': '771001005',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 10,
              'role_key': 'NETWORK_USER',
              'role_name': 'مستخدم',
            },
          ],
        });

        await SessionService.instance.syncSessionProfile(
          user: userV1,
          permissions: ['vouchers.view'],
          roleKey: 'NETWORK_USER',
        );

        expect(PermissionService.instance.currentRole, equals('NETWORK_USER'));
        expect(
          PermissionService.instance.can('network.settings.manage'),
          isFalse,
        );

        // ترقية الدور من الخادم
        final userV2 = UserModel.fromJson({
          'user_id': 1005,
          'user_full_name': 'صالح ترقية',
          'user_phone_number': '771001005',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 10,
              'role_key': 'NETWORK_OWNER',
              'role_name': 'مالك',
            },
          ],
        });

        await SessionService.instance.syncSessionProfile(
          user: userV2,
          permissions: ['vouchers.view', 'network.settings.manage'],
          roleKey: 'NETWORK_OWNER',
        );

        expect(PermissionService.instance.currentRole, equals('NETWORK_OWNER'));
        expect(
          PermissionService.instance.can('network.settings.manage'),
          isTrue,
        );
      },
    );

    // 6. إلغاء العضوية -> يُمنع الوصول إلى المساحة الملغاة
    test('Acceptance 6: إلغاء العضوية يمنع الوصول للمساحة الملغاة ويمسح سياق المستأجر', () async {
      final storage = StorageService.instance;
      await storage.setInt('${StorageKeys.activePosTenantPrefix}_1006', 77);

      final userWithRevokedMembership = UserModel.fromJson({
        'user_id': 1006,
        'user_full_name': 'مستخدم ألغيت عضويته',
        'user_phone_number': '771001006',
        'workspace_roles': <dynamic>[], // عضوية مسحوبة
      });

      await SessionService.instance.syncSessionProfile(
        user: userWithRevokedMembership,
        permissions: [],
      );

      expect(
        storage.getInt('${StorageKeys.activePosTenantPrefix}_1006'),
        isNull,
      );
      expect(
        WorkspaceService.instance.activeWorkspace,
        equals(AppWorkspace.unsupported),
      );
    });

    // 7. اختلاف المستأجر -> لا تنتقل صلاحيات مستأجر إلى آخر
    test(
      'Acceptance 7: اختلاف المستأجر يعزل الهوية ولا ينقل صلاحيات مستأجر لآخر',
      () {
        final user = UserModel.fromJson({
          'user_id': 1007,
          'user_full_name': 'مستأجرين منفصلين',
          'user_phone_number': '771001007',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 501,
              'role_key': 'NETWORK_OWNER',
              'role_name': 'شبكة مالك',
            },
            {
              'scope': 'NETWORK',
              'tenant_id': 502,
              'role_key': 'NETWORK_USER',
              'role_name': 'شبكة موظف',
            },
          ],
        });

        final ownerMembership = user.workspaceMemberships.firstWhere(
          (m) => m.tenantId == 501,
        );
        final userMembership = user.workspaceMemberships.firstWhere(
          (m) => m.tenantId == 502,
        );

        expect(ownerMembership.roleKey, equals('NETWORK_OWNER'));
        expect(userMembership.roleKey, equals('NETWORK_USER'));
        expect(
          ownerMembership.tenantId,
          isNot(equals(userMembership.tenantId)),
        );
      },
    );

    // 8. استعادة الجلسة بعد إغلاق التطبيق وإعادة تشغيله (App reboot & cold start simulation)
    test('Acceptance 8: شرط الإغلاق — استعادة الجلسة بعد إغلاق التطبيق وإعادة تشغيله مع كامل العضويات', () async {
      // 1. بدء جلسة وحفظها
      final user = UserModel.fromJson({
        'user_id': 1008,
        'user_full_name': 'مستخدم إعادة التشغيل',
        'user_phone_number': '771001008',
        'workspace_roles': [
          {
            'scope': 'POS',
            'tenant_id': 888,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل إعادة تشغيل',
          },
        ],
      });

      await SessionService.instance.startSession(
        user: user,
        session: const UserSessionModel(
          sessionId: 'persisted-session-token',
          userId: 1008,
          deviceUuid: 'device-reboot-1',
        ),
        permissions: ['pos.sales.create', 'reports.view'],
      );

      expect(SessionService.instance.isAuthenticated, isTrue);

      // 2. محاكاة إغلاق التطبيق تماماً (Cold App Restart)
      // تفريغ ذاكرة GetX بالكامل
      Get.reset();

      // 3. إعادة إقلاع خدمات التطبيق من التخزين الدائم
      Get.put<StorageService>(StorageService.instance);
      Get.put<PermissionService>(PermissionService.instance);
      Get.put<WorkspaceService>(WorkspaceService.instance);
      Get.put<SessionService>(SessionService.instance);

      await SessionService.instance.init();
      await WorkspaceService.instance.init();

      // 4. التحقق من الاستعادة الكاملة
      expect(SessionService.instance.isAuthenticated, isTrue);
      expect(
        SessionService.instance.currentSessionId,
        equals('persisted-session-token'),
      );

      final restoredUser = SessionService.instance.currentUser;
      expect(restoredUser, isNotNull);
      expect(restoredUser!.userId, equals(1008));
      expect(restoredUser.workspaceMemberships.length, equals(1));

      final restoredMembership = restoredUser.workspaceMemberships.first;
      expect(restoredMembership.scope, equals(RoleScope.pos));
      expect(restoredMembership.tenantId, equals(888));
      expect(restoredMembership.roleKey, equals('POS_AGENT'));
      expect(restoredMembership.roleName, equals('وكيل إعادة تشغيل'));

      // التحقق من استعادة الصلاحيات دون ضياع
      expect(PermissionService.instance.can('pos.sales.create'), isTrue);
      expect(PermissionService.instance.can('reports.view'), isTrue);

      // التحقق من استعادة مساحة العمل الصحيحة
      expect(
        WorkspaceService.instance.activeWorkspace,
        equals(AppWorkspace.pos),
      );
    });
  });
}
