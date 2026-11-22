import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

Widget _harness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await DatePickerService.instance.init();
  });

  group('CustomDatePickerField', () {
    testWidgets('participates in Form validation for a required date', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _harness(
          Form(
            key: formKey,
            child: CustomDatePickerField.single(
              label: 'تاريخ الاستحقاق',
              isRequired: true,
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('synchronizes an externally updated controlled value', (
      tester,
    ) async {
      final selectedDate = ValueNotifier<DateTime?>(DateTime(2026, 11, 5));
      addTearDown(selectedDate.dispose);

      await tester.pumpWidget(
        _harness(
          ValueListenableBuilder<DateTime?>(
            valueListenable: selectedDate,
            builder: (context, value, child) => CustomDatePickerField.single(
              label: 'التاريخ',
              value: value,
              onChanged: (nextValue) => selectedDate.value = nextValue,
              displayFormatter: (date) =>
                  date == null ? 'فارغ' : 'يوم ${date.day}',
            ),
          ),
        ),
      );

      expect(find.text('يوم 5'), findsOneWidget);

      selectedDate.value = DateTime(2026, 11, 19);
      await tester.pump();

      expect(find.text('يوم 19'), findsOneWidget);
      expect(find.text('يوم 5'), findsNothing);
    });

    testWidgets(
      'clears a selected date and emits null from the single factory',
      (tester) async {
        DateTime? changedValue = DateTime(2026, 11, 5);

        await tester.pumpWidget(
          _harness(
            CustomDatePickerField.single(
              label: 'التاريخ',
              value: changedValue,
              onChanged: (value) => changedValue = value,
            ),
          ),
        );

        await tester.tap(find.byTooltip('مسح التاريخ المحدد'));
        await tester.pump();

        expect(changedValue, isNull);
        expect(find.byTooltip('مسح التاريخ المحدد'), findsNothing);
      },
    );

    testWidgets('rejects an incomplete range through Form validation', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _harness(
          Form(
            key: formKey,
            child: CustomDatePickerField(
              label: 'الفترة',
              pickerType: DatePickerSelectionMode.range,
              value: [DateTime(2026, 11, 1)],
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('يرجى تحديد تاريخ البداية والنهاية'), findsOneWidget);
    });

    testWidgets('preserves a range whose end date was selected first', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CustomDatePickerField(
            label: 'الفترة',
            pickerType: DatePickerSelectionMode.range,
            value: [null, DateTime(2026, 11, 18)],
            displayFormatter: (dates) =>
                dates.length == 2 && dates.first == null && dates.last != null
                ? 'إلى ${dates.last!.day}'
                : 'نطاق غير صحيح',
          ),
        ),
      );

      expect(find.text('إلى 18'), findsOneWidget);
      expect(find.text('نطاق غير صحيح'), findsNothing);
    });

    testWidgets('runs a custom validator for an optional empty field', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _harness(
          Form(
            key: formKey,
            child: CustomDatePickerField.single(
              label: 'تاريخ مرجعي',
              validator: (date) =>
                  date == null ? 'يلزم تحديد التاريخ المرجعي' : null,
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('يلزم تحديد التاريخ المرجعي'), findsOneWidget);
    });

    testWidgets('rejects externally supplied dates outside the allowed range', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _harness(
          Form(
            key: formKey,
            child: CustomDatePickerField.single(
              label: 'التاريخ',
              value: DateTime(2026, 10, 31),
              firstDate: DateTime(2026, 11, 1),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('التاريخ المحدد خارج النطاق المسموح'), findsOneWidget);
    });

    testWidgets('supports narrow RTL layouts without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _harness(
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 260,
              child: CustomDatePickerField.single(
                label: 'تاريخ بداية الفترة التشغيلية الطويلة',
                value: DateTime(2026, 11, 22),
                displayFormatter: (_) =>
                    'الأحد، الثاني والعشرون من نوفمبر لعام ألفين وستة وعشرين',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomDatePickerField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('normalizes duplicate dates in multi selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          CustomDatePickerField.multi(
            label: 'تواريخ محددة',
            value: [
              DateTime(2026, 11, 5),
              DateTime(2026, 11, 5, 15),
              DateTime(2026, 11, 7),
            ],
            displayFormatter: (dates) => '${dates.length} تواريخ',
          ),
        ),
      );

      expect(find.text('2 تواريخ'), findsOneWidget);
    });
  });
}
