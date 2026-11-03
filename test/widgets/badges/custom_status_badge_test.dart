import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

Widget _buildTestApp(Widget child, {ThemeMode mode = ThemeMode.light}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      themeMode: mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('CustomStatusBadge Widget Tests', () {
    testWidgets('renders badge text and dot indicator', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CustomStatusBadge(
            label: 'مفعّل',
            tone: SemanticTone.success,
            showDot: true,
          ),
        ),
      );

      expect(find.text('مفعّل'), findsOneWidget);
    });

    testWidgets('renders from EnumPresentation with icon', (tester) async {
      const presentation = EnumPresentation(
        label: 'محظور',
        tone: SemanticTone.danger,
        icon: Icons.block_rounded,
      );

      await tester.pumpWidget(
        _buildTestApp(CustomStatusBadge.fromPresentation(presentation)),
      );

      expect(find.text('محظور'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    });

    testWidgets('renders compact density badge in dark theme without crash', (
      tester,
    ) async {
      const presentation = EnumPresentation(
        label: 'قيد الانتظار',
        tone: SemanticTone.warning,
      );

      await tester.pumpWidget(
        _buildTestApp(
          CustomStatusBadge.fromPresentation(
            presentation,
            isCompact: true,
            showDot: true,
          ),
          mode: ThemeMode.dark,
        ),
      );

      expect(find.text('قيد الانتظار'), findsOneWidget);
    });
  });

  group('CustomChip Widget Tests', () {
    testWidgets('renders neutral chip with label and icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CustomChip(
            label: 'أندرويد',
            icon: Icons.phone_android_rounded,
            isCompact: true,
          ),
        ),
      );

      expect(find.text('أندرويد'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap and onDeleted callbacks', (tester) async {
      var tapped = false;
      var deleted = false;

      await tester.pumpWidget(
        _buildTestApp(
          CustomChip(
            label: 'قابل للحذف',
            onTap: () => tapped = true,
            onDeleted: () => deleted = true,
          ),
        ),
      );

      await tester.tap(find.text('قابل للحذف'));
      expect(tapped, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(deleted, isTrue);
    });
  });
}
