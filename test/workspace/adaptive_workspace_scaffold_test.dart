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
  Widget buildTestableWidget({
    required Size screenSize,
    required Widget child,
  }) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) =>
            MaterialApp(theme: AppThemes.light, home: child),
      ),
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

  testWidgets(
    'AdaptiveWorkspaceScaffold renders CustomFloatingBottomNavBar on mobile screens (< 600px)',
    (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        buildTestableWidget(
          screenSize: const Size(400, 800), // Mobile width < 600
          child: AdaptiveWorkspaceScaffold(
            appBar: const WorkspaceAppBar(
              title: 'مساحة العمل',
              workspace: AppWorkspace.network,
            ),
            items: testItems,
            currentIndex: selectedIndex,
            onIndexChanged: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Mobile CustomFloatingBottomNavBar is rendered
      expect(find.byType(CustomFloatingBottomNavBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('محتوى الرئيسية'), findsOneWidget);
    },
  );

  testWidgets(
    'AdaptiveWorkspaceScaffold renders NavigationRail on tablet screens (>= 600px)',
    (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        buildTestableWidget(
          screenSize: const Size(800, 1024), // Tablet width >= 600
          child: AdaptiveWorkspaceScaffold(
            appBar: const WorkspaceAppBar(
              title: 'مساحة العمل',
              workspace: AppWorkspace.network,
            ),
            items: testItems,
            currentIndex: selectedIndex,
            onIndexChanged: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Tablet NavigationRail is rendered
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(CustomFloatingBottomNavBar), findsNothing);
      expect(find.text('محتوى الرئيسية'), findsOneWidget);
    },
  );
}
