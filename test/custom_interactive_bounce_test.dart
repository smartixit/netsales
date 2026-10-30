import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

void main() {
  group('CustomInteractiveBounce Gesture & Nesting Contract Tests', () {
    testWidgets('Nested CustomInteractiveBounce executes ONLY child and NEVER parent', (tester) async {
      bool parentTapped = false;
      bool childTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomInteractiveBounce(
                onTap: () => parentTapped = true,
                child: Container(
                  key: const Key('parent_card'),
                  width: 300,
                  height: 300,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: CustomInteractiveBounce(
                    onTap: () => childTapped = true,
                    child: Container(
                      key: const Key('child_bounce_btn'),
                      width: 100,
                      height: 100,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // 1. النقر على الزر الداخلي
      await tester.tap(find.byKey(const Key('child_bounce_btn')));
      await tester.pumpAndSettle();

      expect(childTapped, isTrue, reason: 'Child must be tapped');
      expect(parentTapped, isFalse, reason: 'Parent must NOT be tapped when clicking child');

      // 2. النقر على البطاقة الخارجية في منطقة لا تحتوي على الزر الداخلي
      childTapped = false;
      parentTapped = false;

      await tester.tapAt(tester.getTopLeft(find.byKey(const Key('parent_card'))) + const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(parentTapped, isTrue, reason: 'Parent must be tapped when clicking its surface');
      expect(childTapped, isFalse, reason: 'Child must NOT be tapped when clicking outside it');
    });

    testWidgets('Raw GestureDetector or Button inside parent bounce executes ONLY the inner button', (tester) async {
      bool parentTapped = false;
      bool buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomInteractiveBounce(
                onTap: () => parentTapped = true,
                child: Container(
                  key: const Key('parent_card_2'),
                  width: 300,
                  height: 300,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => buttonTapped = true,
                    child: Container(
                      key: const Key('inner_button'),
                      width: 80,
                      height: 80,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // النقر على الزر الداخلي
      await tester.tap(find.byKey(const Key('inner_button')));
      await tester.pumpAndSettle();

      expect(buttonTapped, isTrue, reason: 'Inner button must be tapped');
      expect(parentTapped, isFalse, reason: 'Parent bounce must NOT trigger when inner button is tapped');
    });
  });
}
