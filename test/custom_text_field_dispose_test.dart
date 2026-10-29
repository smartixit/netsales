import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

void main() {
  Widget buildTestable(Widget child) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: AppThemes.light,
          home: Scaffold(body: child),
        ),
      );

  void setupPhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('no exception when controller disposed before teardown',
      (tester) async {
    setupPhoneScreen(tester);
    final controller = TextEditingController(text: '  abc  ');

    await tester.pumpWidget(
      buildTestable(CustomTextField(controller: controller, label: 'x')),
    );

    // Simulate GetX ownership ordering: controller disposed before the
    // widget subtree is unmounted.
    controller.dispose();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('normalizes text on editing complete', (tester) async {
    setupPhoneScreen(tester);
    final controller = TextEditingController(text: '  abc  ');

    await tester.pumpWidget(
      buildTestable(CustomTextField(controller: controller, label: 'x')),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(controller.text, 'abc');
  });
}
