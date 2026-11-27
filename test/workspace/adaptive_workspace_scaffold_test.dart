import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

void main() {
  Widget harness(Widget child) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) =>
        GetMaterialApp(theme: AppThemes.light, home: child),
  );

  final items = [
    const WorkspaceNavItem(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      content: Text('Home'),
    ),
    const WorkspaceNavItem(
      label: 'الطلبات',
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      content: Text('Requests'),
    ),
    const WorkspaceNavItem(
      label: 'الدليل',
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
      content: Text('Directory'),
    ),
    const WorkspaceNavItem(
      label: 'البروفايل',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      content: Text('Profile'),
    ),
  ];

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    await tester.pumpWidget(
      harness(
        AdaptiveWorkspaceScaffold(
          appBar: WorkspaceAppBar(
            title: 'مساحة العمل',
            workspace: AppWorkspace.network,
            onProfileTap: () {},
          ),
          items: items,
          mobileItems: items,
          currentIndex: 0,
          mobileCurrentIndex: 0,
          onIndexChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone has exactly four primary destinations and no More tab', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));
    expect(find.byType(CustomFloatingBottomNavBar), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      expect(find.byKey(ValueKey('nav_item_$index')), findsOneWidget);
    }
    expect(find.text('المزيد'), findsNothing);
    expect(find.byKey(const ValueKey('nav_item_4')), findsNothing);
  });

  testWidgets('compact phone and tablet use NavigationRail', (tester) async {
    await pumpAt(tester, const Size(375, 450));
    expect(find.byType(NavigationRail), findsOneWidget);
    await pumpAt(tester, const Size(800, 1024));
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('desktop uses persistent NavigationDrawer', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    expect(find.byType(NavigationDrawer), findsOneWidget);
  });
}
