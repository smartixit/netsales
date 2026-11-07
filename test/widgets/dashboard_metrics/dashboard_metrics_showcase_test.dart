import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/dashboard_metrics/showcase/dashboard_metrics_showcase_binding.dart';
import 'package:netsales/widgets/dashboard_metrics/showcase/dashboard_metrics_showcase_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    Get.reset();
    Get.testMode = false;
  });

  testWidgets('shows the KPI showcase and all preview controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DashboardMetricsShowcaseScreen(),
          initialBinding: DashboardMetricsShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('معرض مؤشرات الأداء'), findsOneWidget);
    expect(find.text('إعدادات المعاينة'), findsOneWidget);
    expect(find.text('فاتح'), findsOneWidget);
    expect(find.text('داكن'), findsOneWidget);
    expect(find.textContaining('RTL'), findsOneWidget);
    expect(find.text('LTR'), findsOneWidget);
  });

  testWidgets('switches the preview theme and text direction locally', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DashboardMetricsShowcaseScreen(),
          initialBinding: DashboardMetricsShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Theme && widget.data.brightness == Brightness.dark,
      ),
      findsWidgets,
    );

    await tester.tap(find.textContaining('من اليمين لليسار'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.rtl,
      ),
      findsWidgets,
    );

    await tester.tap(find.text('إعادة الضبط').last);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.ltr,
      ),
      findsWidgets,
    );
  });

  testWidgets('renders the KPI variants and component states', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DashboardMetricsShowcaseScreen(),
          initialBinding: DashboardMetricsShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('إجمالي الشبكات'),
      320,
      scrollable: scrollable,
    );
    expect(find.text('إجمالي الشبكات'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('متوسط زمن الاستجابة'),
      320,
      scrollable: scrollable,
    );
    expect(find.text('متوسط زمن الاستجابة'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('استقرار الخدمة'),
      320,
      scrollable: scrollable,
    );
    expect(find.text('استقرار الخدمة'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('المبيعات اليومية'),
      320,
      scrollable: scrollable,
    );
    expect(find.text('المبيعات اليومية'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('حالات المكوّن'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('لا توجد بيانات للفترة المحددة'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('لا توجد بيانات للفترة المحددة'), findsOneWidget);
    expect(find.text('تعذر تحميل المؤشر — مثال توضيحي'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
