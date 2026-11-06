
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/data_grid/showcase/data_grid_showcase_binding.dart';
import 'package:netsales/widgets/data_grid/showcase/data_grid_showcase_screen.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() async {
    await Get.reset();
    Get.testMode = false;
  });

  testWidgets('renders the DataGrid showcase and feature controls', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DataGridShowcaseScreen(),
          initialBinding: DataGridShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('معرض نظام الجداول'), findsOneWidget);
    expect(find.text('سجل العمليات التجارية'), findsOneWidget);
    expect(find.text('العميل'), findsWidgets);
    expect(find.text('المنطقة'), findsWidgets);
    expect(find.text('بيانات العملية'), findsOneWidget);
    expect(find.text('تفاصيل المعالجة'), findsOneWidget);
    expect(find.byTooltip('الوضع الفاتح/الداكن'), findsOneWidget);
    expect(find.byTooltip('RTL / LTR'), findsOneWidget);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('toggles theme and text direction in the showcase', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DataGridShowcaseScreen(),
          initialBinding: DataGridShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('الوضع الفاتح/الداكن'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((widget) => widget is Theme && widget.data.brightness == Brightness.dark), findsWidgets);
    await tester.tap(find.byTooltip('RTL / LTR'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((widget) => widget is Directionality && widget.textDirection == TextDirection.ltr), findsWidgets);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  testWidgets('uses compact selectable record cards on mobile widths', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          home: const DataGridShowcaseScreen(),
          initialBinding: DataGridShowcaseBinding(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('data-grid-mobile')), findsOneWidget);
    expect(find.byKey(const ValueKey('data-grid-desktop')), findsNothing);
    expect(find.byType(Checkbox), findsWidgets);
    expect(find.byTooltip('تصدير Excel'), findsNothing);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

}
