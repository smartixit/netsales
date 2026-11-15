import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';

void main() {
  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('CustomCarouselSlider', () {
    testWidgets('renders items through the consumer builder', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          CustomCarouselSlider<String>(
            items: const ['Network A', 'Network B'],
            height: 180,
            viewportFraction: 0.9,
            itemBuilder: (context, item, index) => Center(
              child: Text(item, key: ValueKey(item)),
            ),
          ),
        ),
      );

      expect(find.text('Network A'), findsOneWidget);
    });

    testWidgets('renders the supplied empty state when there are no items', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          CustomCarouselSlider<String>(
            items: const [],
            itemBuilder: (context, item, index) => Text(item),
            emptyBuilder: (_) => const Text('No networks'),
          ),
        ),
      );

      expect(find.text('No networks'), findsOneWidget);
    });

    testWidgets('does not render indicators for a single item', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(
          CustomCarouselSlider<String>(
            items: const ['Only network'],
            height: 180,
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      );

      expect(find.text('Only network'), findsOneWidget);
      expect(find.byType(CustomCarouselIndicators), findsNothing);
    });
  });
}
