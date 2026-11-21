import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:netsales/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource(this.response);

  final ApiResponse<Map<String, dynamic>> response;

  @override
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  _FakeProfileRemoteDataSource(this.user);

  final UserModel user;

  @override
  Future<UserModel> getProfile() async => user;
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.result);

  final Future<ProfileEntity> Function() result;

  @override
  Future<ProfileEntity> getProfile() => result();
}

void main() {
  group('Profile remote data contract', () {
    test(
      'maps /auth/me user and network/POS memberships without merging scope',
      () async {
        final dataSource = ProfileRemoteDataSourceImpl(
          _FakeAuthRemoteDataSource(
            ApiResponse(
              success: true,
              message: 'تم جلب البروفايل.',
              data: {
                'user': {
                  'user_id': 42,
                  'user_full_name': 'مستخدم تجريبي',
                  'user_phone_number': '777000042',
                  'user_email': 'profile@example.test',
                  'user_profile_logo': 'https://example.test/avatar.png',
                  'user_2fa_enabled': true,
                  'status': 'ACTIVE',
                  'status_label': 'نشط',
                },
                'is_super_admin': false,
                'role_key': 'NETWORK_OWNER',
                'workspace_roles': [
                  {
                    'scope': 'NETWORK',
                    'tenant_id': 15,
                    'role_key': 'NETWORK_OWNER',
                    'role_name': 'مالك الشبكة',
                  },
                  {
                    'scope': 'POS',
                    'tenant_id': 27,
                    'role_key': 'POS_AGENT',
                    'role_name': 'وكيل نقطة البيع',
                  },
                ],
              },
            ),
          ),
        );

        final user = await dataSource.getProfile();

        expect(user.userId, 42);
        expect(user.userFullName, 'مستخدم تجريبي');
        expect(user.user2faEnabled, isTrue);
        expect(user.workspaceMemberships, hasLength(2));
        expect(user.workspaceMemberships[0].scope.wireValue, 'NETWORK');
        expect(user.workspaceMemberships[0].tenantId, 15);
        expect(user.workspaceMemberships[1].scope.wireValue, 'POS');
        expect(user.workspaceMemberships[1].tenantId, 27);
      },
    );

    test('rejects malformed /auth/me response rather than displaying empty account data', () async {
      final dataSource = ProfileRemoteDataSourceImpl(
        _FakeAuthRemoteDataSource(
          ApiResponse(
            success: true,
            message: 'OK',
            data: {'user': 'not-a-map'},
          ),
        ),
      );

      await expectLater(dataSource.getProfile(), throwsA(isA<AppException>()));
    });

    test('rejects unsuccessful profile response', () async {
      final dataSource = ProfileRemoteDataSourceImpl(
        _FakeAuthRemoteDataSource(
          ApiResponse(success: false, message: 'انتهت صلاحية الجلسة.'),
        ),
      );

      await expectLater(
        dataSource.getProfile(),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'انتهت صلاحية الجلسة.',
          ),
        ),
      );
    });
  });

  group('Profile repository and controller', () {
    test(
      'maps server status and scoped memberships into profile domain',
      () async {
        final user = UserModel.fromJson({
          'user_id': 8,
          'user_full_name': 'صاحب حساب',
          'user_phone_number': '771111111',
          'user_2fa_enabled': false,
          'status': 'ACTIVE',
          'workspace_roles': [
            {
              'scope': 'NETWORK',
              'tenant_id': 101,
              'role_key': 'NETWORK_OWNER',
              'role_name': 'مالك الشبكة',
            },
            {
              'scope': 'POS',
              'tenant_id': 202,
              'role_key': 'POS_AGENT',
              'role_name': 'وكيل نقطة البيع',
            },
          ],
        });

        final repository = ProfileRepositoryImpl(
          _FakeProfileRemoteDataSource(user),
        );
        final profile = await repository.getProfile();

        expect(profile.userId, 8);
        expect(profile.statusLabel, 'مفعّل');
        expect(profile.twoFactorEnabled, isFalse);
        expect(profile.memberships, hasLength(2));
        expect(profile.memberships[0].scope, RoleScope.network);
        expect(profile.memberships[0].tenantId, 101);
        expect(profile.memberships[1].scope, RoleScope.pos);
        expect(profile.memberships[1].tenantId, 202);
      },
    );

    test('loads profile into observable controller state', () async {
      const expected = ProfileEntity(
        userId: 5,
        fullName: 'حساب تجريبي',
        phoneNumber: '770000005',
        status: UserStatus.active,
        twoFactorEnabled: true,
        mustChangePassword: false,
        memberships: [
          ProfileMembershipEntity(
            scope: RoleScope.network,
            tenantId: 3,
            roleKey: RoleKey.networkOwner,
            roleName: 'مالك الشبكة',
          ),
        ],
      );
      final controller = ProfileController(
        getProfileUseCase: GetProfileUseCase(
          _FakeProfileRepository(() async => expected),
        ),
      );

      await controller.loadProfile();

      expect(controller.profile.value, same(expected));
      expect(controller.errorMessage.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('exposes a recoverable error when profile loading fails', () async {
      final controller = ProfileController(
        getProfileUseCase: GetProfileUseCase(
          _FakeProfileRepository(() async {
            throw const AppException('تعذر جلب بيانات الحساب.');
          }),
        ),
      );

      await controller.loadProfile();

      expect(controller.profile.value, isNull);
      expect(controller.errorMessage.value, 'تعذر جلب بيانات الحساب.');
      expect(controller.isLoading.value, isFalse);
    });
  });
}
