import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/dashboard_layout/dashboard_layout.dart';

void main() {
  final navigation = DashboardNavigationSection(
    items: [
      DashboardNavigationItem(
        id: 'home',
        label: 'Home',
        icon: Icons.home_outlined,
      ),
    ],
  );

  testWidgets('renders content and selected navigation item', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardShell(
          navigation: navigation,
          selectedNavigationId: 'home',
          onNavigationSelected: (_) {},
          sidebarHeader: const Text('Brand'),
          child: const Text('Dashboard content'),
        ),
      ),
    );

    expect(find.text('Dashboard content'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
  });

  testWidgets('uses drawer navigation at compact width', (tester) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardShell(
          navigation: navigation,
          selectedNavigationId: 'home',
          onNavigationSelected: (_) {},
          child: const Text('Compact content'),
        ),
      ),
    );

    expect(find.text('Compact content'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
  });
}
