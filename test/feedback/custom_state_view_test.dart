import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

void main() {
  Widget buildTestable(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('renders compact loading state with shared hierarchy', (tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      buildTestable(
        const CustomStateView.loading(
          presentation: CustomStatePresentation.compact,
          title: 'جارٍ تحميل الباقات',
        ),
      ),
    );

    expect(find.text('جارٍ تحميل الباقات'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state with contextual action', (tester) async {
    configureViewport(tester);
    var actionCalled = false;
    await tester.pumpWidget(
      buildTestable(
        CustomStateView.empty(
          title: 'لا توجد باقات',
          presentation: CustomStatePresentation.compact,
          actionLabel: 'تحديث',
          onAction: () => actionCalled = true,
        ),
      ),
    );

    expect(find.text('لا توجد باقات'), findsOneWidget);
    await tester.tap(find.text('تحديث'));
    await tester.pump();
    expect(actionCalled, isTrue);
  });

  testWidgets('renders offline banner in non-blocking presentation', (tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      buildTestable(
        const CustomStateView.offline(
          presentation: CustomStatePresentation.banner,
          title: 'الاتصال غير متاح',
        ),
      ),
    );

    expect(find.text('الاتصال غير متاح'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });

  testWidgets('renders expired pricing with refresh action', (tester) async {
    configureViewport(tester);
    var refreshed = false;
    await tester.pumpWidget(
      buildTestable(
        CustomStateView.pricingExpired(
          presentation: CustomStatePresentation.compact,
          onAction: () => refreshed = true,
        ),
      ),
    );

    expect(find.text('انتهت صلاحية التعرفة'), findsOneWidget);
    await tester.tap(find.text('تحديث التعرفة'));
    await tester.pump();
    expect(refreshed, isTrue);
  });

  testWidgets('renders error with retry action', (tester) async {
    configureViewport(tester);
    var retried = false;
    await tester.pumpWidget(
      buildTestable(
        CustomStateView.error(
          title: 'تعذر تحميل البيانات',
          presentation: CustomStatePresentation.compact,
          onAction: () => retried = true,
        ),
      ),
    );

    expect(find.text('تعذر تحميل البيانات'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    expect(retried, isTrue);
  });
  testWidgets('builds adaptive list skeleton with requested item count', (tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      buildTestable(
        const CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeleton: CustomStateSkeleton(
            layout: CustomStateSkeletonLayout.list,
            itemCount: 4,
            cardHeight: 88,
          ),
        ),
      ),
    );

    expect(find.byType(FractionallySizedBox), findsNWidgets(8));
  });

  testWidgets('adapts grid skeleton to available width', (tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      buildTestable(
        const SizedBox(
          width: 720,
          child: CustomStateView.loading(
            presentation: CustomStatePresentation.skeletonOnly,
            skeleton: CustomStateSkeleton(
              layout: CustomStateSkeletonLayout.grid,
              itemCount: 6,
              maxColumns: 3,
              minItemWidth: 180,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNWidgets(12));
  });

  testWidgets('supports a screen-shaped custom skeleton builder', (tester) async {
    configureViewport(tester);
    await tester.pumpWidget(
      buildTestable(
        CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeletonBuilder: (_) => const SizedBox(
            key: ValueKey('screen-specific-skeleton'),
            height: 240,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('screen-specific-skeleton')), findsOneWidget);
  });

}
