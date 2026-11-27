import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_metrics_grid.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';

void main() {
  final sampleMetrics = [
    DashboardMetricData(
      id: 'pos',
      title: 'نقاط البيع',
      value: '42',
      unit: 'نقطة',
      icon: Icons.storefront_rounded,
      tone: DashboardMetricTone.primary,
      variant: DashboardMetricVariant.standard,
      description: 'نشطة 35 · غير نشطة 7',
    ),
    DashboardMetricData(
      id: 'requests',
      title: 'طلبات التوريد',
      value: '18',
      unit: 'طلب',
      icon: Icons.inbox_rounded,
      tone: DashboardMetricTone.warning,
      variant: DashboardMetricVariant.standard,
      description: 'بانتظار الاعتماد 4',
    ),
    DashboardMetricData(
      id: 'packages',
      title: 'باقات الكتالوج',
      value: '26',
      unit: 'باقة',
      icon: Icons.widgets_rounded,
      tone: DashboardMetricTone.info,
      variant: DashboardMetricVariant.standard,
      description: 'باقات نشطة: 22',
    ),
  ];

  Widget buildHarness({
    required Widget child,
    Size surfaceSize = const Size(375, 812),
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(size: surfaceSize),
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  group('ExecutiveMetricsGrid Responsiveness and Layout Tests', () {
    testWidgets(
      'Mobile viewport adopts 2-column layout to prevent clipping and crowding',
      (tester) async {
        tester.view.physicalSize = const Size(375 * 2, 812 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(
          buildHarness(
            surfaceSize: const Size(375, 812),
            child: ExecutiveMetricsGrid(
              items: sampleMetrics,
              onPointsOfSaleTap: () {},
              onRequestsTap: () {},
              onPackagesTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All 3 cards should render
        final cardFinders = find.byType(DashboardMetricCard);
        expect(cardFinders, findsNWidgets(3));

        // Cards must have ample width (greater than 140) to prevent clipping
        final cardBoxes = tester
            .renderObjectList<RenderBox>(cardFinders)
            .toList();
        for (final box in cardBoxes) {
          expect(box.size.width, greaterThan(140.0));
        }

        // Full labels and descriptions must be rendered without being completely cut off
        expect(find.text('نقاط البيع'), findsOneWidget);
        expect(find.text('طلبات التوريد'), findsOneWidget);
        expect(find.text('باقات الكتالوج'), findsOneWidget);
        expect(find.text('نشطة 35 · غير نشطة 7'), findsOneWidget);
        expect(find.text('بانتظار الاعتماد 4'), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet / Desktop viewport arranges cards in 3 columns comfortably',
      (tester) async {
        tester.view.physicalSize = const Size(900 * 2, 1200 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(
          buildHarness(
            surfaceSize: const Size(900, 1200),
            child: ExecutiveMetricsGrid(
              items: sampleMetrics,
              onPointsOfSaleTap: () {},
              onRequestsTap: () {},
              onPackagesTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cardFinders = find.byType(DashboardMetricCard);
        expect(cardFinders, findsNWidgets(3));

        final cardBoxes = tester
            .renderObjectList<RenderBox>(cardFinders)
            .toList();
        // On wide screen, cards have generous width >= 200
        for (final box in cardBoxes) {
          expect(box.size.width, greaterThan(200.0));
        }
      },
    );
  });

  group('ExecutiveMetricsGrid Navigation and Action Routing Tests', () {
    testWidgets('Tapping POS metric calls onPointsOfSaleTap', (tester) async {
      var posTapped = false;

      await tester.pumpWidget(
        buildHarness(
          child: ExecutiveMetricsGrid(
            items: sampleMetrics,
            onPointsOfSaleTap: () => posTapped = true,
            onRequestsTap: () {},
            onPackagesTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('نقاط البيع'));
      await tester.pumpAndSettle();

      expect(posTapped, isTrue);
    });

    testWidgets('Tapping Requests metric calls onRequestsTap', (tester) async {
      var requestsTapped = false;

      await tester.pumpWidget(
        buildHarness(
          child: ExecutiveMetricsGrid(
            items: sampleMetrics,
            onPointsOfSaleTap: () {},
            onRequestsTap: () => requestsTapped = true,
            onPackagesTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('طلبات التوريد'));
      await tester.pumpAndSettle();

      expect(requestsTapped, isTrue);
    });

    testWidgets('Tapping Packages metric calls onPackagesTap', (tester) async {
      var packagesTapped = false;

      await tester.pumpWidget(
        buildHarness(
          child: ExecutiveMetricsGrid(
            items: sampleMetrics,
            onPointsOfSaleTap: () {},
            onRequestsTap: () {},
            onPackagesTap: () => packagesTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('باقات الكتالوج'));
      await tester.pumpAndSettle();

      expect(packagesTapped, isTrue);
    });
  });

  group('WorkspaceAppBar Entity Identity Tests', () {
    testWidgets(
      'Displays entity initials and entity logo instead of user initials',
      (tester) async {
        await tester.pumpWidget(
          buildHarness(
            child: const WorkspaceAppBar(
              title: 'شبكة يمن واي فاي',
              workspace: AppWorkspace.network,
              entityInitials: 'شي',
              entityLogo: null,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Finds the avatar badge with entity initials 'شي'
        expect(find.byType(CustomAvatarBadge), findsOneWidget);
        expect(find.text('شي'), findsOneWidget);
        expect(find.text('شبكة يمن واي فاي'), findsOneWidget);
      },
    );

    testWidgets(
      'Uses the shared theme toggle instead of the legacy sheet trigger',
      (tester) async {
        await tester.pumpWidget(
          buildHarness(
            child: const WorkspaceAppBar(
              title: 'مساحة العمل',
              workspace: AppWorkspace.network,
              onProfileTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomThemeToggleButton), findsOneWidget);
        expect(find.byIcon(Icons.tune_rounded), findsNothing);
      },
    );

    testWidgets(
      'Falls back to workspace letter when entity initials are empty',
      (tester) async {
        await tester.pumpWidget(
          buildHarness(
            child: const WorkspaceAppBar(
              title: 'نقطة بيع الأمل',
              workspace: AppWorkspace.pos,
              onProfileTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Default POS letter fallback is 'ن'
        expect(find.text('ن'), findsOneWidget);
        expect(find.text('نقطة بيع الأمل'), findsOneWidget);
      },
    );
  });
}
