import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/workspace/presentation/widgets/adaptive_workspace_scaffold.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

void main() {
  Widget buildTestableWidget({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(theme: AppThemes.light, home: child),
    );
  }

  final testItems = [
    const WorkspaceNavItem(
      label: 'الرئيسية',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      content: Text('محتوى الرئيسية'),
    ),
    const WorkspaceNavItem(
      label: 'الطلبات',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      content: Text('محتوى الطلبات'),
    ),
  ];

  Future<void> pumpAtSize(
    WidgetTester tester, {
    required Size logicalSize,
  }) async {
    tester.view.physicalSize = logicalSize * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      buildTestableWidget(
        child: AdaptiveWorkspaceScaffold(
          appBar: const WorkspaceAppBar(
            title: 'مساحة العمل',
            workspace: AppWorkspace.network,
          ),
          items: testItems,
          currentIndex: 0,
          onIndexChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('portrait phone uses the floating bottom navigation bar', (
    tester,
  ) async {
    await pumpAtSize(tester, logicalSize: const Size(375, 812));

    expect(find.byType(CustomFloatingBottomNavBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('compact-height phone uses NavigationRail instead of bottom bar', (
    tester,
  ) async {
    await pumpAtSize(tester, logicalSize: const Size(375, 450));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(CustomFloatingBottomNavBar), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('tablet uses NavigationRail', (tester) async {
    await pumpAtSize(tester, logicalSize: const Size(800, 1024));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(CustomFloatingBottomNavBar), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('desktop uses persistent NavigationDrawer', (tester) async {
    await pumpAtSize(tester, logicalSize: const Size(1440, 900));

    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(CustomFloatingBottomNavBar), findsNothing);
  });
}
