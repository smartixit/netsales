import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_active_context_banner.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_logout_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_preferences_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_security_section.dart';

void main() {
  Widget testHarness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  final testProfile = const ProfileEntity(
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

  group('Profile Screen Composition & VIP Components Tests', () {
    testWidgets('ProfileActiveContextBanner renders active workspace label', (
      tester,
    ) async {
      await tester.pumpWidget(
        testHarness(
          const ProfileActiveContextBanner(
            activeWorkspaceLabel: 'شبكة النخبة الذكية',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المساحة النشطة: شبكة النخبة الذكية'), findsOneWidget);
    });

    testWidgets('ProfileIdentityCard renders name, status, contact pills and action button', (
      tester,
    ) async {
      var phoneCopied = false;
      var emailCopied = false;
      var profileCompleted = false;

      await tester.pumpWidget(
        testHarness(
          ProfileIdentityCard(
            profile: testProfile,
            onCopyPhone: () => phoneCopied = true,
            onCopyEmail: () => emailCopied = true,
            onAvatarChanged: (_) {},
            onCompleteProfile: () => profileCompleted = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('عبدالرحمن الشامي'), findsOneWidget);
      expect(find.text('حساب موثق'), findsOneWidget);
      expect(find.text('+967 771 234 567'), findsOneWidget);
      expect(find.text('shami@smartix.net'), findsOneWidget);
      expect(find.text('إكمال الملف'), findsOneWidget);

      await tester.tap(find.text('+967 771 234 567'));
      expect(phoneCopied, isTrue);

      await tester.tap(find.text('shami@smartix.net'));
      expect(emailCopied, isTrue);

      await tester.tap(find.text('إكمال الملف'));
      expect(profileCompleted, isTrue);
    });

    testWidgets('ProfileSecuritySection renders 2FA, password, and active sessions', (
      tester,
    ) async {
      var securityOpened = false;
      var sessionsOpened = false;

      await tester.pumpWidget(
        testHarness(
          ProfileSecuritySection(
            profile: testProfile,
            onOpenSecurity: () => securityOpened = true,
            onOpenSessions: () => sessionsOpened = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مركز الأمان والحماية'), findsOneWidget);
      expect(find.text('المصادقة الثنائية'), findsOneWidget);
      expect(find.text('محمي'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('الجلسات والأجهزة'), findsOneWidget);

      await tester.tap(find.text('المصادقة الثنائية'));
      expect(securityOpened, isTrue);

      await tester.tap(find.text('الجلسات والأجهزة'));
      expect(sessionsOpened, isTrue);
    });

    testWidgets('ProfilePreferencesSection toggles theme mode without language selector', (
      tester,
    ) async {
      var themeToggled = false;

      await tester.pumpWidget(
        testHarness(
          ProfilePreferencesSection(
            isDarkMode: true,
            onToggleTheme: () => themeToggled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الوضع الليلي'), findsOneWidget);
      expect(find.text('الوضع الداكن مفعّل'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Verify no language selector exists
      expect(find.text('اللغة (العربية)'), findsNothing);
      expect(find.text('لغة الواجهة'), findsNothing);

      await tester.tap(find.byType(Switch));
      expect(themeToggled, isTrue);
    });

    testWidgets('ProfileLogoutTile triggers logout on tap', (tester) async {
      var loggedOut = false;

      await tester.pumpWidget(
        testHarness(ProfileLogoutTile(onLogout: () => loggedOut = true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الخروج من الحساب'), findsOneWidget);
      expect(find.text('إنهاء الجلسة والعودة لشاشة تسجيل الدخول'), findsOneWidget);

      await tester.tap(find.text('تسجيل الخروج من الحساب'));
      expect(loggedOut, isTrue);
    });
  });
}
