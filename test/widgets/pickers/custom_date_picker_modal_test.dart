import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';

Widget _harness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  setUpAll(() async {
    await DatePickerService.instance.init();
  });

  group('CustomDatePickerModal', () {
    testWidgets('anchors the shared bottom sheet at the viewport bottom', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'اختيار التاريخ',
                  mode: DatePickerSelectionMode.single,
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();

      final content = find.byKey(
        const ValueKey<String>('custom-date-picker-sheet-content'),
      );
      expect(content, findsOneWidget);

      final rect = tester.getRect(content);
      final viewportBottom =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      expect(rect.bottom, greaterThan(viewportBottom - 48));
      expect(rect.height, lessThan(viewportBottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirms an intentional clear as an empty selection', (
      tester,
    ) async {
      late Future<List<DateTime?>?> selectionResult;

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                selectionResult = CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'تواريخ محددة',
                  mode: DatePickerSelectionMode.multi,
                  initialValue: [DateTime(2026, 11, 18)],
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('مسح الاختيار'));
      await tester.pump();
      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();

      expect(await selectionResult, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('caps and centers sheet width on a desktop window', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'اختيار التاريخ',
                  mode: DatePickerSelectionMode.single,
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();

      final content = find.byKey(
        const ValueKey<String>('custom-date-picker-sheet-content'),
      );
      expect(content, findsOneWidget);
      final rect = tester.getRect(content);

      expect(rect.width, closeTo(AppBreakpoints.maxModalWidth, 1));
      expect(rect.center.dx, closeTo(500, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('minute increment carries into the next hour at midnight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'اختيار التاريخ والوقت',
                  mode: DatePickerSelectionMode.single,
                  enableTime: true,
                  initialValue: [DateTime(2026, 11, 18, 23, 55)],
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();

      expect(find.text('55'), findsOneWidget);
      await tester.tap(find.byTooltip('زيادة').last);
      await tester.pump();

      expect(find.text('00'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('minute decrement carries into the previous hour at midnight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'اختيار التاريخ والوقت',
                  mode: DatePickerSelectionMode.single,
                  enableTime: true,
                  initialValue: [DateTime(2026, 11, 18, 0, 0)],
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();

      expect(find.text('00'), findsOneWidget);
      await tester.tap(find.byTooltip('إنقاص').last);
      await tester.pump();

      expect(find.text('55'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow in compact landscape with time enabled', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _harness(
          Builder(
            builder: (context) => TextButton(
              onPressed: () {
                CustomDatePickerModal.showBottomSheet(
                  context: context,
                  title: 'اختيار التاريخ والوقت',
                  mode: DatePickerSelectionMode.single,
                  enableTime: true,
                );
              },
              child: const Text('فتح المنتقي'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح المنتقي'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('custom-date-picker-sheet-content')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
