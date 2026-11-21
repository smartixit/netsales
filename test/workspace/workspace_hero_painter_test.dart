import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_illustration_painter.dart';

void main() {
  group('Workspace hero vector artwork', () {
    for (final isNetwork in [true, false]) {
      testWidgets(
        isNetwork ? 'paints the network illustration' : 'paints the POS illustration',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 320,
                    height: 224,
                    child: CustomPaint(
                      painter: WorkspaceHeroIllustrationPainter(
                        isNetwork: isNetwork,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint &&
                  widget.painter is WorkspaceHeroIllustrationPainter,
            ),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets('handles an empty canvas without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: Size.zero,
              painter: WorkspaceHeroIllustrationPainter(isNetwork: true),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
