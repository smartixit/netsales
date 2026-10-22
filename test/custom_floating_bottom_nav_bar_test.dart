import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          bottomNavigationBar: child,
        ),
      ),
    );
  }

  void setupPhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final testItems = const [
    CustomFloatingNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    CustomFloatingNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'المبيعات',
      badgeCount: 5,
    ),
    CustomFloatingNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'العملاء',
    ),
    CustomFloatingNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'الإعدادات',
    ),
  ];

  group('CustomFloatingNavItem Data Model Tests', () {
    test('instantiates with required and optional properties cleanly', () {
      const item = CustomFloatingNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'الرئيسية',
        badgeCount: 3,
        tooltip: 'الانتقال للرئيسية',
      );

      expect(item.icon, Icons.home_outlined);
      expect(item.activeIcon, Icons.home);
      expect(item.label, 'الرئيسية');
      expect(item.badgeCount, 3);
      expect(item.tooltip, 'الانتقال للرئيسية');
    });
  });

  group('CustomFloatingBottomNavBar Widget Tests', () {
    testWidgets('renders all items and handles tab switching', (tester) async {
      setupPhoneScreen(tester);
      int selectedTab = 0;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return CustomFloatingBottomNavBar(
                currentIndex: selectedTab,
                items: testItems,
                onTap: (index) {
                  setState(() => selectedTab = index);
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // التحقق من ظهور كافة تسميات التبويبات
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('المبيعات'), findsOneWidget);
      expect(find.text('العملاء'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);

      // التحقق من ظهور شارة التنبيهات للتبويب الثاني
      expect(find.text('5'), findsOneWidget);

      // النقر على تبويب المبيعات
      await tester.tap(find.text('المبيعات'));
      await tester.pumpAndSettle();

      expect(selectedTab, 1);
    });

    testWidgets('renders center action button and triggers callback', (tester) async {
      setupPhoneScreen(tester);
      bool centerActionTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CustomFloatingBottomNavBar(
            currentIndex: 0,
            items: testItems,
            onTap: (_) {},
            onCenterActionTap: () {
              centerActionTapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // التحقق من ظهور الزر المركزي
      expect(find.byType(FloatingCenterActionButton), findsOneWidget);

      // النقر على الزر المركزي
      await tester.tap(find.byType(FloatingCenterActionButton));
      await tester.pumpAndSettle();

      expect(centerActionTapped, isTrue);
    });
  });
}
