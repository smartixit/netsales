import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:premium_carousel_slider/premium_carousel_slider.dart';

void main() {
  group('PremiumCarouselSlider', () {
    testWidgets('renders every item through the consumer builder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 220,
              child: PremiumCarouselSlider<String>(
                items: const ['Network A', 'Network B'],
                options: const PremiumCarouselOptions(
                  height: 180,
                  viewportFraction: 0.9,
                  enableInfiniteScroll: false,
                ),
                itemBuilder: (context, item, index) => Center(
                  child: Text(item, key: ValueKey(item)),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Network A'), findsOneWidget);
      expect(find.text('Network B'), findsOneWidget);
    });

    testWidgets('renders the supplied empty state when there are no items', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumCarouselSlider<String>(
              items: const [],
              itemBuilder: (context, item, index) => Text(item),
              emptyBuilder: (_) => const Text('No networks'),
            ),
          ),
        ),
      );

      expect(find.text('No networks'), findsOneWidget);
    });

    testWidgets('does not render a page indicator for a single item', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 220,
              child: PremiumCarouselSlider<String>(
                items: const ['Only network'],
                options: const PremiumCarouselOptions(height: 180),
                itemBuilder: (context, item, index) => Text(item),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Only network'), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNothing);
    });
  });
}
