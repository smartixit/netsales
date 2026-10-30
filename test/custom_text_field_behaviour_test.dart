import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// Regression lock for the *default* behaviours of [CustomTextField].
///
/// These tests exist because a previous change replaced `onFieldSubmitted`
/// with `onEditingComplete` + `onTapOutside`, which silently disabled
/// Flutter's built-in editing behaviour (focus traversal, unfocus on done,
/// tap-outside unfocus, clearComposing). Any future edit that breaks one of
/// these contracts must fail here first.
void main() {
  Widget buildTestable(Widget child) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) =>
        MaterialApp(theme: AppThemes.light, home: Scaffold(body: child)),
  );

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<FocusNode> fieldFocusNodes(WidgetTester tester) => tester
      .widgetList<EditableText>(find.byType(EditableText))
      .map((e) => e.focusNode)
      .toList();

  testWidgets('TextInputAction.next moves focus to the following field', (
    tester,
  ) async {
    setupScreen(tester);
    final first = TextEditingController();
    final second = TextEditingController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(
      buildTestable(
        Column(
          children: [
            CustomTextField(
              controller: first,
              label: 'first',
              textInputAction: TextInputAction.next,
            ),
            CustomTextField(
              controller: second,
              label: 'second',
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField).first);
    await tester.pump();

    final nodes = fieldFocusNodes(tester);
    expect(nodes[0].hasFocus, isTrue, reason: 'first field must be focused');

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();

    final after = fieldFocusNodes(tester);
    expect(
      after[1].hasFocus,
      isTrue,
      reason: 'TextInputAction.next must traverse to the next focus node',
    );
  });

  testWidgets('TextInputAction.done unfocuses the field', (tester) async {
    setupScreen(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestable(
        CustomTextField(
          controller: controller,
          label: 'only',
          textInputAction: TextInputAction.done,
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(fieldFocusNodes(tester).single.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      fieldFocusNodes(tester).single.hasFocus,
      isFalse,
      reason: 'TextInputAction.done must unfocus by default',
    );
  });

  testWidgets('tapping outside with a desktop pointer unfocuses the field', (
    tester,
  ) async {
    setupScreen(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await tester.pumpWidget(
        buildTestable(
          Column(
            children: [
              CustomTextField(controller: controller, label: 'only'),
              const Expanded(child: SizedBox.expand()),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(fieldFocusNodes(tester).single.hasFocus, isTrue);

      await tester.tapAt(const Offset(200, 780));
      await tester.pumpAndSettle();

      expect(
        fieldFocusNodes(tester).single.hasFocus,
        isFalse,
        reason: 'default onTapOutside must unfocus on desktop platforms',
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tapping outside with a touch pointer keeps focus (mobile)', (
    tester,
  ) async {
    setupScreen(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestable(
        Column(
          children: [
            CustomTextField(controller: controller, label: 'only'),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    await tester.tapAt(const Offset(200, 780));
    await tester.pumpAndSettle();

    expect(
      fieldFocusNodes(tester).single.hasFocus,
      isTrue,
      reason:
          'Flutter keeps focus on touch tap-outside for mobile; a custom '
          'onTapOutside must not change that',
    );
  });

  testWidgets('losing focus trims surrounding whitespace', (tester) async {
    setupScreen(tester);
    final controller = TextEditingController(text: '  abc  ');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestable(CustomTextField(controller: controller, label: 'only')),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(fieldFocusNodes(tester).single.hasFocus, isTrue);

    fieldFocusNodes(tester).single.unfocus();
    await tester.pumpAndSettle();

    expect(
      controller.text,
      'abc',
      reason: 'blur-trim behaviour must be preserved',
    );
  });

  testWidgets('submitting trims the value and forwards it', (tester) async {
    setupScreen(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? submitted;

    await tester.pumpWidget(
      buildTestable(
        CustomTextField(
          controller: controller,
          label: 'only',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) => submitted = value,
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), '  hello  ');
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(controller.text, 'hello');
    expect(submitted, 'hello');
  });

  testWidgets('rejects leading whitespace on user input', (tester) async {
    setupScreen(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestable(CustomTextField(controller: controller, label: 'only')),
    );

    await tester.enterText(find.byType(TextFormField), '  spaced');
    await tester.pump();

    expect(controller.text, 'spaced');
  });
}
