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
      final clearButton = find.byTooltip('مسح');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      final confirmButton = find.text('تأكيد');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
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

      final minuteIncrement = find.byTooltip('زيادة').last;
      await tester.ensureVisible(minuteIncrement);
      await tester.tap(minuteIncrement);
      await tester.pump();

      expect(find.text('00'), findsOneWidget);
      expect(find.text('صباحاً (ص)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final cancelButton = find.text('إلغاء');
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
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

      final minuteDecrement = find.byTooltip('إنقاص').last;
      await tester.ensureVisible(minuteDecrement);
      await tester.tap(minuteDecrement);
      await tester.pump();

      expect(find.text('55'), findsOneWidget);
      expect(find.text('مساءً (م)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final cancelButton = find.text('إلغاء');
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });

    testWidgets('does not overflow in compact landscape with time enabled', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1;

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

      final cancelButton = find.text('إلغاء');
      await tester.ensureVisible(cancelButton);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
