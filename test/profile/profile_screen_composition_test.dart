import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_body.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  final ProfileEntity profile;

  @override
  Future<ProfileEntity> getProfile() async => profile;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const profile = ProfileEntity(
    userId: 1,
    fullName: 'عبدالرحمن الشامي',
    phoneNumber: '+967 771 234 567',
    email: 'shami@smartix.net',
    status: UserStatus.active,
    statusLabel: 'حساب موثق',
    twoFactorEnabled: true,
    mustChangePassword: false,
    primaryRoleKey: RoleKey.networkOwner,
    primaryRoleName: 'مالك الشبكة',
    memberships: [],
  );

  setUp(() {
    Get.testMode = true;
    Get.put(
      ProfileController(
        getProfileUseCase: GetProfileUseCase(_FakeProfileRepository(profile)),
        updateProfileUseCase: UpdateProfileUseCase(
          _FakeProfileRepository(profile),
        ),
        updateAvatarUseCase: UpdateAvatarUseCase(
          _FakeProfileRepository(profile),
        ),
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('ProfileBody composes the current account settings sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ProfileBody()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('معلوماتك الشخصية'), findsOneWidget);
    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
    expect(find.text('تغيير كلمة المرور'), findsOneWidget);
    expect(find.text('التحقق بخطوتين'), findsOneWidget);
  });
}
